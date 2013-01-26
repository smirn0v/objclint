//
//  CursorBinding.h
//  objclint
//
//  Created by Alexander Smirnov on 1/20/13.
//  Copyright (c) 2013 Alexander Smirnov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ClangBinding.h"

#include <clang-c/Index.h>

@interface CursorBinding : NSObject<ClangBinding>

- (CXCursor) cursorFromJSObject:(JSObject*) object;
- (JSObject*) JSObjectFromCursor:(CXCursor) cursor;

@end
