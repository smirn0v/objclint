//
//  DeclarationBinding+Protected.m
//  objclint
//
//  Created by Alexander Smirnov on 1/21/13.
//  Copyright (c) 2013 Alexander Smirnov. All rights reserved.
//

#import "DeclarationBinding+Internal.h"

#include "clang-js-utils.h"

#include "js.h"

@implementation DeclarationBinding (Internal)

+ (clang::Decl*) extractDeclarationFromJSObject:(JSObject*) object inContext:(JSContext*) context {
    jsval value;
    JS_GetProperty(context, object, "_declaration", &value);
    
    void* declaration = JSVAL_TO_PRIVATE(value);
    
    return (clang::Decl*)declaration;
}

+ (void) storeDeclaration:(clang::Decl*) declaration intoJSObject:(JSObject*) object inContext:(JSContext*) context {
    setJSProperty_Ptr(context, object, "_declaration", (void*)declaration);
}

@end
