//
//  TokenBinding.h
//  objclint
//
//  Created by Alexander Smirnov on 1/20/13.
//  Copyright (c) 2013 Alexander Smirnov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ClangBinding.h"

#include <clang-c/Index.h>

@interface TokenBinding : NSObject<ClangBinding>

- (JSObject*) tokensJSArrayFromCursor:(CXCursor) cursor;
- (JSObject*) JSObjectFromToken:(CXToken) token cursor:(CXCursor) cursor;

@end
