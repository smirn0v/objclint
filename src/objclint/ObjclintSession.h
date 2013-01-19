//
//  ObjclintSession.h
//  objclint
//
//  Created by Smirnov on 1/19/13.
//  Copyright (c) 2013 Borsch Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <clang-c/Index.h>

#import "ObjclintCoordinator.h"

@interface ObjclintSession : NSObject

- (id) initWithCoordinator:(id<ObjclintCoordinator>) coordinator;

- (BOOL) validateTranslationUnit:(CXTranslationUnit) translationUnit;

@end
