//
//  ObjclintSessionManager.m
//  objclint
//
//  Created by Smirnov on 12/9/12.
//  Copyright (c) 2012 Borsch Lab. All rights reserved.
//

#import "ObjclintSessionManager.h"

@implementation ObjclintSessionManager {
    NSMutableDictionary* _sessionsByProject;
}

#pragma mark - Init&Dealloc

- (id)init {
    self = [super init];
    if (self) {
        _sessionsByProject = @{}.mutableCopy;
        NSLog(@"ObjclintSessionManager init");
    }

    return self;
}

- (void)dealloc {
    [_sessionsByProject release];
    [super dealloc];
}

#pragma mark - ObjclintSessionManagerProtocol

- (BOOL) checkIfLocation:(NSString*) location wasCheckedForProjectIdentity:(NSString*) projectIdentity {
    NSLog(@"check");
    if(!location)
        return NO;


    NSMutableSet* projectLocations = _sessionsByProject[projectIdentity];
    return [projectLocations containsObject: location];
}

- (void) markLocation:(NSString*) location checkedForProjectIdentity:(NSString*) projectIdentity {
    NSLog(@"mark");
    if(!location)
        return;

    NSMutableSet* projectLocations = _sessionsByProject[projectIdentity];

    if (!projectLocations) {
        projectLocations = [NSMutableSet set];
        _sessionsByProject[projectIdentity] = projectLocations;
    }

    [projectLocations addObject: location];
}

@end
