//
//  ClangSpellingLocation.m
//  objclint
//
//  Created by Smirnov on 12/23/12.
//  Copyright (c) 2012 Borsch Lab. All rights reserved.
//

#import "ClangSpellingLocation.h"

@implementation ClangSpellingLocation

- (void)dealloc
{
    [_filePath release];
    [super dealloc];
}

- (NSString*) description {
    
    NSMutableString* locationDescription = [NSMutableString string];
    [locationDescription appendFormat:@"clang-location-%@-", _filePath];
    [locationDescription appendFormat:@"%u-%u-%u",_line,_column,_offset];
    
    return locationDescription;
}

@end
