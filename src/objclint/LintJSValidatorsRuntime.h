//
//  LintJSValidatorsRuntime.h
//  objclint
//
//  Created by Smirnov on 12/24/12.
//  Copyright (c) 2012 Borsch Lab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LintJSValidatorsRuntime : NSObject

- (id) initWithLintsFolderPath:(NSString*) folderPath;
+ (LintJSValidatorsRuntime*) runtimeWithLintsFolderPath:(NSString*) folderPath;

- (void) runValidators;

@end
