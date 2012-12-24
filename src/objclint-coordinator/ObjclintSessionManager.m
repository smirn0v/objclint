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
    NSMutableDictionary* _validatorsFolderPathForProject;
}

#pragma mark - Init&Dealloc

- (id)init {
    self = [super init];
    if (self) {
        _sessionsByProject = @{}.mutableCopy;
        _validatorsFolderPathForProject = @{}.mutableCopy;
    }

    return self;
}

- (void)dealloc {
    [_lastActionDate release];
    [_sessionsByProject release];
    [_validatorsFolderPathForProject release];
    [super dealloc];
}

#pragma mark - ObjclintSessionManagerProtocol

- (void) clearSessionForProjectIdentity:(NSString*) projectIdentity {
    [self updateLastActionDate];
    
    if(!projectIdentity)
        return;

    [_sessionsByProject removeObjectForKey: projectIdentity];
}

- (void) setLintJSValidatorsFolderPath:(NSString*) folderPath forProjectIdentity:(NSString*) projectIdentity {
    [self updateLastActionDate];
    
    if(!projectIdentity)
        return;
    
    if(folderPath)
        _validatorsFolderPathForProject[projectIdentity] = folderPath;
}

- (BOOL) checkIfLocation:(NSString*) location wasCheckedForProjectIdentity:(NSString*) projectIdentity {
    [self updateLastActionDate];
    
    if(!location)
        return NO;

    NSMutableSet* projectLocations = _sessionsByProject[projectIdentity];
    return [projectLocations containsObject: location];
}

- (void) markLocation:(NSString*) location checkedForProjectIdentity:(NSString*) projectIdentity {
    [self updateLastActionDate];
    
    if(!location)
        return;

    NSMutableSet* projectLocations = _sessionsByProject[projectIdentity];

    if (!projectLocations) {
        projectLocations = [NSMutableSet set];
        _sessionsByProject[projectIdentity] = projectLocations;
    }

    [projectLocations addObject: location];
}

#pragma mark - Private

- (void) updateLastActionDate {
    [_lastActionDate autorelease];
    _lastActionDate = [[NSDate date] retain];
}

@end
