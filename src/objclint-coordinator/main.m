//
//  main.m
//  objclint-coordinator
//
//  Created by Alexander Smirnov on 12/9/12.
//  Copyright (c) 2012 Alexander Smirnov. All rights reserved.
//

#import "ObjclintCoordinatorImpl.h"
#import "TextReportGenerator.h"
#include <stdlib.h>

static NSString* const kObjclintConfigurationFile = @".objclint";

static NSString* const kObjclintStart  = @"-start";
static NSString* const kObjclintCheck  = @"-check";
static NSString* const kObjclintReport = @"-report";

void usage() {
    fprintf(
            stderr,
            "usage: %s [%s|%s|%s]\n\n"
            "Arguments are exclusive.\n"
            "%s  – start objclint session in current directory\n"
            "%s  – check if objclint stared\n"
            "%s – print report for current session\n",
            [[NSProcessInfo processInfo].processName UTF8String],
            kObjclintStart.UTF8String,
            kObjclintCheck.UTF8String,
            kObjclintReport.UTF8String,
            kObjclintStart.UTF8String,
            kObjclintCheck.UTF8String,
            kObjclintReport.UTF8String
        );
}

NSDictionary* defaultConfiguration() {
    return @{
             kObjclintConfigurationLintsDirs: @[@"./lints"]
             };
}

NSString* projectIdentity() {
    return [[NSFileManager defaultManager] currentDirectoryPath];
}

NSDictionary* readObjclintConfiguration() {
    NSError* error             = nil;
    NSData*  configurationData = [NSData dataWithContentsOfFile: kObjclintConfigurationFile];
    id       jsonConfiguration = nil;
    
    if(configurationData) {
        jsonConfiguration = [NSJSONSerialization JSONObjectWithData: configurationData
                                                            options: 0
                                                              error: &error];
    }
    
    if(configurationData && error != nil) {
        fprintf(stderr,
                "failed to read .objclint configuration file, ignoring it.\n%s\n",
                error.localizedDescription.UTF8String);
    }
    
    if(!jsonConfiguration)
        jsonConfiguration = defaultConfiguration();
    
    if(NO == [jsonConfiguration isKindOfClass:[NSDictionary class]]) {
        fprintf(stderr,"wrong configuration file format, ignoring it\n");
    }
    
    return jsonConfiguration;
}

ObjclintCoordinatorImpl* createCoordinator(BOOL createIfNeeded, NSConnection** connection) {
    NSConnection* tmpConnection;
    if(!connection)
        connection = &tmpConnection;
    
    *connection = [NSConnection connectionWithRegisteredName: kObjclintServiceName
                                                        host: nil];
    
    [(*connection).rootProxy setProtocolForProxy: @protocol(ObjclintCoordinator)];
    id<ObjclintCoordinator> coordinator = (id<ObjclintCoordinator>) (*connection).rootProxy;

    if(coordinator || NO == createIfNeeded)
        return coordinator;
    
    *connection = [[[NSConnection alloc] init] autorelease];
    
    coordinator = [[ObjclintCoordinatorImpl new] autorelease];
    
    [*connection setRootObject: coordinator];
    
    if([*connection registerName: kObjclintServiceName])
        return coordinator;
    
    fprintf(stderr, "failed to register service %s\n", kObjclintServiceName.UTF8String);
    
    return nil;
}


void objclintStart() {
    NSDictionary* objclintConfiguration = readObjclintConfiguration();
    NSArray* lintsDirs = objclintConfiguration[kObjclintConfigurationLintsDirs];
    if(lintsDirs.count == 0) {
        fprintf(stderr, "no lint directories provided. at least one directory must be provided\n");
    }
    
    NSConnection* connection = nil;
    
    ObjclintCoordinatorImpl* coordinator =
    createCoordinator(/* createIfNeeded */ YES, &connection);
    
    if(!coordinator || !connection)
        exit(1);
    
    [coordinator clearSessionForProjectIdentity: projectIdentity()];
    [coordinator setConfiguration: objclintConfiguration forProjectIdentity: projectIdentity()];
    
    NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
    [connection addRunLoop:runLoop];
    
    // die after 5 minutes of inactivity
    while (1) {
        @autoreleasepool {
            NSDate* boundaryDate = [NSDate dateWithTimeInterval:60 sinceDate:[NSDate date]];
            [runLoop runMode:NSDefaultRunLoopMode beforeDate: boundaryDate];
            if([[NSDate date] timeIntervalSinceDate: coordinator.lastActionDate] > 5*60)
                break;
        }
    }
}

void objclintCheck() {
    if(nil == createCoordinator(/* createIfNeeded */NO, nil))
        exit(1);
}

void objclintReport() {
    id<ObjclintReportGenerator> reportGenerator = [[[TextReportGenerator alloc] init] autorelease];
    
    ObjclintCoordinatorImpl* coordinator =
    createCoordinator(/* createIfNeeded */ NO,
                      /* connection */ nil);
    
    if(coordinator)
        [reportGenerator generateReportForProjectIdentity: projectIdentity()
                                        withinCoordinator: coordinator];
}

int main(int argc, const char* argv[]) {
    @autoreleasepool {
        
        NSDictionary* argumentsAndActions = nil;
        argumentsAndActions = @{
                                kObjclintStart:  [[^{objclintStart();}  copy] autorelease],
                                kObjclintCheck:  [[^{objclintCheck();}  copy] autorelease],
                                kObjclintReport: [[^{objclintReport();} copy] autorelease]
                                };
        
        NSMutableSet* passedArgs = [NSMutableSet set];
        for(int i = 1; i < argc; ++i) {
            NSString* arg = [NSString stringWithUTF8String:argv[i]];
            [passedArgs addObject: arg];
        }   

        NSMutableSet* intersection = [NSMutableSet setWithArray: argumentsAndActions.allKeys];
        [intersection intersectSet: passedArgs];

        if(intersection.count != 1 || passedArgs.count != 1) {
            usage();
            return 1;
        }
        
        for(NSString* key in argumentsAndActions.allKeys) {
            if([passedArgs containsObject: key]) {
                ((void(^)())argumentsAndActions[key])();
                break;
            }
        }

    }
    return 0;
}

