//
//  JavaScriptSession.m
//  objclint
//
//  Created by Smirnov on 12/24/12.
//  Copyright (c) 2012 Borsch Lab. All rights reserved.
//

#import "JSValidatorsRunner.h"
#import "ClangUtils.h"
#include "cursor-info-helper.h"


#define JS_NO_JSVAL_JSID_STRUCT_TYPES
#include "js/jsapi.h"

/* The class of the global object. */
static JSClass global_class = { "global", JSCLASS_GLOBAL_FLAGS, JS_PropertyStub, JS_PropertyStub, JS_PropertyStub, JS_StrictPropertyStub, JS_EnumerateStub, JS_ResolveStub, JS_ConvertStub, NULL, JSCLASS_NO_OPTIONAL_MEMBERS };

static JSClass lint_class = { "Lint", JSCLASS_HAS_PRIVATE, JS_PropertyStub, JS_PropertyStub, JS_PropertyStub, JS_StrictPropertyStub, JS_EnumerateStub, JS_ResolveStub, JS_ConvertStub, NULL, JSCLASS_NO_OPTIONAL_MEMBERS };

static JSClass token_class = { "Token", JSCLASS_HAS_PRIVATE, JS_PropertyStub, JS_PropertyStub, JS_PropertyStub, JS_StrictPropertyStub, JS_EnumerateStub, JS_ResolveStub, JS_ConvertStub, NULL, JSCLASS_NO_OPTIONAL_MEMBERS };

static JSClass cursor_class = { "Cursor", JSCLASS_HAS_PRIVATE, JS_PropertyStub, JS_PropertyStub, JS_PropertyStub, JS_StrictPropertyStub, JS_EnumerateStub, JS_ResolveStub, JS_ConvertStub, NULL, JSCLASS_NO_OPTIONAL_MEMBERS };


JSBool lint_log(JSContext *cx, uintN argc, jsval *vp) {
    
    JSString* string;
    if (!JS_ConvertArguments(cx, argc, JS_ARGV(cx, vp), "S", &string))
        return JS_FALSE;
    
    char* stringC = JS_EncodeString(cx, string);
    
    printf("%s\n",stringC);
    
    JS_free(cx, stringC);
    JS_SET_RVAL(cx, vp, JSVAL_VOID);
    return JS_TRUE;
}

JSBool lint_reportError(JSContext *cx, uintN argc, jsval *vp) {
    JSString* errorDescription;
    if (!JS_ConvertArguments(cx, argc, JS_ARGV(cx, vp), "S", &errorDescription))
        return JS_FALSE;
    
    char* errorDescriptionC = JS_EncodeString(cx, errorDescription);
    
    JSValidatorsRunner* runtime = (JSValidatorsRunner*)JS_GetContextPrivate(cx);

    //TODO: somehow use CXDiagnostic
    
    NSString* filePath = [ClangUtils filePathForCursor: runtime->_cursor];
    NSString* fileName = filePath.lastPathComponent;
    const char* fileNameC = [fileName UTF8String];
    
    CXSourceLocation location = clang_getCursorLocation(runtime->_cursor);
    
    unsigned line;
    unsigned column;
    
    clang_getSpellingLocation(location,NULL,&line,&column,NULL);
    fprintf(stderr,"%s:%u:%u: warning: %s\n", fileNameC, line, column, errorDescriptionC);
    
    runtime->_errorsOccured = YES;
    
    return JS_TRUE;
}

JSBool cursor_get_lexical_parent(JSContext *cx, uintN argc, jsval *vp) {

    JSObject* cursorObject = JS_THIS_OBJECT(cx, vp);
    CXCursor cursor = cursor_from_jsobject(cx, cursorObject);

    CXCursor lexicalParentCursor = clang_getCursorLexicalParent(cursor);
    if(clang_Cursor_isNull(lexicalParentCursor)) {
        JS_SET_RVAL(cx, vp, JSVAL_NULL);
        return JS_TRUE;
    }

    JSObject* lexicalParentCursorObj = JS_NewObject(cx, &cursor_class, JS_GetPrototype(cx, cursorObject), NULL);

    JSValidatorsRunner* runtime = JS_GetPrivate(cx, cursorObject);

    [runtime fillJSObject:lexicalParentCursorObj fromCursor:lexicalParentCursor];

    jsval result = OBJECT_TO_JSVAL(lexicalParentCursorObj);
    JS_SET_RVAL(cx, vp, result);
    
    return JS_TRUE;
}

