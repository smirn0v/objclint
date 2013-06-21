//
//  ObjclintIssue.m
//  objclint
//
//  Created by Smirnov on 4/12/13.
//  Copyright (c) 2013 Alexander Smirnov. All rights reserved.
//

#import "ObjclintIssue.h"

@implementation ObjclintIssue

#pragma mark - Init&Dealloc

- (void)dealloc
{
    [_fileName    release];
    [_description release];
    [super dealloc];
}

#pragma mark - Public

- (NSString*) issueTypeDescription {
    static NSDictionary* issueTypes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        issueTypes = @{
                       @(ObjclintIssueType_Error):   @"Error",
                       @(ObjclintIssueType_Info):    @"Info",
                       @(ObjclintIssueType_JSError): @"JSError",
                       @(ObjclintIssueType_Warning): @"Warning"
                    };
        [issueTypes retain];
    });
    
    return issueTypes[@(_issueType)]?:@"<Unknown issue type>";
}

@end
