//
//  DeclarationBinding+Protected.h
//  objclint
//
//  Created by Alexander Smirnov on 1/21/13.
//  Copyright (c) 2013 Alexander Smirnov. All rights reserved.
//

#import "DeclarationBinding.h"

#include <clang-c/Index.h>
#include "clang-cpp-api.h"

@interface DeclarationBinding (Internal)

+ (clang::Decl*) extractDeclarationFromJSObject:(JSObject*) object inContext:(JSContext*) context;
+ (void) storeDeclaration:(clang::Decl*) declaration intoJSObject:(JSObject*) object inContext:(JSContext*) context;

@end

