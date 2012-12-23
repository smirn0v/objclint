//
//  ObjclintSessionManagerProtocol.h
//  objclint
//
//  Created by Smirnov on 12/9/12.
//  Copyright (c) 2012 Borsch Lab. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ObjclintSessionManagerProtocol <NSObject>

- (BOOL) checkIfLocation:(NSString*) location wasCheckedForProjectIdentity:(NSString*) projectIdentity;
- (void) markLocation:(NSString*) location checkedForProjectIdentity:(NSString*) projectIdentity;

@end