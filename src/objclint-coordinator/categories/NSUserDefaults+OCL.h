//
//  NSUserDefaults+OCL.h
//  objclint
//
//  Created by Александр Смирнов on 6/21/13.
//  Copyright (c) 2013 Alexander Smirnov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (OCL)

- (id) objectForKeyedSubscript:(id) key;

@end
