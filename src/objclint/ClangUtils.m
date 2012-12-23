//
//  ClangUtils.m
//  objclint
//
//  Created by Smirnov on 12/23/12.
//  Copyright (c) 2012 Borsch Lab. All rights reserved.
//

#import "ClangUtils.h"
#import "ClangSpellingLocation.h"

@implementation ClangUtils

+ (NSString*) projectPath {
    static NSString* currentDirPath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        currentDirPath = [[[NSFileManager defaultManager] currentDirectoryPath] retain];
    });
    
    return currentDirPath;
}

+ (BOOL) locationBelongsToProject:(const CXSourceLocation*) location {
    NSString* filePath = [self spellingLocationForSourceLocation: location].filePath;
    return [filePath rangeOfString: self.projectPath].location == 0;
}

+ (ClangSpellingLocation*) spellingLocationForSourceLocation:(const CXSourceLocation*) location {
    CXFile file;
    unsigned line;
    unsigned column;
    unsigned offset;
    
    clang_getSpellingLocation(*location,&file,&line,&column,&offset);
    
    CXString fileNameCX = clang_getFileName(file);
    const char* fileNameC = clang_getCString(fileNameCX);
    
    ClangSpellingLocation* spellingLocation = [[ClangSpellingLocation new] autorelease];
    
    if(fileNameC)
        spellingLocation.filePath = [NSString stringWithUTF8String:fileNameC];
    spellingLocation.line = line;
    spellingLocation.column = column;
    spellingLocation.offset = offset;
    
    clang_disposeString(fileNameCX);
    
    return spellingLocation;
}

@end
