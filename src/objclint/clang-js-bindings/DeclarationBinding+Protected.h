//
//  DeclarationBinding+Protected.h
//  objclint
//
//  Created by Alexander Smirnov on 1/21/13.
//  Copyright (c) 2013 Alexander Smirnov. All rights reserved.
//

#import "DeclarationBinding.h"

#include <clang-c/Index.h>

#define __STDC_LIMIT_MACROS
#define __STDC_CONSTANT_MACROS

#include <clang/AST/Decl.h>

@interface DeclarationBinding (Protected)

- (clang::Decl*) extractDeclarationFromJSObject:(JSObject*) object;
- (void) storeDeclaration:(clang::Decl*) declaration intoJSObject:(JSObject*) object;

@end
