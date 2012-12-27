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
+ (NSString*) filePathForCursor:(CXCursor) cursor;
+ (BOOL) cursorBelongsToProject:(CXCursor) cursor;
+ (NSString*) cursorDescription:(CXCursor) cursor;
+ (NSString*) tokenKindDescription:(CXTokenKind) tokenKind;


@end
