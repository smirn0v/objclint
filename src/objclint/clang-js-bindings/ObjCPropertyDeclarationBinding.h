//
//  ObjCPropertyDeclarationBinding.h
//  objclint
//
//  Created by Александр Смирнов on 9/8/13.
//  Copyright (c) 2013 Alexander Smirnov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ClangBinding.h"
#import "DeclarationBinding.h"

#include <clang-c/Index.h>

@interface ObjCPropertyDeclarationBinding : NSObject<ClangBinding>

- (JSObject*) declarationJSObjectFromCursor:(CXCursor) cursor;

@end
