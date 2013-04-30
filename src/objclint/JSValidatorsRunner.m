//
//  JavaScriptSession.m
//  objclint
//
//  Created by Alexander Smirnov on 12/24/12.
//  Copyright (c) 2012 Alexander Smirnov. All rights reserved.
//

#import "JSValidatorsRunner.h"

#import "ClangBindings.h"
#import "LintBinding.h"

#include "clang-js-utils.h"
#include "clang-utils.h"

#include "js.h"

/* The class of the global object. */
static JSClass global_class = { "global", JSCLASS_GLOBAL_FLAGS, JS_PropertyStub, JS_PropertyStub, JS_PropertyStub, JS_StrictPropertyStub, JS_EnumerateStub, JS_ResolveStub, JS_ConvertStub, NULL, JSCLASS_NO_OPTIONAL_MEMBERS };

/* The error reporter callback. */
void reportError(JSContext *cx, const char *message, JSErrorReport *report) {
    fprintf(stderr, "%s:%u:%s\n",
            report->filename ?: "<no filename>",
            (unsigned int) report->lineno,
            message);
}

@interface JSValidatorsRunner()<LintBindingDelegate>
@end

@implementation JSValidatorsRunner {
    ClangBindingsCollection* _bindings;
    LintBinding*             _lintBinding;
    NSString* _folderPath;
    JSRuntime* _runtime;
    JSContext* _context;
    JSObject*  _global;
    JSObject*  _lintObject;
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

- (void)dealloc {
    [self teardownSpiderMonkey];
    [_folderPath release];
    [super dealloc];
}

#pragma mark - Public

- (void) runValidatorsForCursor:(CXCursor) cursor {
    if(!_runtime || !_context || !_global)
        return;
    
    _cursor = cursor;
    
    JSObject* cursorObject = [_bindings.cursorBinding JSObjectFromCursor: cursor];
    setJSProperty_JSObject(_context, _global, "cursor", cursorObject);
    
}

#pragma mark - Private

- (BOOL) setupSpiderMonkey {

    [self teardownSpiderMonkey];

    _runtime = JS_NewRuntime(8L * 1024L * 1024L);
    if (_runtime == NULL)
        return NO;

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

    _bindings = [[ClangBindingsCollection alloc] initWithContext:_context runtime:_runtime];
    [self setupLint];
    [self setupValidators];
    
    return YES;
}

- (void) teardownSpiderMonkey {
    [_bindings release];
    [self releaseLint];
    [self releaseValidators];
    
    if(_context)
        JS_DestroyContext(_context);
    if(_runtime)
        JS_DestroyRuntime(_runtime);
    
    _context = NULL;
    _runtime = NULL;
    _global  = NULL;
}

- (void) setupLint {
    _lintBinding = [[LintBinding alloc] initWithContext: _context
                                                runtime: _runtime];
    _lintBinding.delegate = self;
    _lintObject  = [_lintBinding createLintObject];
}

- (void) releaseLint {
    [_lintBinding release];
}

#pragma mark - LintBindingDelegate

- (void) lintObject:(JSObject*) lintObject errorReport:(NSString*) errorDescription {
    
}

- (void) lintObject:(JSObject*) lintObject warningReport:(NSString*) warningDescription {
    
}

- (void) lintObject:(JSObject*) lintObject infoReport:(NSString*) infoReport {
    
}

@end
