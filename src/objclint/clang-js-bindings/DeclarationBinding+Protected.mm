//
//  DeclarationBinding+Protected.m
//  objclint
//
//  Created by Alexander Smirnov on 1/21/13.
//  Copyright (c) 2013 Alexander Smirnov. All rights reserved.
//

#import "DeclarationBinding+Protected.h"

#include "clang-js-utils.h"

#include "js.h"

@implementation DeclarationBinding (Protected)

- (clang::Decl*) extractDeclarationFromJSObject:(JSObject*) object {
    jsval value;
    JS_GetProperty(self.bindings.context, object, "_declaration", &value);
    
    void* declaration = JSVAL_TO_PRIVATE(value);
    
    return (clang::Decl*)declaration;
}

- (void) storeDeclaration:(clang::Decl*) declaration intoJSObject:(JSObject*) object {
    setJSProperty_Ptr(self.bindings.context, object, "_declaration", (void*)declaration);
}

@end
