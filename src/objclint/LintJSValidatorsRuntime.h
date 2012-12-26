//
//  LintJSValidatorsRuntime.h
//  objclint
//
//  Created by Smirnov on 12/24/12.
//  Copyright (c) 2012 Borsch Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <Index.h>

@interface LintJSValidatorsRuntime : NSObject {
@public
    CXCursor _cursor;
    BOOL     _errorsOccured;
}

@property(nonatomic, readonly) BOOL errorsOccured;

- (id) initWithLintsFolderPath:(NSString*) folderPath;
+ (LintJSValidatorsRuntime*) runtimeWithLintsFolderPath:(NSString*) folderPath;

- (void) runValidatorsForCursor:(CXCursor) cursor;

@end
