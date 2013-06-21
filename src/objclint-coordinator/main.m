//
//  main.m
//  objclint-coordinator
//
//  Created by Alexander Smirnov on 12/9/12.
//  Copyright (c) 2012 Alexander Smirnov. All rights reserved.
//

#import "ObjclintCoordinatorImpl.h"
#import "NSUserDefaults+OCL.h"
#include <stdlib.h>

static NSString* const kObjclintServiceName = @"ru.smirn0v.objclint.coordinator";

static NSString* const kObjclintStart  = @"start";
static NSString* const kObjclintCheck  = @"check";
static NSString* const kObjclintReport = @"report";

void usage() {
    fprintf(
            stderr,
            "usage: %s [-%s|-%s|-%s]\n\n"
            "Arguments are exclusive.\n"
            "-%s  – start objclint session in current directory\n"
            "-%s  – check if objclint stared\n"
            "-%s – print report for current session\n",
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
             @"lints-directory": @[@"./lints"]
             };
}

NSString* projectIdentity() {
    return [[NSFileManager defaultManager] currentDirectoryPath];
}

NSDictionary* readObjclintConfiguration() {
    NSError* error = nil;
    NSData* configurationData = [NSData dataWithContentsOfFile: @".objclint"];
    id jsonConfiguration = [NSJSONSerialization JSONObjectWithData: configurationData
                                                           options: 0
                                                             error: &error];
    
    if(configurationData && error != nil) {
        fprintf(stderr,
                "failed to read .objclint configuration file, ignoring it.\n%s",
                error.localizedDescription.UTF8String);
    }
    
    if(!jsonConfiguration)
        jsonConfiguration = defaultConfiguration();
    
    if(NO == [jsonConfiguration isKindOfClass:[NSDictionary class]]) {
        fprintf(stderr,"wrong configuration file format, ignoring it");
    }
    
    return jsonConfiguration;
}

ObjclintCoordinatorImpl* createCoordinator(BOOL createIfNeeded, NSConnection** connection) {
    NSConnection* tmpConnection;
    if(!connection)
        connection = &tmpConnection;
    
    *connection = [[NSConnection connectionWithRegisteredName: kObjclintServiceName
                                                         host: nil] autorelease];
    
    [(*connection).rootProxy setProtocolForProxy: @protocol(ObjclintCoordinator)];
    id<ObjclintCoordinator> coordinator = (id<ObjclintCoordinator>) (*connection).rootProxy;

    if(NO == createIfNeeded)
        return coordinator;
    
    *connection = [[[NSConnection alloc] init] autorelease];
    
    NSProtocolChecker* rootObject = nil;
    
    coordinator = [[ObjclintCoordinatorImpl new] autorelease];
    rootObject  = [NSProtocolChecker protocolCheckerWithTarget: coordinator
                                                      protocol: @protocol(ObjclintCoordinator)];
    
    [*connection setRootObject: rootObject];
    
    if([*connection registerName: kObjclintServiceName])
        return coordinator;
    
    fprintf(stderr, "failed to register service %s", kObjclintServiceName.UTF8String);
    
    return nil;
}


void objclintStart() {
    NSDictionary* objclintConfiguration = readObjclintConfiguration();
    
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
            NSDate* boundaryDate = [NSDate dateWithTimeInterval:1*60 sinceDate:[NSDate date]];
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
}

int main(int argc, const char* argv[]) {
    @autoreleasepool {
        
        NSUserDefaults* arguments = [NSUserDefaults standardUserDefaults];

        NSDictionary* argumentsAndActions = @{
                                              kObjclintStart:  [[^{objclintStart();}  copy] autorelease],
                                              kObjclintCheck:  [[^{objclintCheck();}  copy] autorelease],
                                              kObjclintReport: [[^{objclintReport();} copy] autorelease]
                                            };

        __block NSUInteger exclusiveArgumentsCount = 0;
        [argumentsAndActions.allKeys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if(arguments[obj] != nil)
                exclusiveArgumentsCount++;
        }];
        
        if(exclusiveArgumentsCount != 1) {
            usage();
            return 1;
        }
        
        for(NSString* key in argumentsAndActions.allKeys) {
            if(arguments[key] != nil) {
                ((void(^)())argumentsAndActions[key])();
                break;
            }
        }

    }
    return 0;
}

