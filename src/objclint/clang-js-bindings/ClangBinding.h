//
//  ClangBinding.h
//  objclint
//
//  Created by Smirnov on 1/20/13.
//  Copyright (c) 2013 Borsch Lab. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ClangBindingsCollection.h"

#define JS_NO_JSVAL_JSID_STRUCT_TYPES
#include "js/jsapi.h"

@protocol ClangBinding<NSObject>

- (id) initWithBindingsCollection:(ClangBindingsCollection*) collection;

@property(nonatomic,readonly) JSClass* jsClass;
@property(nonatomic,readonly) JSFunctionSpec* jsFunctionSpec;
@property(nonatomic,readonly) JSObject* jsPrototype;


@end
