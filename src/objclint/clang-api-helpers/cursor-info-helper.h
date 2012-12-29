//
//  cursor-info-helper.h
//  objclint
//
//  Created by Smirnov on 12/29/12.
//  Copyright (c) 2012 Borsch Lab. All rights reserved.
//

#include <clang-c/Index.h>

#ifdef __cplusplus
extern "C" {
#endif

bool is_synthesized_method_decl(CXCursor cursor);
bool has_body(CXCursor cursor);

#ifdef __cplusplus
}
#endif