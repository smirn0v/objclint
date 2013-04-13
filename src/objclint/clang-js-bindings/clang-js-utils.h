//
//  clang-js-utils.h
//  objclint
//
//  Created by Alexander Smirnov on 1/20/13.
//  Copyright (c) 2013 Alexander Smirnov. All rights reserved.
//

#ifndef objclint_clang_js_utils_h
#define objclint_clang_js_utils_h

#include <stdbool.h>
#include <clang-c/Index.h>

#include "js.h"

#ifdef __cplusplus
extern "C" {
#endif

    void setJSProperty_CXString(JSContext* context, JSObject* object, const char* propertyName, CXString string);
    void setJSProperty_CString(JSContext* context, JSObject* object, const char* propertyName, const char* stringC);
    void setJSProperty_JSObject(JSContext* context, JSObject* object, const char* propertyName, JSObject* propertyObject);
    void setJSProperty_UInt(JSContext* context, JSObject* object, const char* propertyName, unsigned int value);
    void setJSProperty_Int(JSContext* context, JSObject* object, const char* propertyName, int value);
    void setJSProperty_Bool(JSContext* context, JSObject* object, const char* propertyName, bool value);
    void setJSProperty_Ptr(JSContext* context, JSObject* object, const char* propertyName, void* value);
    
#ifdef __cplusplus
}
#endif

#endif
