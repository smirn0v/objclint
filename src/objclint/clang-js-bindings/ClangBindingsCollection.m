//
//  ClangBindingsCollection.m
//  objclint
//
//  Created by Smirnov on 1/20/13.
//  Copyright (c) 2013 Borsch Lab. All rights reserved.
//

#import "ClangBindingsCollection.h"

@implementation ClangBindingsCollection

#pragma mark - Init&Dealloc

- (id) initWithContext:(JSContext*) context runtime:(JSRuntime*) runtime {
    self = [super init];
    if (self) {
        _context = context;
        _runtime = runtime;
    }
    return self;
}

#pragma mark - Public

#pragma mark - Private

@end
