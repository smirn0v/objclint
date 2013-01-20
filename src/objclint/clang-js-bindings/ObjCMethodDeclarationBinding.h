//
//  ObjCMethodDeclarationBinding.h
//  objclint
//
//  Created by Smirnov on 1/20/13.
//  Copyright (c) 2013 Borsch Lab. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DeclarationBinding.h"

#include <clang-c/Index.h>

@interface ObjCMethodDeclarationBinding : DeclarationBinding

- (JSObject*) declarationJSObjectFromCursor:(CXCursor) cursor;

@end
