//
//  JSEnvironment.h
//  objclint
//
//  Created by Smirnov on 4/16/13.
//  Copyright (c) 2013 Alexander Smirnov. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "js.h"

@class JSEnvironment;
@class JSError;

@protocol JSEnvironmentDelegate<NSObject>

- (void) JSEnvironment:(JSEnvironment*) env errorOccured:(JSError*) error;

@end

@interface JSEnvironment : NSObject

@property(nonatomic,readonly) JSContext* context;
@property(nonatomic,readonly) JSRuntime* runtime;
@property(nonatomic,readonly) JSObject*  global;
@property(nonatomic,assign) id<JSEnvironmentDelegate> delegate;

@end