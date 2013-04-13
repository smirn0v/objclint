//
//  ClangBinding.h
//  objclint
//
//  Created by Alexander Smirnov on 1/20/13.
//  Copyright (c) 2013 Alexander Smirnov. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ClangBindingsCollection.h"

#include "js.h"

@protocol ClangBinding<NSObject>

- (id) initWithBindingsCollection:(ClangBindingsCollection*) collection;

@property(nonatomic,readonly) ClangBindingsCollection* bindings;
@property(nonatomic,readonly) JSClass* jsClass;
@property(nonatomic,readonly) JSFunctionSpec* jsFunctionSpec;
@property(nonatomic,readonly) JSObject* jsPrototype;


@end
