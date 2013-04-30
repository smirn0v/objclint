//
//  JSError.m
//  objclint
//
//  Created by Smirnov on 4/16/13.
//  Copyright (c) 2013 Alexander Smirnov. All rights reserved.
//

#import "JSError.h"

@implementation JSError

- (void)dealloc
{
    [_filename release];
    [_message  release];
    [super dealloc];
}

@end
