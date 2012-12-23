//
//  main.m
//  objclint-coordinator
//
//  Created by Smirnov on 12/9/12.
//  Copyright (c) 2012 Borsch Lab. All rights reserved.
//

#import "ObjclintSessionManager.h"

int main(int argc, const char* argv[]) {
    @autoreleasepool {
        
        if(argc == 3 && strcmp(argv[1],"--drop-session") == 0) {
            NSString* projectPath = [NSString stringWithUTF8String:argv[2]];
            
            NSConnection* connection = [[NSConnection connectionWithRegisteredName: @"ru.borsch-lab.objclint.coordinator"
                                                                              host: nil] autorelease];
            
            [connection.rootProxy setProtocolForProxy:@protocol(ObjclintSessionManagerProtocol)];
            id<ObjclintSessionManagerProtocol> sessionManager = (id<ObjclintSessionManagerProtocol>) connection.rootProxy;
            
            [sessionManager clearSessionForProjectIdentity: projectPath];
            
            return 0;
        }

        NSRunLoop* runLoop = [NSRunLoop currentRunLoop];

        ObjclintSessionManager* root = [[ObjclintSessionManager new] autorelease];
        
        NSConnection* connection = [[[NSConnection alloc] init] autorelease];
        
        [connection setRootObject: [NSProtocolChecker protocolCheckerWithTarget:root protocol:@protocol(ObjclintSessionManagerProtocol)]];
        
        if(NO == [connection registerName:@"ru.borsch-lab.objclint.coordinator"]) {
            NSLog(@"failed to register local service");
            return 1;
        }
        
        [connection addRunLoop:runLoop];

        while (1) {
            @autoreleasepool {
                NSDate* boundaryDate = [NSDate dateWithTimeInterval:1*60 sinceDate:[NSDate date]];
                [runLoop runMode:NSDefaultRunLoopMode beforeDate: boundaryDate];
                
                if([[NSDate date] timeIntervalSinceDate: root.lastActionDate] > 5*60)
                    break;
            }
        }
    }
    return 0;
}