JSBool cursor_get_semantic_parent(JSContext *cx, uintN argc, jsval *vp) {
    
    JSObject* cursorObject = JS_THIS_OBJECT(cx, vp);
    CXCursor cursor = cursor_from_jsobject(cx, cursorObject);
    
    CXCursor semanticParentCursor = clang_getCursorSemanticParent(cursor);
    
    if(clang_Cursor_isNull(semanticParentCursor)) {
        JS_SET_RVAL(cx, vp, JSVAL_NULL);
        return JS_TRUE;
    }
    
    JSObject* semanticParentCursorObj = JS_NewObject(cx, &cursor_class, JS_GetPrototype(cx, cursorObject), NULL);
    
    JSValidatorsRunner* runtime = JS_GetPrivate(cx, cursorObject);
    
    [runtime fillJSObject:semanticParentCursorObj fromCursor:semanticParentCursor];
    
    jsval result = OBJECT_TO_JSVAL(semanticParentCursorObj);
    JS_SET_RVAL(cx, vp, result);
    
    return JS_TRUE;
}

JSBool cursor_visit_children(JSContext* cx, uintN argc, jsval *vp) {

    JSFunction* ignoreFunction;
    if (!JS_ConvertArguments(cx, argc, JS_ARGV(cx, vp), "f", &ignoreFunction))
        return JS_FALSE;
    
    JSObject* cursorObject = JS_THIS_OBJECT(cx, vp);
    CXCursor cursor = cursor_from_jsobject(cx, cursorObject);

    JSValidatorsRunner* runtime = JS_GetPrivate(cx, cursorObject);

    clang_visitChildrenWithBlock(cursor, ^enum CXChildVisitResult(CXCursor childCursor, CXCursor parent) {
        
        JSObject* childObj = JS_NewObject(cx, &cursor_class, JS_GetPrototype(cx, cursorObject), NULL);

        [runtime fillJSObject:childObj fromCursor:childCursor];
        
        jsval retVal;
        jsval childVal = OBJECT_TO_JSVAL(childObj);

        JSBool result = JS_CallFunctionValue(cx, JS_GetGlobalObject(cx), *(JS_ARGV(cx, vp)), 1, &childVal, &retVal);

        return CXChildVisit_Recurse;
    });
    
    return JS_TRUE;
}

JSBool cursor_get_tokens(JSContext* cx, uintN argc, jsval *vp) {
    JSObject* cursorObject = JS_THIS_OBJECT(cx, vp);
    CXCursor cursor = cursor_from_jsobject(cx, cursorObject);
    JSValidatorsRunner* runtime = JS_GetPrivate(cx, cursorObject);
    JS_SET_RVAL(cx, vp, OBJECT_TO_JSVAL([runtime tokensForCursor:cursor]));
    return JS_TRUE;
}

JSBool cursor_equal(JSContext* cx, uintN argc, jsval *vp) {
    JSObject* cursorObject = JS_THIS_OBJECT(cx, vp);
    CXCursor cursor = cursor_from_jsobject(cx, cursorObject);
    
    JSObject* anotherCursorObject;
    if (!JS_ConvertArguments(cx, argc, JS_ARGV(cx, vp), "o", &anotherCursorObject))
        return JS_FALSE;
    
    CXCursor anotherCursor = cursor_from_jsobject(cx, anotherCursorObject);
    
    bool equals = clang_equalCursors(cursor, anotherCursor);
    JS_SET_RVAL(cx, vp, equals);
    
    return JS_TRUE;
}

