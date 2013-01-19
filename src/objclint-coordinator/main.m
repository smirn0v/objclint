//
//  main.m
//  objclint-coordinator
//
//  Created by Smirnov on 12/9/12.
//  Copyright (c) 2012 Borsch Lab. All rights reserved.
//

#import "ObjclintCoordinatorImpl.h"
#include <stdlib.h>

static NSString* serviceName = @"ru.borsch-lab.objclint.coordinator";

BOOL setupExistingCoordinator(BOOL check, NSString* projectIdentity, NSString* jsValidatorsFolder) {
    NSConnection* existingCoordinatorConnection = [[NSConnection connectionWithRegisteredName: serviceName
                                                                                         host: nil] autorelease];
    
    [existingCoordinatorConnection.rootProxy setProtocolForProxy:@protocol(ObjclintCoordinator)];
    id<ObjclintCoordinator> coordinator = (id<ObjclintCoordinator>) existingCoordinatorConnection.rootProxy;
    
    if(NO == check) {
        [coordinator clearSessionForProjectIdentity: projectIdentity];
        [coordinator setLintJSValidatorsFolderPath: jsValidatorsFolder forProjectIdentity:projectIdentity];
    }
    
    return existingCoordinatorConnection != nil;
}

int main(int argc, const char* argv[]) {
    @autoreleasepool {
        
        BOOL justCheck = argc==2 && strcmp(argv[1],"--check") == 0;

        NSString* projectIdentity = [[NSFileManager defaultManager] currentDirectoryPath];
        NSString* jsValidatorsFolder = @"/opt/local/share/objclint-validators";
        //TODO: support for '.objclint' configuration for validators folder
        
        if(setupExistingCoordinator(justCheck, projectIdentity, jsValidatorsFolder)) {
            if(justCheck)
                printf("...%s started...\n",argv[0]);
            else
                printf("connected to existing %s, prepared for new session\n", argv[0]);
            return 0;
        } else if(justCheck) {
            //TODO: support for daemonization instead of '--check'
            return 1;
        }

        NSRunLoop* runLoop = [NSRunLoop currentRunLoop];

        ObjclintCoordinatorImpl* coordinator = [[ObjclintCoordinatorImpl new] autorelease];
        
        NSConnection* connection = [[[NSConnection alloc] init] autorelease];
        
        [connection setRootObject: [NSProtocolChecker protocolCheckerWithTarget:coordinator protocol:@protocol(ObjclintCoordinator)]];
        
        if(NO == [connection registerName:serviceName]) {
            printf("failed to register local service\n");
            return 1;
        }
        
        [coordinator clearSessionForProjectIdentity: projectIdentity];
        [coordinator setLintJSValidatorsFolderPath:jsValidatorsFolder forProjectIdentity:projectIdentity];
        
        [connection addRunLoop:runLoop];

        while (1) {
            @autoreleasepool {
                NSDate* boundaryDate = [NSDate dateWithTimeInterval:1*60 sinceDate:[NSDate date]];
                [runLoop runMode:NSDefaultRunLoopMode beforeDate: boundaryDate];
                
                if([[NSDate date] timeIntervalSinceDate: coordinator.lastActionDate] > 5*60)
                    break;
            }
        }
    }
    return 0;
}

