//
//  clang-js-utils.h
//  objclint
//
//  Created by Smirnov on 1/20/13.
//  Copyright (c) 2013 Borsch Lab. All rights reserved.
//

#ifndef objclint_clang_js_utils_h
#define objclint_clang_js_utils_h

#include <stdbool.h>
#include <clang-c/Index.h>

#define JS_NO_JSVAL_JSID_STRUCT_TYPES
#include "js/jsapi.h"

void setJSProperty_CXString(JSContext* context, JSObject* object, const char* propertyName, CXString string);
void setJSProperty_CString(JSContext* context, JSObject* object, const char* propertyName, const char* stringC);
void setJSProperty_UInt(JSContext* context, JSObject* object, const char* propertyName, unsigned int value);
void setJSProperty_Int(JSContext* context, JSObject* object, const char* propertyName, int value);
void setJSProperty_Bool(JSContext* context, JSObject* object, const char* propertyName, bool value);
void setJSProperty_Ptr(JSContext* context, JSObject* object, const char* propertyName, void* value);

#endif
