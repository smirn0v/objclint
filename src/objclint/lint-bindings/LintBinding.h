//
//  LintBinding.h
//  objclint
//
//  Created by Smirnov on 4/12/13.
//  Copyright (c) 2013 Alexander Smirnov. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "js.h"
#include <clang-c/Index.h>

@class ObjclintIssue;

@protocol LintBindingDelegate<NSObject>

- (void) lintObject:(JSObject*) lintObject issue:(ObjclintIssue*) issue;

- (CXCursor) cursorForLintObject:(JSObject*) lintObject;

@end

@interface LintBinding : NSObject

@property(nonatomic,readonly) JSContext* context;

@property(nonatomic,readonly) JSClass* jsClass;
@property(nonatomic,readonly) JSFunctionSpec* jsFunctionSpec;
@property(nonatomic,readonly) JSObject* jsPrototype;

@property(nonatomic,assign) id<LintBindingDelegate> delegate;

- (id) initWithContext:(JSContext*) context;

- (JSObject*) createLintObject;

@end