/* The error reporter callback. */
void reportError(JSContext *cx, const char *message, JSErrorReport *report) {
    fprintf(stderr, "%s:%u:%s\n",
            report->filename ?: "<no filename>",
            (unsigned int) report->lineno,
            message);
}

static JSFunctionSpec lint_methods[] = {
    JS_FS("log", lint_log, 1, 0),
    JS_FS("reportError", lint_reportError, 1, 0),
    JS_FS_END
};

static JSFunctionSpec cursor_methods[] = {
    JS_FS("getLexicalParent",cursor_get_lexical_parent,0,0),
    JS_FS("getSemanticParent",cursor_get_semantic_parent,0,0),
    JS_FS("visitChildren",cursor_visit_children,1,0),
    JS_FS("getTokens",cursor_get_tokens,0,0),
    JS_FS("equal",cursor_equal,1,0),
    JS_FS_END
};

@implementation JSValidatorsRunner {
    NSString* _folderPath;
    JSRuntime* _runtime;
    JSContext* _context;
    JSObject*  _global;
    JSObject* _lintPrototypeObject;
    JSObject* _tokenPrototypeObject;
    JSObject* _cursorPrototypeObject;
    JSObject* _lintObject;
    JSObject* _cursorObject;
    NSMutableArray* _validatorsScripts;
}

- (id) initWithLintsFolderPath:(NSString*) folderPath{
    self = [super init];
    if(self) {
        _folderPath = [folderPath retain];
        if(NO == [self setupSpiderMonkey]) {
            [self autorelease];
            self = nil;
            return self;
        }
            
    }
    return self;
}

- (void)dealloc
{
    [self teardownSpiderMonkey];
    [_folderPath release];
    [super dealloc];
}

#pragma mark - Public

- (void) runValidatorsForCursor:(CXCursor) cursor {
    if(!_runtime || !_context || !_global)
        return;
    
    _cursor = cursor;
    
    [self fillJSObject:_cursorObject fromCursor:cursor];
    
    for(NSValue* scriptObjValue in _validatorsScripts) {
        JSObject* scriptObj = (JSObject*)[scriptObjValue pointerValue];
        jsval result;
        JS_ExecuteScript(_context, _global, scriptObj, &result);
        JS_MaybeGC(_context);
    }
}

#pragma mark - Private

- (BOOL) setupSpiderMonkey {

    [self teardownSpiderMonkey];

    /* Create a JS runtime. */
    _runtime = JS_NewRuntime(8L * 1024L * 1024L);
    if (_runtime == NULL)
        return NO;

    /* Create a context. */
    _context = JS_NewContext(_runtime, 8192);
    if (_context == NULL)
        return NO;

    JS_SetOptions(_context, JSOPTION_VAROBJFIX | JSOPTION_METHODJIT);
    JS_SetVersion(_context, JSVERSION_LATEST);
    JS_SetErrorReporter(_context, reportError);
    JS_SetContextPrivate(_context, self);

    /* Create the global object in a new compartment. */
    _global = JS_NewCompartmentAndGlobalObject(_context, &global_class, NULL);

    if (_global == NULL)
        return NO;

    /* Populate the global object with the standard globals, like Object and Array. */
    if (!JS_InitStandardClasses(_context, _global))
        return NO;

    [self registerLintObject];
    [self prepareValidators];
    
    return YES;
}

- (void) teardownSpiderMonkey {
    [self releaseValidators];
    
    if(_context)
        JS_DestroyContext(_context);
    if(_runtime)
        JS_DestroyRuntime(_runtime);
    
    _context = NULL;
    _runtime = NULL;
    _global  = NULL;
}

