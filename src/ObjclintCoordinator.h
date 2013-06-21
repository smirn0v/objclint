//
//  ObjclintCoordinator.h
//  objclint
//
//  Created by Alexander Smirnov on 12/9/12.
//  Copyright (c) 2012 Alexander Smirnov. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString* const kObjclintConfigurationLintsDirs = @"lints-directories";

@class ObjclintIssue;

@protocol ObjclintCoordinator <NSObject>

- (void) clearSessionForProjectIdentity:(NSString*) projectIdentity;

- (BOOL) checkIfLocation:(NSString*) location wasCheckedForProjectIdentity:(NSString*) projectIdentity;

- (void) markLocation:(NSString*) location checkedForProjectIdentity:(NSString*) projectIdentity;

- (void) setConfiguration:(NSDictionary*) configuration forProjectIdentity:(NSString*) projectIdentity;

- (NSDictionary*) configurationForProjectIdentity:(NSString*) projectIdentity;

- (void) reportIssue:(ObjclintIssue*) issue forProjectIdentity:(NSString*) projectIdentity;

- (NSArray*) issuesForProjectIdentity:(NSString*) projectIdentity;

@end
