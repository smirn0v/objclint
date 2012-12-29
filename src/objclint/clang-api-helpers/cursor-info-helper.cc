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

extern "C" {
    
bool is_synthesized_method_decl(CXCursor cursor) {
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
    
bool has_body(CXCursor cursor) {
    if(!clang_isDeclaration(clang_getCursorKind(cursor)))
       return false;
    clang::Decl* decl = (clang::Decl*)cursor.data[0];
    
    return decl->hasBody();
}
    
}


