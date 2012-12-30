//
//  cursor-info-helper.m
//  objclint
//
//  Created by Smirnov on 12/29/12.
//  Copyright (c) 2012 Borsch Lab. All rights reserved.
//

#import "cursor-info-helper.h"

#define __STDC_LIMIT_MACROS
#define __STDC_CONSTANT_MACROS

#include <clang/AST/DeclObjC.h>
#include <clang/AST/StmtObjC.h>
#include <clang/AST/Stmt.h>
#include <clang/AST/ExprObjC.h>

extern "C" {
    
    bool method_is_synthesized(CXCursor cursor) {
        enum CXCursorKind cursorKind = clang_getCursorKind(cursor);
        bool methodDeclaration = cursorKind == CXCursor_ObjCInstanceMethodDecl ||
                                 cursorKind == CXCursor_ObjCClassMethodDecl;

        if(false == methodDeclaration)
            return false;
        
        if(methodDeclaration) {
            clang::ObjCMethodDecl* methodDecl = (clang::ObjCMethodDecl *)cursor.data[0];
            return methodDecl->isSynthesized();
        }
    }

    bool is_decl(CXCursor cursor) {
        return clang_isDeclaration(clang_getCursorKind(cursor));
    }

    bool decl_has_body(CXCursor cursor) {
        if(!is_decl(cursor))
           return false;
        
        clang::Decl* decl = (clang::Decl*)cursor.data[0];
        
        return decl->hasBody();
    }
    
    CXCursor cursor_from_jsobject(JSContext* cx, JSObject* object) {
        CXCursor cursorObj;
        
        jsval value;
        JS_GetProperty(cx, object, "_kind", &value);
        cursorObj.kind  = (CXCursorKind)JSVAL_TO_INT(value);
        
        JS_GetProperty(cx, object, "_xdata", &value);
        cursorObj.xdata = JSVAL_TO_INT(value);
        
        JS_GetProperty(cx, object, "_data0", &value);
        cursorObj.data[0] = JSVAL_TO_PRIVATE(value);
        JS_GetProperty(cx, object, "_data1", &value);
        cursorObj.data[1] = JSVAL_TO_PRIVATE(value);
        JS_GetProperty(cx, object, "_data2", &value);
        cursorObj.data[2] = JSVAL_TO_PRIVATE(value);
        
        return cursorObj;
    }
    
    void store_cursor_into_jsobject(CXCursor cursor, JSContext* cx, JSObject* object) {
        jsval internalKindVal = INT_TO_JSVAL(cursor.kind);
        JS_SetProperty(cx, object, "_kind", &internalKindVal);
        
        jsval internalXDataVal = INT_TO_JSVAL(cursor.xdata);
        JS_SetProperty(cx, object, "_xdata", &internalXDataVal);
        
        jsval internalDataVal = PRIVATE_TO_JSVAL(cursor.data[0]);
        JS_SetProperty(cx, object, "_data0", &internalDataVal);
        internalDataVal = PRIVATE_TO_JSVAL(cursor.data[1]);
        JS_SetProperty(cx, object, "_data1", &internalDataVal);
        internalDataVal = PRIVATE_TO_JSVAL(cursor.data[2]);
        JS_SetProperty(cx, object, "_data2", &internalDataVal);
    }
    
}


