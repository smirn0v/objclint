//
//  ClangSpellingLocation.h
//  objclint
//
//  Created by Smirnov on 12/23/12.
//  Copyright (c) 2012 Borsch Lab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClangSpellingLocation : NSObject

@property(nonatomic, retain) NSString* filePath;
@property(nonatomic, assign) unsigned line;
@property(nonatomic, assign) unsigned column;
@property(nonatomic, assign) unsigned offset;

@end
