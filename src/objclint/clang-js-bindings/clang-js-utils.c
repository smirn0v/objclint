//
//  clang-js-utils.c
//  objclint
//
//  Created by Alexander Smirnov on 1/20/13.
//  Copyright (c) 2013 Alexander Smirnov. All rights reserved.
//

#include "clang-js-utils.h"

void setJSProperty_CXString(JSContext* context, JSObject* object, const char* propertyName, CXString string) {
    //REDO: leak ?
    const char* stringC = clang_getCString(string);
    
    JSString* jsString = JS_NewStringCopyZ(context, stringC);
    jsval value = STRING_TO_JSVAL(jsString);
    
    JS_SetProperty(context, object, propertyName, &value);
}

void setJSProperty_CString(JSContext* context, JSObject* object, const char* propertyName, const char* stringC) {
    //REDO: leak ?
    JSString* jsString = JS_NewStringCopyZ(context, stringC);
    jsval value = STRING_TO_JSVAL(jsString);
    
    JS_SetProperty(context, object, propertyName, &value);
}

void setJSProperty_JSObject(JSContext* context, JSObject* object, const char* propertyName, JSObject* propertyObject) {
    jsval value = OBJECT_TO_JSVAL(propertyObject);
    JS_SetProperty(context, object, propertyName, &value);
}

#define $set_primitive(func_name)\
jsval jsValue   = func_name(value); \
JS_SetProperty(context, object, propertyName, &jsValue);

void setJSProperty_UInt(JSContext* context, JSObject* object, const char* propertyName, unsigned int value) {
    $set_primitive(UINT_TO_JSVAL);
}

void setJSProperty_Int(JSContext* context, JSObject* object, const char* propertyName, int value) {
    $set_primitive(INT_TO_JSVAL);
}

void setJSProperty_Bool(JSContext* context, JSObject* object, const char* propertyName, bool value) {
    $set_primitive(BOOLEAN_TO_JSVAL);
}

void setJSProperty_Ptr(JSContext* context, JSObject* object, const char* propertyName, void* value) {
    $set_primitive(PRIVATE_TO_JSVAL);
}

#undef $set_primitive