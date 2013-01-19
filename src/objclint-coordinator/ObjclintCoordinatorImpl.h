//
//  ObjclintCoordinatorImpl.h
//  objclint
//
//  Created by Smirnov on 12/9/12.
//  Copyright (c) 2012 Borsch Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjclintCoordinator.h"

@interface ObjclintCoordinatorImpl : NSObject<ObjclintCoordinator>

@property(nonatomic,readonly) NSDate* lastActionDate;

@end
