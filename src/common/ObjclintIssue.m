//
//  ObjclintIssue.m
//  objclint
//
//  Created by Smirnov on 4/12/13.
//  Copyright (c) 2013 Alexander Smirnov. All rights reserved.
//

#import "ObjclintIssue.h"

@implementation ObjclintIssue

- (void)dealloc
{
    [_filePath    release];
    [_description release];
    [super dealloc];
}

@end
