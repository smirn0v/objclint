//
//  JSValidatorsRunner.h
//  objclint
//
//  Created by Alexander Smirnov on 12/24/12.
//  Copyright (c) 2012 Alexander Smirnov. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "clang-c/Index.h"

@interface JSValidatorsRunner : NSObject {
@public
    CXCursor _cursor;
    BOOL     _errorsOccured;
}

@property(nonatomic, readonly) BOOL errorsOccured;

- (id) initWithLintsFolderPath:(NSString*) folderPath;

- (void) runValidatorsForCursor:(CXCursor) cursor;

@end
