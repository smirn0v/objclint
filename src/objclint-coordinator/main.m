//
//  main.m
//  objclint-coordinator
//
//  Created by Smirnov on 12/9/12.
//  Copyright (c) 2012 Borsch Lab. All rights reserved.
//

#import "ObjclintSessionManager.h"

static NSString* serviceName = @"ru.borsch-lab.objclint.coordinator";

BOOL setupExistingCoordinator(NSString* projectIdentity, NSString* jsValidatorsFolder) {
    NSConnection* existingCoordinatorConnection = [[NSConnection connectionWithRegisteredName: serviceName
                                                                                         host: nil] autorelease];
    
    [existingCoordinatorConnection.rootProxy setProtocolForProxy:@protocol(ObjclintSessionManagerProtocol)];
    id<ObjclintSessionManagerProtocol> sessionManager = (id<ObjclintSessionManagerProtocol>) existingCoordinatorConnection.rootProxy;
    
    [sessionManager clearSessionForProjectIdentity: projectIdentity];
    [sessionManager setLintJSValidatorsFolderPath:jsValidatorsFolder forProjectIdentity:projectIdentity];
    
    return existingCoordinatorConnection != nil;
}

int main(int argc, const char* argv[]) {
    @autoreleasepool {
        

        NSString* projectIdentity = [[NSFileManager defaultManager] currentDirectoryPath];
        NSString* jsValidatorsFolder = @"/opt/local/share/objclint-validators";
        //TODO: support for '.objclint' configuration for validators folder
        
        if(setupExistingCoordinator(projectIdentity, jsValidatorsFolder)) {
            printf("Connected to existing %s, prepared for new session\n", argv[0]);
            return 0;
        }

        NSRunLoop* runLoop = [NSRunLoop currentRunLoop];

        ObjclintSessionManager* sessionManager = [[ObjclintSessionManager new] autorelease];
        
        NSConnection* connection = [[[NSConnection alloc] init] autorelease];
        
        [connection setRootObject: [NSProtocolChecker protocolCheckerWithTarget:sessionManager protocol:@protocol(ObjclintSessionManagerProtocol)]];
        
        if(NO == [connection registerName:serviceName]) {
            printf("Failed to register local service\n");
            return 1;
        }
        
        [sessionManager clearSessionForProjectIdentity: projectIdentity];
        [sessionManager setLintJSValidatorsFolderPath:jsValidatorsFolder forProjectIdentity:projectIdentity];
        
        [connection addRunLoop:runLoop];

        while (1) {
            @autoreleasepool {
                NSDate* boundaryDate = [NSDate dateWithTimeInterval:1*60 sinceDate:[NSDate date]];
                [runLoop runMode:NSDefaultRunLoopMode beforeDate: boundaryDate];
                
                if([[NSDate date] timeIntervalSinceDate: sessionManager.lastActionDate] > 5*60)
                    break;
            }
        }
    }
    return 0;
}

