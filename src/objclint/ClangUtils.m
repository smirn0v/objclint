//
//  ClangUtils.m
//  objclint
//
//  Created by Smirnov on 12/23/12.
//  Copyright (c) 2012 Borsch Lab. All rights reserved.
//

#import "ClangUtils.h"


@implementation ClangUtils

+ (NSString*) projectPath {
    static NSString* currentDirPath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        currentDirPath = [[[NSFileManager defaultManager] currentDirectoryPath] retain];
    });
    
    return currentDirPath;
}

+ (NSString*) filePathForCursor:(CXCursor) cursor {
    CXSourceLocation location = clang_getCursorLocation(cursor);
    
    CXFile file;
    
    clang_getSpellingLocation(location,&file,NULL,NULL,NULL);
    
    CXString fileNameCX = clang_getFileName(file);
    const char* fileNameC = clang_getCString(fileNameCX);
    
    NSString* filePath = nil;
    if(fileNameC)
        filePath = [NSString stringWithUTF8String: fileNameC];
    
    clang_disposeString(fileNameCX);
    
    return filePath;
}

+ (BOOL) cursorBelongsToProject:(CXCursor) cursor {
    NSString* filePath = [self filePathForCursor: cursor];
    
    return filePath!=nil && [filePath rangeOfString: self.projectPath].location == 0;
}

+ (NSString*) cursorDescription:(CXCursor) cursor {
    CXSourceLocation location = clang_getCursorLocation(cursor);
    
    CXFile file;
    unsigned line;
    unsigned column;
    unsigned offset;
    
    clang_getSpellingLocation(location,&file,&line,&column,&offset);
    
    CXString fileNameCX = clang_getFileName(file);
    const char* fileNameC = clang_getCString(fileNameCX);
    
    NSString* filePath = nil;
    if(fileNameC)
        filePath = [NSString stringWithUTF8String: fileNameC];
    
    clang_disposeString(fileNameCX);
    
    return [NSString stringWithFormat:@"clang-%@-%u-%u-%u", filePath,line,column,offset];
}

+ (NSString*) tokenKindDescription:(CXTokenKind) tokenKind {
    NSDictionary* tokenKindDescription =
    @{
        @(CXToken_Punctuation) : @"Punctuation",
        @(CXToken_Keyword)     : @"Keyword",
        @(CXToken_Identifier)  : @"Identifier",
        @(CXToken_Literal)     : @"Literal",
        @(CXToken_Comment)     : @"Comment"
    };
    return tokenKindDescription[@(tokenKind)];
}

@end
