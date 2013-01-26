//
//  clang-utils.c
//  objclint
//
//  Created by Alexander Smirnov on 1/26/13.
//  Copyright (c) 2013 Alexander Smirnov. All rights reserved.
//
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "clang-utils.h"

const char* getTokenKindSpelling(CXTokenKind tokenKind) {
    switch(tokenKind) {
        case CXToken_Punctuation : return "Punctuation";
        case CXToken_Keyword     : return "Keyword";
        case CXToken_Identifier  : return "Identifier";
        case CXToken_Literal     : return "Literal";
        case CXToken_Comment     : return "Comment";
    }
    return "<unknown token kind>";
}

char* copyCursorFilePath(CXCursor cursor) {
    CXSourceLocation location = clang_getCursorLocation(cursor);
    
    CXFile file;
    
    clang_getSpellingLocation(location,&file,NULL,NULL,NULL);
    
    CXString fileNameCX = clang_getFileName(file);
    const char* fileNameC = clang_getCString(fileNameCX);
    char* result = NULL;
    if(fileNameC){
        unsigned long length = strlen(fileNameC);
        result = (char*)malloc(length+1);
        memset(result, 0, length+1);
        strncpy(result, fileNameC, length);
    }
    
    clang_disposeString(fileNameCX);

    return result;
}