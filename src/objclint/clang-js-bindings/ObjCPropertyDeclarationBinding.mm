//
//  ObjCPropertyDeclarationBinding.m
//  objclint
//
//  Created by Александр Смирнов on 9/8/13.
//  Copyright (c) 2013 Alexander Smirnov. All rights reserved.
//

#import "ObjCPropertyDeclarationBinding.h"
#import "DeclarationBinding+Internal.h"

#include "clang-cpp-api.h"

static JSClass objc_property_declaration_class = {
    .name        = "ObjCPropertyDeclaration",
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

#define $extract_declaration\
    JSObject* declarationObject = JS_THIS_OBJECT(context, parameters);\
    clang::ObjCPropertyDecl* declaration = NULL;\
    declaration = (clang::ObjCPropertyDecl*)[DeclarationBinding extractDeclarationFromJSObject: declarationObject\
                                                                                     inContext: context];

JSBool objc_property_declaration_is_read_only(JSContext* context, uintN argc, jsval* parameters) {
    $extract_declaration;
    
    bool isReadOnly = declaration->isReadOnly();
    
    JS_SET_RVAL(context, parameters, BOOLEAN_TO_JSVAL(isReadOnly));
    
    return JS_TRUE;
}

JSBool objc_property_declaration_is_atomic(JSContext* context, uintN argc, jsval* parameters) {
    $extract_declaration;
    
    bool isAtomic = declaration->isAtomic();
    
    JS_SET_RVAL(context, parameters, BOOLEAN_TO_JSVAL(isAtomic));
    
    return JS_TRUE;
}

JSBool objc_property_declaration_is_retaining(JSContext* context, uintN argc, jsval* parameters) {
    $extract_declaration;
    
    bool isRetaining = declaration->isRetaining();
    
    JS_SET_RVAL(context, parameters, BOOLEAN_TO_JSVAL(isRetaining));
    
    return JS_TRUE;
}

void set_rval_for_string(JSContext* context, uintN argc, jsval* parameters, const std::string& str) {    
    JSString* nameJSStr = JS_NewStringCopyZ(context, str.c_str());
    JS_SET_RVAL(context, parameters, STRING_TO_JSVAL(nameJSStr));
}

JSBool objc_property_declaration_get_getter_name(JSContext* context, uintN argc, jsval* parameters) {
    $extract_declaration;
    
    set_rval_for_string(context, argc, parameters, declaration->getGetterName().getAsString());

    return JS_TRUE;
}

JSBool objc_property_declaration_get_setter_name(JSContext* context, uintN argc, jsval* parameters) {
    $extract_declaration;
    
    set_rval_for_string(context, argc, parameters, declaration->getSetterName().getAsString());
    
    return JS_TRUE;
}

void set_rval_for_meth_decl(JSContext* context, uintN argc, jsval* parameters, clang::ObjCMethodDecl* methodDecl) {
    JSObject* objcPropertyDeclJSObj = JS_THIS_OBJECT(context, parameters);
    ObjCPropertyDeclarationBinding* propertyDeclBinding = nil;
    propertyDeclBinding = (ObjCPropertyDeclarationBinding*) JS_GetPrivate(context, objcPropertyDeclJSObj);
    
    JSObject* methodDeclJSObject = JS_NewObject(context, propertyDeclBinding.jsClass, propertyDeclBinding.jsPrototype, NULL);
    
    [DeclarationBinding storeDeclaration: methodDecl
                            intoJSObject: methodDeclJSObject
                               inContext: context];
    
    JS_SET_RVAL(context, parameters, OBJECT_TO_JSVAL(methodDeclJSObject));
}

JSBool objc_property_declaration_get_getter_method_decl(JSContext* context, uintN argc, jsval* parameters) {
    $extract_declaration;
    
    set_rval_for_meth_decl(context, argc, parameters, declaration->getGetterMethodDecl());
    
    return JS_TRUE;
}

JSBool objc_property_declaration_get_setter_method_decl(JSContext* context, uintN argc, jsval* parameters) {
    $extract_declaration;
    
    set_rval_for_meth_decl(context, argc, parameters, declaration->getSetterMethodDecl());
    
    return JS_TRUE;
}

static JSFunctionSpec objc_property_declaration_methods[] = {
    JS_FS("isReadOnly",  objc_property_declaration_is_read_only,0,0),
    JS_FS("isAtomic",    objc_property_declaration_is_atomic,0,0),
    JS_FS("isRetaining", objc_property_declaration_is_retaining,0,0),
    JS_FS("getGetterName", objc_property_declaration_get_getter_name,0,0),
    JS_FS("getSetterName", objc_property_declaration_get_setter_name,0,0),
    JS_FS("getGetterMethodDecl", objc_property_declaration_get_getter_method_decl,0,0),
    JS_FS("getSetterMethodDecl", objc_property_declaration_get_setter_method_decl,0,0),
    JS_FS_END
};

@implementation ObjCPropertyDeclarationBinding

@synthesize bindings       = _bindings,
            jsClass        = _jsClass,
            jsFunctionSpec = _jsFunctionSpec,
            jsPrototype    = _jsPrototype;

#pragma mark Init&Dealloc

- (id) initWithBindingsCollection:(ClangBindingsCollection*) collection {
    self = [super init];
    if (self) {
        _bindings = collection;
        
        _jsClass  = &objc_property_declaration_class;
        _jsFunctionSpec = objc_property_declaration_methods;
        
        _jsPrototype = JS_InitClass(/* context       */ _bindings.context,
                                    /* global obj    */ JS_GetGlobalObject(_bindings.context),
                                    /* parent proto  */ NULL,
                                    /* class         */ &objc_property_declaration_class,
                                    /* constructor   */ NULL,
                                    /* nargs         */ 0,
                                    /* property spec */ NULL,
                                    /* function spec */ objc_property_declaration_methods,
                                    /* static property spec */ NULL,
                                    /* static func spec     */ NULL);
        
        // not sure if must to, but it's definetely safer to 'retain' prototype here.
        // please correct me if we can ommit this.
        JS_AddNamedObjectRoot(_bindings.context, &_jsPrototype, "objc-property-declaration-prototype");
    }
    return self;
}

- (void)dealloc {
    JS_RemoveObjectRoot(_bindings.context, &_jsPrototype);
    [super dealloc];
}

#pragma mark - Public

- (JSObject*) declarationJSObjectFromCursor:(CXCursor) cursor {
    enum CXCursorKind cursorKind = clang_getCursorKind(cursor);
    bool propertyDeclaration = CXCursor_ObjCPropertyDecl == cursorKind;
    
    if(!propertyDeclaration)
        return NULL;
    
    clang::ObjCPropertyDecl* propertyDecl = (clang::ObjCPropertyDecl *)cursor.data[0];
    
    JSObject* propertyDeclJSObject = JS_NewObject(_bindings.context, _jsClass, _jsPrototype, NULL);
    
    [DeclarationBinding storeDeclaration: propertyDecl
                            intoJSObject: propertyDeclJSObject
                               inContext: _bindings.context];
    
    JS_SetPrivate(_bindings.context, propertyDeclJSObject, self);
    
    return propertyDeclJSObject;
}

@end
