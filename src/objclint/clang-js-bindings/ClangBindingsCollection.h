//
//  ClangBindingsCollection.h
//  objclint
//
//  Created by Alexander Smirnov on 1/20/13.
//  Copyright (c) 2013 Alexander Smirnov. All rights reserved.
//

#import <Foundation/Foundation.h>

#define JS_NO_JSVAL_JSID_STRUCT_TYPES
#include "js/jsapi.h"

@class CursorBinding;
@class TokenBinding;
@class DeclarationBinding;
@class ObjCMethodDeclarationBinding;

@interface ClangBindingsCollection : NSObject

@property(nonatomic,readonly) JSContext* context;
@property(nonatomic,readonly) JSRuntime* runtime;

@property(nonatomic,readonly) CursorBinding* cursorBinding;
@property(nonatomic,readonly) TokenBinding* tokenBinding;
@property(nonatomic,readonly) DeclarationBinding* declarationBinding;
@property(nonatomic,readonly) ObjCMethodDeclarationBinding* objCMethodDeclarationBinding;

- (id) initWithContext:(JSContext*) context runtime:(JSRuntime*) runtime;

@end
