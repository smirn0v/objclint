//
//  ClangUtils.h
//  objclint
//
//  Created by Smirnov on 12/23/12.
//  Copyright (c) 2012 Borsch Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "clang-c/Index.h"

@class ClangSpellingLocation;

@interface ClangUtils : NSObject


+ (NSString*) filePathForCursor:(CXCursor) cursor;
+ (NSString*) tokenKindDescription:(CXTokenKind) tokenKind;


@end