- (void) prepareValidators {
    @autoreleasepool {
        [_validatorsScripts release];
        _validatorsScripts = [[NSMutableArray array] retain];
        
        NSFileManager* fileManager = [NSFileManager defaultManager];
        NSDirectoryEnumerator* dirEnumerator = [fileManager enumeratorAtPath: _folderPath];
        
        NSString *filePath;
        while (filePath = [dirEnumerator nextObject]) {
            
            filePath = [_folderPath stringByAppendingPathComponent: filePath];
            NSString* fileName = filePath.lastPathComponent;
            
            if([fileName hasPrefix:@"lint-check"] && [fileName hasSuffix:@".js"]) {
                
                const char* filePathC = [filePath cStringUsingEncoding:NSUTF8StringEncoding];
                JSObject* scriptObj = JS_CompileFile(_context, _global, filePathC);
                
                if(NULL == scriptObj)
                    continue;

                if(!JS_AddObjectRoot(_context, &scriptObj))
                    continue;
                    
                [_validatorsScripts addObject: [NSValue valueWithPointer: scriptObj]];
            }
        }
    }
}

- (void) releaseValidators {
    for(NSValue* scriptObjValue in _validatorsScripts) {
        JSObject* scriptObj = (JSObject*)[scriptObjValue pointerValue];
        JS_RemoveObjectRoot(_context, &scriptObj);
    }
    [_validatorsScripts release];
    _validatorsScripts = nil;
}

- (void) registerLintObject {
    
    _lintPrototypeObject = JS_InitClass(_context, _global, NULL, &lint_class, NULL, 0, NULL, lint_methods, NULL, NULL);
    _tokenPrototypeObject = JS_InitClass(_context, _global, NULL, &token_class, NULL, 0, NULL, NULL, NULL, NULL);
    _cursorPrototypeObject = JS_InitClass(_context, _global, NULL, &token_class, NULL, 0, NULL, cursor_methods, NULL, NULL);
    
    _lintObject = JS_DefineObject(_context, _global, "lint", &lint_class, _lintPrototypeObject, 0);
    _cursorObject = JS_DefineObject(_context, _global, "cursor", &cursor_class, _cursorPrototypeObject, 0);
    
    JS_AddNamedObjectRoot(_context, &_lintObject, "lint");
    JS_AddNamedObjectRoot(_context, &_lintPrototypeObject, "lint-prototype");
    JS_AddNamedObjectRoot(_context, &_tokenPrototypeObject, "token-prototype");
    JS_AddNamedObjectRoot(_context, &_cursorPrototypeObject, "cursor-prototype");
}

- (void) fillJSObject:(JSObject*)object fromCursor:(CXCursor) cursor {
    CXSourceLocation location = clang_getCursorLocation(cursor);
    CXFile   file;
    unsigned line;
    unsigned column;
    unsigned offset;
    
    store_cursor_into_jsobject(cursor, _context, object);
    
    clang_getSpellingLocation(location,&file,&line,&column,&offset);
    
    jsval lineVal   = UINT_TO_JSVAL(line);
    jsval columnVal = UINT_TO_JSVAL(column);
    jsval offsetVal = UINT_TO_JSVAL(offset);
    
    JS_SetProperty(_context, object, "lineNumber", &lineVal);
    JS_SetProperty(_context, object, "column", &columnVal);
    JS_SetProperty(_context, object, "offset", &offsetVal);
    
    CXString fileName = clang_getFileName(file);
    [self setJSPropertyNamed:"fileName" withCXString:fileName forJSObject:object];
    clang_disposeString(fileName);
    
    CXString displayName = clang_getCursorDisplayName(cursor);
    [self setJSPropertyNamed:"displayName" withCXString:displayName forJSObject:object];
    clang_disposeString(displayName);
    
    CXString usr = clang_getCursorUSR(cursor);
    [self setJSPropertyNamed:"USR" withCXString:usr forJSObject:object];
    clang_disposeString(usr);
    
    CXString spelling = clang_getCursorSpelling(cursor);
    [self setJSPropertyNamed:"spelling" withCXString:spelling forJSObject:object];
    clang_disposeString(spelling);
    
    enum CXCursorKind cursorKind = clang_getCursorKind(cursor);
    CXString kind = clang_getCursorKindSpelling(cursorKind);
    [self setJSPropertyNamed:"kind" withCXString:kind forJSObject:object];
    clang_disposeString(kind);
    
    bool synthesized = method_is_synthesized(cursor);
    jsval synthesizedVal = BOOLEAN_TO_JSVAL(synthesized);
    JS_SetProperty(_context, object, "isSynthesizedMethod", &synthesizedVal);
    
    bool hasBody = decl_has_body(cursor);
    jsval hasBodyVal = BOOLEAN_TO_JSVAL(hasBody);
    JS_SetProperty(_context, object, "declarationHasBody", &hasBodyVal);
    
    JS_SetPrivate(_context, object, self);
}

