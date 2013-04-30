//
//  JSScriptsLoader.h
//  objclint
//
//  Created by Smirnov on 4/13/13.
//  Copyright (c) 2013 Alexander Smirnov. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "js.h"

@interface JSScriptsLoader : NSObject

- (instancetype) initWithContext:(JSContext*) context
                   scriptsFolder:(NSString*) folder;

- (void) runScriptsWithResultHandler:(void(^)(jsval))handler;

@end
