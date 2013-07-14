//
//  CursorArray.m
//  objclint
//
//  Created by Александр Смирнов on 7/14/13.
//  Copyright (c) 2013 Alexander Smirnov. All rights reserved.
//

#import "CursorArray.h"

@implementation CursorArray {
    NSMutableArray* _cursorArray;
}

#pragma mark - Init&Dealloc

- (id)init
{
    self = [super init];
    if (self) {
        _cursorArray = [NSMutableArray new];
    }
    return self;
}

- (id) initWithCursor:(CXCursor) cursor {
    if(self = [self init]) {
        
    }
    return self;
}

- (void)dealloc
{
    [_cursorArray release];
    [super dealloc];
}

#pragma mark - Public

- (void) addCursor:(CXCursor) cursor {
    [_cursorArray addObject: [self valueFromCursor: cursor]];
}

- (void) removeCursor:(CXCursor) cursor {
    [_cursorArray removeObject: [self valueFromCursor: cursor]];
}

- (CXCursor) lastCursor {
    return [self cursorFromValue: [_cursorArray lastObject]];
}

- (CXCursor) firstCursor {
    if(_cursorArray.count)
        return [self cursorFromValue: _cursorArray[0]];
    return clang_getNullCursor();
}

- (NSUInteger) count {
    return self.length;
}

- (NSUInteger) length {
    return _cursorArray.count;
}

- (CXCursor) cursorAtIndex:(NSUInteger) index {
    if(index < self.length)
        return [self cursorFromValue: _cursorArray[index]];
    return clang_getNullCursor();
}

#pragma mark - Private

- (NSValue*) valueFromCursor:(CXCursor) cursor {
    return [NSValue valueWithBytes: &cursor objCType: @encode(CXCursor)];
}

- (CXCursor) cursorFromValue:(NSValue*) value {
    if(!value)
        return clang_getNullCursor();
    CXCursor cursor;
    [value getValue: &cursor];
    return cursor;
}

@end
