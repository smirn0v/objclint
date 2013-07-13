//
//  DeclarationBinding.m
//  objclint
//
//  Created by Alexander Smirnov on 1/20/13.
//  Copyright (c) 2013 Alexander Smirnov. All rights reserved.
//

#import "DeclarationBinding.h"
#import "DeclarationBinding+Protected.h"

#include "clang-js-utils.h"

static JSClass declaration_class = {
    .name        = "Declaration",
    .flags       = JSCLASS_HAS_PRIVATE,
    .addProperty = JS_PropertyStub,
    .delProperty = JS_PropertyStub,
    .getProperty = JS_PropertyStub,
    .setProperty = JS_StrictPropertyStub,
    .enumerate   = JS_EnumerateStub,
    .resolve     = JS_ResolveStub,
    .convert     = JS_ConvertStub,
    .finalize    = NULL,
    JSCLASS_NO_OPTIONAL_MEMBERS
};

JSBool declaration_has_body(JSContext* context, uintN argc, jsval* parameters) {

    JSObject* declarationObject = JS_THIS_OBJECT(context, parameters);
    DeclarationBinding* declarationBinding = (DeclarationBinding*)JS_GetPrivate(context, declarationObject);
    clang::Decl* declaration = [declarationBinding extractDeclarationFromJSObject: declarationObject];
    
    bool hasBody = declaration->hasBody();
    JS_SET_RVAL(context, parameters, BOOLEAN_TO_JSVAL(hasBody));
    
    return JS_TRUE;
}

static JSFunctionSpec declaration_methods[] = {
    JS_FS("hasBody", declaration_has_body,0,0),
    JS_FS_END
};

@implementation DeclarationBinding

@synthesize bindings       = _bindings,
            jsClass        = _jsClass,
            jsFunctionSpec = _jsFunctionSpec,
            jsPrototype    = _jsPrototype;

#pragma mark - Init&Dealloc

- (id) initWithBindingsCollection:(ClangBindingsCollection*) collection {
    self = [super init];
    if (self) {
        _bindings = collection;
        
        _jsClass  = &declaration_class;
        _jsFunctionSpec = declaration_methods;
        
        _jsPrototype = JS_InitClass(/* context       */ _bindings.context,
                                    /* global obj    */ JS_GetGlobalObject(_bindings.context),
                                    /* parent proto  */ NULL,
                                    /* class         */ &declaration_class,
                                    /* constructor   */ NULL,
                                    /* nargs         */ 0,
                                    /* property spec */ NULL,
                                    /* function spec */ declaration_methods,
                                    /* static property spec */ NULL,
                                    /* static func spec     */ NULL);
        
        // not sure if must to, but it's definetely safer to 'retain' prototype here.
        // please correct me if we can ommit this.
        JS_AddNamedObjectRoot(_bindings.context, &_jsPrototype, "declaration-prototype");
    }
    return self;
}

- (void)dealloc {
    JS_RemoveObjectRoot(_bindings.context, &_jsPrototype);
    [super dealloc];
}

#pragma mark - Public

#pragma mark - Private


@end
