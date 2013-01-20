//
//  DeclarationBinding+Protected.m
//  objclint
//
//  Created by Smirnov on 1/21/13.
//  Copyright (c) 2013 Borsch Lab. All rights reserved.
//

#import "DeclarationBinding+Protected.h"

#define JS_NO_JSVAL_JSID_STRUCT_TYPES
#include "js/jsapi.h"

@implementation DeclarationBinding (Protected)

- (clang::Decl*) extractDeclarationFromJSObject:(JSObject*) object {
    jsval value;
    JS_GetProperty(_bindings.context, object, "_declaration", &value);
    
    void* declaration = JSVAL_TO_PRIVATE(value);
    
    return declaration;
}

- (void) storeDeclaration:(clang::Decl*) declaration intoJSObject:(JSObject*) object {
    setJSProperty_Ptr(_bindings.context, object, "_declaration", (void*)declaration);
}

@end
