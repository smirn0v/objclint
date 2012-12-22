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

        NSRunLoop* runLoop = [NSRunLoop currentRunLoop];

        id<ObjclintSessionManagerProtocol> root = [[ObjclintSessionManager new] autorelease];
        
        NSConnection* connection = [[[NSConnection alloc] init] autorelease];
        
        [connection setRootObject: [NSProtocolChecker protocolCheckerWithTarget:root protocol:@protocol(ObjclintSessionManagerProtocol)]];
        
        if(NO == [connection registerName:@"ru.borsch-lab.objclint.coordinator"]) {
            NSLog(@"failed to register local service");
            return 1;
        }
        
        [connection addRunLoop:runLoop];

        while (1) {
            [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
    }
    return 0;
}

