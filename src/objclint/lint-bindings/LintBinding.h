//
//  LintBinding.h
//  objclint
//
//  Created by Smirnov on 4/12/13.
//  Copyright (c) 2013 Alexander Smirnov. All rights reserved.
//

#import <Foundation/Foundation.h>

#define JS_NO_JSVAL_JSID_STRUCT_TYPES
#include "js/jsapi.h"

@protocol LintBindingDelegate<NSObject>

- (void) lintObject:(JSObject*) lintObject errorReport:(NSString*) errorDescription;
- (void) lintObject:(JSObject*) lintObject warningReport:(NSString*) warningDescription;
- (void) lintObject:(JSObject*) lintObject infoReport:(NSString*) infoReport;

@end

@interface LintBinding : NSObject

@property(nonatomic,readonly) JSContext* context;
@property(nonatomic,readonly) JSRuntime* runtime;

@property(nonatomic,readonly) JSClass* jsClass;
@property(nonatomic,readonly) JSFunctionSpec* jsFunctionSpec;
@property(nonatomic,readonly) JSObject* jsPrototype;

@property(nonatomic,assign) id<LintBindingDelegate> delegate;

- (id) initWithContext:(JSContext*) context runtime:(JSRuntime*) runtime;

- (JSObject*) createLintObject;

@end