- (void) setJSPropertyNamed:(const char*) name withCXString:(CXString) string forJSObject:(JSObject*) object{
    const char* stringC = clang_getCString(string);
    
    JSString* js_string = JS_NewStringCopyZ(_context, stringC);
    jsval usrVal = STRING_TO_JSVAL(js_string);
    
    JS_SetProperty(_context, object, name, &usrVal);
}

- (JSObject*) tokensForCursor:(CXCursor) cursor {
    
    unsigned line;
    unsigned column;

    CXTranslationUnit translationUnit = clang_Cursor_getTranslationUnit(cursor);
    CXToken* tokens;
    
    unsigned int numTokens;
    
    CXSourceRange cursorExtent = clang_getCursorExtent(cursor);
    clang_tokenize(translationUnit, cursorExtent, &tokens, &numTokens);
    
    CXCursor cursors[numTokens];
    
    if(numTokens == 0) {
//        clang_disposeTokens(translationUnit, tokens, numTokens);]
        return JS_NewArrayObject(_context, 0, NULL);
    } else {
        clang_annotateTokens(translationUnit, tokens, numTokens, cursors);
    }
    
    JSObject* tokenObjects[numTokens];
    jsval arrayValues[numTokens];
    
    for(int i = 0; i<numTokens; i++) {
        CXToken token = tokens[i];
        CXTokenKind tokenKind = clang_getTokenKind(token);
        
        CXString tokenSpelling = clang_getTokenSpelling(translationUnit, token);
        const char* tokenSpellingC = clang_getCString(tokenSpelling);
        const char* tokenKindC = [[ClangUtils tokenKindDescription: tokenKind] UTF8String];
        
        CXSourceLocation tokenLocation = clang_getTokenLocation(translationUnit, token);
        clang_getExpansionLocation(tokenLocation, NULL, &line, &column, NULL);
        
        tokenObjects[i] = JS_NewObject(_context, &token_class, _tokenPrototypeObject, NULL);

        JSString* tokenKindString = JS_NewStringCopyZ(_context, tokenKindC);
        jsval tokenKindVal = STRING_TO_JSVAL(tokenKindString);

        JS_SetProperty(_context, tokenObjects[i], "kind", &tokenKindVal);
        
        JSString* tokenSpellingString = JS_NewStringCopyZ(_context, tokenSpellingC);
        jsval tokenSpellingVal = STRING_TO_JSVAL(tokenSpellingString);
        JS_SetProperty(_context, tokenObjects[i], "spelling", &tokenSpellingVal);
        
        jsval lineVal = UINT_TO_JSVAL(line);
        JS_SetProperty(_context, tokenObjects[i], "lineNumber", &lineVal);
        
        jsval columnVal = UINT_TO_JSVAL(column);
        JS_SetProperty(_context, tokenObjects[i], "column", &columnVal);
        
        JSObject* cursorObj = JS_DefineObject(_context, tokenObjects[i], "cursor", &cursor_class, _cursorPrototypeObject, 0);
        [self fillJSObject:cursorObj fromCursor:cursors[i]];
        
        
        arrayValues[i] = OBJECT_TO_JSVAL(tokenObjects[i]);
        
        clang_disposeString(tokenSpelling);
    }
    
    JSObject* tokensArray = JS_NewArrayObject(_context, numTokens, arrayValues);
    clang_disposeTokens(translationUnit, tokens, numTokens);
    
    return tokensArray;
}


@end
