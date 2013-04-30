//
//  JSError.h
//  objclint
//
//  Created by Smirnov on 4/16/13.
//  Copyright (c) 2013 Alexander Smirnov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSError : NSObject

@property(nonatomic, retain) NSString*  filename;
@property(nonatomic, assign) NSUInteger line;
@property(nonatomic, assign) NSUInteger errorNo;
@property(nonatomic, retain) NSString*  message;

@end
