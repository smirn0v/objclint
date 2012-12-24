//
//  JavaScriptSession.m
//  objclint
//
//  Created by Smirnov on 12/24/12.
//  Copyright (c) 2012 Borsch Lab. All rights reserved.
//

#import "LintJSValidatorsRuntime.h"
#include <js/jsapi.h>

/* The class of the global object. */
static JSClass global_class = { "global", JSCLASS_GLOBAL_FLAGS, JS_PropertyStub, JS_PropertyStub, JS_PropertyStub, JS_StrictPropertyStub, JS_EnumerateStub, JS_ResolveStub, JS_ConvertStub, NULL, JSCLASS_NO_OPTIONAL_MEMBERS };

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

- (LintJSValidatorsRuntime*) runtimeWithLintsFolderPath:(NSString*) folderPath {
    return [[[[self class] alloc] initWithLintsFolderPath: folderPath] autorelease];
}

- (void)dealloc
{
    [self teardownSpiderMonkey];
    [_folderPath release];
    [super dealloc];
}

#pragma mark - Public

- (void) runValidators {
    if(!_runtime || !_context || !_global)
        return;
    
    for(NSValue* scriptObjValue in _validatorsScripts) {
        JSObject* scriptObj = (JSObject*)[scriptObjValue pointerValue];
        jsval result;
        JS_ExecuteScript(_context, _global, scriptObj, &result);
        JS_MaybeGC(_context);
    }
}

#pragma mark - Private

- (BOOL) setupSpiderMonkey {
    
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
    
    /* Create the global object in a new compartment. */
    _global = JS_NewGlobalObject(_context, &global_class);
    if (_global == NULL)
        return NO;
    
    /* Populate the global object with the standard globals, like Object and Array. */
    if (!JS_InitStandardClasses(_context, _global)) {
        JS_DestroyContext(_context);
        
        return NO;
    }
    
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
        NSFileManager* fileManager = [NSFileManager defaultManager];
        NSDirectoryEnumerator* dirEnumerator = [fileManager enumeratorAtPath: _folderPath];
        
        NSString *filePath;
        while (filePath = [dirEnumerator nextObject]) {
            NSString* fileName = filePath.lastPathComponent;
            if([fileName hasPrefix:@"lint-check"] && [fileName hasSuffix:@".js"]) {
                const char* filePathC = [filePath cStringUsingEncoding:NSUTF8StringEncoding];
                JSObject* scriptObj = JS_CompileFile(_context, _global, filePathC);
                
                if(NULL == scriptObj)
                    continue;

                if(!JS_AddNamedObjectRoot(_context, &scriptObj, NULL))
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


@end
