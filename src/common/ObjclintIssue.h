//
//  ObjclintIssue.h
//  objclint
//
//  Created by Smirnov on 4/12/13.
//  Copyright (c) 2013 Alexander Smirnov. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ObjclintIssueType) {
    ObjclintIssueType_Warning,
    ObjclintIssueType_Error,
    ObjclintIssueType_JSError,
    ObjclintIssueType_Info
};

@interface ObjclintIssue : NSObject

@property(nonatomic, copy)   NSString*  fileName;
@property(nonatomic, assign) NSUInteger line;
@property(nonatomic, assign) NSUInteger column;
@property(nonatomic, assign) ObjclintIssueType issueType;
@property(nonatomic, copy)   NSString* description;

- (NSString*) issueTypeDescription;

@end
