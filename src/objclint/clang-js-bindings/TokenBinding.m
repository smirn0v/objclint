//
//  TokenBinding.m
//  objclint
//
//  Created by Smirnov on 1/20/13.
//  Copyright (c) 2013 Borsch Lab. All rights reserved.
//

#import "TokenBinding.h"

@implementation TokenBinding

@synthesize jsClass, jsFunctionSpec, jsPrototype;

- (id) initWithBindingsCollection:(ClangBindingsCollection*) collection {
    self = [super init];
    if (self) {
        
    }
    return self;
}

@end
