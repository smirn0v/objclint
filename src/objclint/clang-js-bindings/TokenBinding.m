//
//  TokenBinding.m
//  objclint
//
//  Created by Alexander Smirnov on 1/20/13.
//  Copyright (c) 2013 Alexander Smirnov. All rights reserved.
//

#import "TokenBinding.h"
#import "CursorBinding.h"

#include "clang-js-utils.h"
#include "clang-utils.h"

static JSClass token_class = {
    .name        = "Token",
    .flags       = JSCLASS_HAS_PRIVATE,
    .addProperty = JS_PropertyStub,
    .delProperty = JS_PropertyStub,
    .getProperty = JS_PropertyStub,
    .setProperty = JS_StrictPropertyStub,
    .enumerate   = JS_EnumerateStub,
    .resolve     = JS_ResolveStub,
    .convert     = JS_ConvertStub,
    .finalize    = NULL,
    JSCLASS_NO_OPTIONAL_MEMBERS
};


static JSFunctionSpec token_methods[] = {
    JS_FS_END
};


@implementation TokenBinding

@synthesize bindings       = _bindings,
            jsClass        = _jsClass,
            jsFunctionSpec = _jsFunctionSpec,
            jsPrototype    = _jsPrototype;

#pragma mark - Init&Dealloc

- (id) initWithBindingsCollection:(ClangBindingsCollection*) collection {
    self = [super init];
    if (self) {
        _bindings = collection;
        
        _jsClass  = &token_class;
        _jsFunctionSpec = token_methods;
        
        _jsPrototype = JS_InitClass(/* context       */ _bindings.context,
                                    /* global obj    */ JS_GetGlobalObject(_bindings.context),
                                    /* parent proto  */ NULL,
                                    /* class         */ &token_class,
                                    /* constructor   */ NULL,
                                    /* nargs         */ 0,
                                    /* property spec */ NULL,
                                    /* function spec */ token_methods,
                                    /* static property spec */ NULL,
                                    /* static func spec     */ NULL);
        
        // not sure if must to, but it's definetely safer to 'retain' prototype here.
        // please correct me if we can ommit this.
        JS_AddNamedObjectRoot(_bindings.context, &_jsPrototype, "token-prototype");
    }
    return self;
}

- (void)dealloc {
    JS_RemoveObjectRoot(_bindings.context, &_jsPrototype);
    [super dealloc];
}

#pragma mark - Public

- (JSObject*) tokensJSArrayFromCursor:(CXCursor) cursor {
    unsigned numTokens;
    
    CXTranslationUnit translationUnit = clang_Cursor_getTranslationUnit(cursor);
    CXToken* tokens;
    
    CXSourceRange cursorExtent = clang_getCursorExtent(cursor);
    clang_tokenize(translationUnit, cursorExtent, &tokens, &numTokens);
    
    CXCursor cursors[numTokens];
    
    if(numTokens == 0) {
        //        clang_disposeTokens(translationUnit, tokens, numTokens);]
        return JS_NewArrayObject(_bindings.context, 0, NULL);
    } else {
        clang_annotateTokens(translationUnit, tokens, numTokens, cursors);
    }
    
    JSObject* tokenObjects[numTokens];
    jsval arrayValues[numTokens];
    
    for(int i = 0; i<numTokens; i++) {
        
        tokenObjects[i] = [self JSObjectFromToken:tokens[i] cursor:cursors[i]];

        arrayValues[i] = OBJECT_TO_JSVAL(tokenObjects[i]);

    }
    
    JSObject* tokensArray = JS_NewArrayObject(_bindings.context, numTokens, arrayValues);
    clang_disposeTokens(translationUnit, tokens, numTokens);
    
    return tokensArray;
}

- (JSObject*) JSObjectFromToken:(CXToken) token cursor:(CXCursor) cursor {
    
    CXTranslationUnit translationUnit = clang_Cursor_getTranslationUnit(cursor);
    
    CXTokenKind tokenKind  = clang_getTokenKind(token);
    CXString tokenSpelling = clang_getTokenSpelling(translationUnit, token);
    
    unsigned line, column;
    CXSourceLocation tokenLocation = clang_getTokenLocation(translationUnit, token);
    clang_getExpansionLocation(tokenLocation, NULL, &line, &column, NULL);
    
    JSObject* tokenObject = JS_NewObject(_bindings.context, &token_class, _jsPrototype, NULL);
    
    setJSProperty_CXString(_bindings.context, tokenObject, "spelling", tokenSpelling);
    setJSProperty_CString(_bindings.context, tokenObject, "kind", getTokenKindSpelling(tokenKind));
    
    setJSProperty_UInt(_bindings.context, tokenObject, "lineNumber", line);
    setJSProperty_UInt(_bindings.context, tokenObject, "column", column);
    
    JSObject* cursorObj = [_bindings.cursorBinding JSObjectFromCursor: cursor];
    setJSProperty_JSObject(_bindings.context, tokenObject, "cursor", cursorObj);
    
    clang_disposeString(tokenSpelling);
    
    return tokenObject;
}

#pragma mark - Private

@end
