//
//  JavaScriptSession.m
//  objclint
//
//  Created by Smirnov on 12/24/12.
//  Copyright (c) 2012 Borsch Lab. All rights reserved.
//

#import "LintJSValidatorsRuntime.h"
#import "ClangUtils.h"

#define JS_NO_JSVAL_JSID_STRUCT_TYPES
#include "js/jsapi.h"

JSBool lint_log(JSContext *cx, uintN argc, jsval *vp) {
    
    JSString* string;
    if (!JS_ConvertArguments(cx, argc, JS_ARGV(cx, vp), "S", &string))
        return JS_FALSE;
    
    char* stringC = JS_EncodeString(cx, string);
    
    NSLog(@"%s",stringC);
    
    JS_free(cx, stringC);
    JS_SET_RVAL(cx, vp, JSVAL_VOID);
    return JS_TRUE;
}

JSBool lint_reportError(JSContext *cx, uintN argc, jsval *vp) {
    JSString* errorDescription;
    if (!JS_ConvertArguments(cx, argc, JS_ARGV(cx, vp), "S", &errorDescription))
        return JS_FALSE;
    
    char* errorDescriptionC = JS_EncodeString(cx, errorDescription);
    
    LintJSValidatorsRuntime* runtime = JS_GetContextPrivate(cx);

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

/* The class of the global object. */
static JSClass global_class = { "global", JSCLASS_GLOBAL_FLAGS, JS_PropertyStub, JS_PropertyStub, JS_PropertyStub, JS_StrictPropertyStub, JS_EnumerateStub, JS_ResolveStub, JS_ConvertStub, NULL, JSCLASS_NO_OPTIONAL_MEMBERS };

static JSClass lint_class = { "Lint", JSCLASS_HAS_PRIVATE, JS_PropertyStub, JS_PropertyStub, JS_PropertyStub, JS_StrictPropertyStub, JS_EnumerateStub, JS_ResolveStub, JS_ConvertStub, NULL, JSCLASS_NO_OPTIONAL_MEMBERS };

static JSFunctionSpec lint_methods[] = {
    JS_FS("log", lint_log, 1, 0),
    JS_FS("reportError", lint_reportError, 1, 0),
    JS_FS_END
};

/* The error reporter callback. */
void reportError(JSContext *cx, const char *message, JSErrorReport *report) {
    fprintf(stderr, "%s:%u:%s\n",
            report->filename ?: "<no filename>",
            (unsigned int) report->lineno,
            message);
}

@implementation LintJSValidatorsRuntime {
    NSString* _folderPath;
    JSRuntime* _runtime;
    JSContext* _context;
    JSObject*  _global;
    JSObject* _lintObject;
    NSMutableArray* _validatorsScripts;
}

- (id) initWithLintsFolderPath:(NSString*) folderPath {
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

+ (LintJSValidatorsRuntime*) runtimeWithLintsFolderPath:(NSString*) folderPath {
    return [[[[self class] alloc] initWithLintsFolderPath: folderPath] autorelease];
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
    
    [self fillLintObjectFromCursor: cursor];
    
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
    
    JSObject* prototype = JS_InitClass(_context, _global, NULL, &lint_class, NULL, 0, NULL, lint_methods, NULL, NULL);
    _lintObject = JS_DefineObject(_context, _global, "lint", &lint_class, prototype, 0);
    
    
    
    JS_AddNamedObjectRoot(_context, &_lintObject, "lint");
}

- (void) fillLintObjectFromCursor:(CXCursor) cursor {
    CXSourceLocation location = clang_getCursorLocation(cursor);
    
    unsigned line;
    unsigned column;
    unsigned offset;
    
    clang_getSpellingLocation(location,NULL,&line,&column,&offset);
    
    jsval lineVal = UINT_TO_JSVAL(line);
    jsval columnVal = UINT_TO_JSVAL(column);
    jsval offsetVal = UINT_TO_JSVAL(offset);
    
    JS_SetProperty(_context, _lintObject, "line", &lineVal);
    JS_SetProperty(_context, _lintObject, "column", &columnVal);
    JS_SetProperty(_context, _lintObject, "offset", &offsetVal);
    
    // display name
    CXString displayName = clang_getCursorDisplayName(cursor);
    [self setJSPropertyNamed:"displayName" withCXString:displayName];
    clang_disposeString(displayName);// ??? should I ?
    
    
    CXString usr = clang_getCursorUSR(cursor);
    [self setJSPropertyNamed:"USR" withCXString:usr];
    clang_disposeString(usr);
    
    CXString spelling = clang_getCursorSpelling(cursor);
    [self setJSPropertyNamed:"spelling" withCXString:spelling];
    clang_disposeString(spelling);
    
    CXString kind = clang_getCursorKindSpelling(clang_getCursorKind(cursor));
    [self setJSPropertyNamed:"kind" withCXString:kind];
    clang_disposeString(kind);
    
}

- (void) setJSPropertyNamed:(const char*) name withCXString:(CXString) string {
    const char* stringC = clang_getCString(string);
    
    JSString* js_string = JS_NewStringCopyZ(_context, stringC);
    jsval usrVal = STRING_TO_JSVAL(js_string);
    
    JS_SetProperty(_context, _lintObject, name, &usrVal);
}


@end
