//
//  CursorArray.h
//  objclint
//
//  Created by Александр Смирнов on 7/14/13.
//  Copyright (c) 2013 Alexander Smirnov. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <clang-c/Index.h>

@interface CursorArray : NSObject

- (id) initWithCursor:(CXCursor) cursor;

- (void) addCursor:(CXCursor) cursor;
- (void) removeCursor:(CXCursor) cursor;

- (CXCursor) lastCursor;
- (CXCursor) firstCursor;

- (NSUInteger) count;
- (NSUInteger) length;

- (CXCursor) cursorAtIndex:(NSUInteger) index;

@end
