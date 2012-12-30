//
//  cursor-info-helper.h
//  objclint
//
//  Created by Smirnov on 12/29/12.
//  Copyright (c) 2012 Borsch Lab. All rights reserved.
//

#include <clang-c/Index.h>

#define JS_NO_JSVAL_JSID_STRUCT_TYPES
#include "js/jsapi.h"

#ifdef __cplusplus
extern "C" {
#endif

    bool method_is_synthesized(CXCursor cursor);
    bool is_decl(CXCursor cursor);
    bool decl_has_body(CXCursor cursor);
    CXCursor cursor_from_jsobject(JSContext* cx, JSObject* object);
    void store_cursor_into_jsobject(CXCursor cursor, JSContext* cx, JSObject* object);
    

#ifdef __cplusplus
}
#endif