//
//  ObjCMethodDeclarationBinding.m
//  objclint
//
//  Created by Alexander Smirnov on 1/20/13.
//  Copyright (c) 2013 Alexander Smirnov. All rights reserved.
//

#import "ObjCMethodDeclarationBinding.h"
#import "DeclarationBinding+Protected.h"

#include "clang-cpp-api.h"

static JSClass objc_method_declaration_class = {
    .name        = "ObjCMethodDeclaration",
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

JSBool objc_method_declaration_is_synthesized(JSContext* context, uintN argc, jsval* parameters) {
    
    JSObject* declarationObject = JS_THIS_OBJECT(context, parameters);
    ObjCMethodDeclarationBinding* declarationBinding =
        (ObjCMethodDeclarationBinding*)JS_GetPrivate(context, declarationObject);
    clang::ObjCMethodDecl* declaration = (clang::ObjCMethodDecl*)[declarationBinding extractDeclarationFromJSObject: declarationObject];

    bool isSynthesized = declaration->isImplicit();
    JS_SET_RVAL(context, parameters, BOOLEAN_TO_JSVAL(isSynthesized));
    
    return JS_TRUE;
}

static JSFunctionSpec objc_method_declaration_methods[] = {
    JS_FS("isSynthesized", objc_method_declaration_is_synthesized,0,0),
    JS_FS("isImplicit", objc_method_declaration_is_synthesized,0,0),
    JS_FS_END
};

@implementation ObjCMethodDeclarationBinding

@synthesize bindings       = _bindings,
            jsClass        = _jsClass,
            jsFunctionSpec = _jsFunctionSpec,
            jsPrototype    = _jsPrototype;

#pragma mark - Init&Dealloc

- (id) initWithBindingsCollection:(ClangBindingsCollection*) collection {
    self = [super init];
    if (self) {
        _bindings = collection;
        
        _jsClass  = &objc_method_declaration_class;
        _jsFunctionSpec = objc_method_declaration_methods;
        
        NSAssert(_bindings.declarationBinding.jsPrototype, @"Declaration binding must be initialized before ObjCMethodDeclarationBinding");
        
        _jsPrototype = JS_InitClass(/* context       */ _bindings.context,
                                    /* global obj    */ JS_GetGlobalObject(_bindings.context),
                                    /* parent proto  */ _bindings.declarationBinding.jsPrototype,
                                    /* class         */ &objc_method_declaration_class,
                                    /* constructor   */ NULL,
                                    /* nargs         */ 0,
                                    /* property spec */ NULL,
                                    /* function spec */ objc_method_declaration_methods,
                                    /* static property spec */ NULL,
                                    /* static func spec     */ NULL);
        
        // not sure if must to, but it's definetely safer to 'retain' prototype here.
        // please correct me if we can ommit this.
        JS_AddNamedObjectRoot(_bindings.context, &_jsPrototype, "objc-declaration-prototype");
    }
    return self;
}

- (void)dealloc {
    JS_RemoveObjectRoot(_bindings.context, &_jsPrototype);
    _jsPrototype = NULL;
    [super dealloc];
}

#pragma mark - Public

- (JSObject*) declarationJSObjectFromCursor:(CXCursor) cursor {
    enum CXCursorKind cursorKind = clang_getCursorKind(cursor);
    bool methodDeclaration = cursorKind == CXCursor_ObjCInstanceMethodDecl ||
                             cursorKind == CXCursor_ObjCClassMethodDecl;
    
    if(!methodDeclaration)
        return NULL;

    clang::ObjCMethodDecl* methodDecl = (clang::ObjCMethodDecl *)cursor.data[0];
    
    JSObject* methodDeclJSObject = JS_NewObject(_bindings.context, _jsClass, _jsPrototype, NULL);
    
    [self storeDeclaration: methodDecl
              intoJSObject: methodDeclJSObject];
    
    return methodDeclJSObject;
}

#pragma mark - Private

@end
