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

- (instancetype) initWithObjclintIssue:(ObjclintIssue*) issue {
    if(self = [super init]) {
        _fileName    = issue.fileName.copy;
        _line        = issue.line;
        _column      = issue.column;
        _issueType   = issue.issueType;
        _description = issue.description.copy;
    }
    return self;
}

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

#pragma mark - NSCopying

-(id)copyWithZone:(NSZone*)zone {
    ObjclintIssue *issueCopy = [[[self class] allocWithZone: zone] initWithObjclintIssue: self];
    return issueCopy;
}

@end
