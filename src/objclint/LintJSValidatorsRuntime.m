//
//  JavaScriptSession.m
//  objclint
//
//  Created by Smirnov on 12/24/12.
//  Copyright (c) 2012 Borsch Lab. All rights reserved.
//

#import "JavaScriptSession.h"

@implementation LintJSValidatorsRuntime {
    NSArray* _validatorScriptFilePaths;
}

- (id) initWithLintsFolderPath:(NSString*) folderPath {
    self = [super init];
    if(self) {
        
    }
    return self;
}

- (LintJSValidatorsRuntime*) runtimeWithLintsFolderPath:(NSString*) folderPath {
    
}

- (void)dealloc
{
    [_validatorScriptFilePaths release];
    [super dealloc];
}

#pragma mark - Public


#pragma mark - Private


@end
