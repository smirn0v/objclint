//
//  ObjclintReportGenerator.h
//  objclint
//
//  Created by Smirnov on 5/1/13.
//  Copyright (c) 2013 Alexander Smirnov. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ObjclintCoordinator;

@protocol ObjclintReportGenerator <NSObject>

- (void) generateReportForProjectIdentity:(NSString*) identity
                        withinCoordinator:(id<ObjclintCoordinator>) coordinator;

@end
