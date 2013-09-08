//
//  ClangBindingsCollection.m
//  objclint
//
//  Created by Alexander Smirnov on 1/20/13.
//  Copyright (c) 2013 Alexander Smirnov. All rights reserved.
//
#import "ClangBindings.h"

@implementation ClangBindingsCollection

#pragma mark - Init&Dealloc

- (id) initWithContext:(JSContext*) context{
    self = [super init];
    if (self) {
        _context = context;
        
        _cursorBinding      = [[CursorBinding alloc] initWithBindingsCollection: self];
        _tokenBinding       = [[TokenBinding alloc] initWithBindingsCollection: self];
        _declarationBinding = [[DeclarationBinding alloc] initWithBindingsCollection: self];
        _objCMethodDeclarationBinding   = [[ObjCMethodDeclarationBinding alloc] initWithBindingsCollection: self];
        _objCPropertyDeclarationBinding = [[ObjCPropertyDeclarationBinding alloc] initWithBindingsCollection: self];
    }
    return self;
}

- (void)dealloc {
    [_cursorBinding                  release];
    [_tokenBinding                   release];
    [_declarationBinding             release];
    [_objCMethodDeclarationBinding   release];
    [_objCPropertyDeclarationBinding release];
    [super dealloc];
}

#pragma mark - Public

#pragma mark - Private

@end
