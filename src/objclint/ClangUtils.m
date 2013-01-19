//
//  ClangUtils.m
//  objclint
//
//  Created by Smirnov on 12/23/12.
//  Copyright (c) 2012 Borsch Lab. All rights reserved.
//

#import "ClangUtils.h"


@implementation ClangUtils


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
