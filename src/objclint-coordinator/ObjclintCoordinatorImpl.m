//
//  ObjclintCoordinatorImpl.m
//  objclint
//
//  Created by Alexander Smirnov on 12/9/12.
//  Copyright (c) 2012 Alexander Smirnov. All rights reserved.
//

#import "ObjclintCoordinatorImpl.h"
#import "ObjclintIssue.h"

// TODO: AOP for 'updateLastActionDate'.

@implementation ObjclintCoordinatorImpl {
    NSMutableDictionary* _sessionsByProject;
    NSMutableDictionary* _configurationByProject;
    NSMutableDictionary* _issuesByProject;
}

#pragma mark - Init&Dealloc

- (id)init {
    self = [super init];
    if (self) {
        _sessionsByProject               = @{}.mutableCopy;
        _configurationByProject          = @{}.mutableCopy;
        _issuesByProject                 = @{}.mutableCopy;
    }

    return self;
}

- (void)dealloc {
    
    [_lastActionDate                  release];
    [_sessionsByProject               release];
    [_configurationByProject          release];
    [_issuesByProject                 release];
    
    [super dealloc];
}

#pragma mark - ObjclintSessionManagerProtocol

- (void) clearSessionForProjectIdentity:(NSString*) projectIdentity {
    [self updateLastActionDate];
    
    if(!projectIdentity)
        return;

    [_sessionsByProject      removeObjectForKey: projectIdentity];
    [_configurationByProject removeObjectForKey: projectIdentity];
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

- (void) setConfiguration:(NSDictionary*) configuration forProjectIdentity:(NSString*) projectIdentity {
    [self updateLastActionDate];
    
    if(!configuration)
        return;
    
    _configurationByProject[projectIdentity] = configuration;
}

- (NSDictionary*) configurationForProjectIdentity:(NSString*) projectIdentity {
    [self updateLastActionDate];
    
    return _configurationByProject[projectIdentity];
}

- (void) reportIssue:(ObjclintIssue*) issue forProjectIdentity:(NSString*) projectIdentity {

    [self updateLastActionDate];

    if(!issue)
        return;
    
    NSMutableArray* issues = _issuesByProject[projectIdentity];
    if(!issues) {
        issues = [NSMutableArray array];
        _issuesByProject[projectIdentity] = issues;
    }
    
    ObjclintIssue* issueCopy = [[[ObjclintIssue alloc] initWithObjclintIssue: issue] autorelease];
    [issues addObject: issueCopy];
}

- (NSArray*) issuesForProjectIdentity:(NSString*) projectIdentity {
    return _issuesByProject[projectIdentity] ?: [NSArray array];
}

#pragma mark - Private

- (void) updateLastActionDate {
    [_lastActionDate autorelease];
    _lastActionDate = [[NSDate date] retain];
}

@end
