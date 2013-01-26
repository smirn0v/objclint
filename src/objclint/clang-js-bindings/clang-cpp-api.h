//
//  clang-cpp-api.h
//  objclint
//
//  Created by Smirnov on 1/27/13.
//  Copyright (c) 2013 Alexander Smirnov. All rights reserved.
//

#ifndef objclint_clang_cpp_api_h
#define objclint_clang_cpp_api_h

#undef IBAction
#undef IBOutlet
#define __STDC_LIMIT_MACROS
#define __STDC_CONSTANT_MACROS

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wshorten-64-to-32"

#include <clang/AST/Decl.h>
#include <clang/AST/DeclObjC.h>

#pragma clang diagnostic pop

#endif