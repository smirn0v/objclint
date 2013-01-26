//
//  clang-utils.h
//  objclint
//
//  Created by Alexander Smirnov on 1/26/13.
//  Copyright (c) 2013 Alexander Smirnov. All rights reserved.
//

#ifndef objclint_clang_utils_h
#define objclint_clang_utils_h

#include <clang-c/Index.h>

#ifdef __cplusplus
extern "C" {
#endif

    const char* getTokenKindSpelling(CXTokenKind tokenKind);
    char* copyCursorFilePath(CXCursor cursor);
    
#ifdef __cplusplus
}
#endif

#endif
