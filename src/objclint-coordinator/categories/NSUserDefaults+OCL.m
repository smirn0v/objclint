//
//  NSUserDefaults+OCL.m
//  objclint
//
//  Created by Alexander Smirnov on 6/21/13.
//  Copyright (c) 2013 Alexander Smirnov. All rights reserved.
//

#import "NSUserDefaults+OCL.h"

@implementation NSUserDefaults (OCL)

- (id) objectForKeyedSubscript:(id) key {
    if(NO == [key isKindOfClass:[NSString class]])
        return nil;
    return [self objectForKey: key];
}

@end
