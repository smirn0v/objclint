//
//  ObjclintCoordinatorImpl.h
//  objclint
//
//  Created by Alexander Smirnov on 12/9/12.
//  Copyright (c) 2012 Alexander Smirnov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjclintCoordinator.h"

@interface ObjclintCoordinatorImpl : NSObject<ObjclintCoordinator>

@property(nonatomic,readonly) NSDate* lastActionDate;

@end
