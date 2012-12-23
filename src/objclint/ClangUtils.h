//
//  ClangUtils.h
//  objclint
//
//  Created by Smirnov on 12/23/12.
//  Copyright (c) 2012 Borsch Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <Index.h>

@class ClangSpellingLocation;

@interface ClangUtils : NSObject

+ (NSString*) projectPath;
+ (BOOL) locationBelongsToProject:(const CXSourceLocation*) location;
+ (ClangSpellingLocation*) spellingLocationForSourceLocation:(const CXSourceLocation*) location;

@end
