//
//  JSEnvironment.m
//  objclint
//
//  Created by Smirnov on 4/16/13.
//  Copyright (c) 2013 Alexander Smirnov. All rights reserved.
//

#import "JSEnvironment.h"
#import "JSError.h"

/* The class of the global object. */
static JSClass global_class = {
    .name        = "global",
    .flags       = JSCLASS_GLOBAL_FLAGS,
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


void jsenv_reportError(JSContext* cx, const char* message, JSErrorReport* report) {
    JSEnvironment* env = (JSEnvironment*) JS_GetContextPrivate(cx);
    JSError* error = [[JSError new] autorelease];
    error.message  = [[[NSString alloc] initWithBytes: message
                                               length: strlen(message)
                                             encoding: NSUTF8StringEncoding] autorelease];
    error.line     = report->lineno;
    error.errorNo  = report->errorNumber;
    error.filename = [[[NSString alloc] initWithBytes: report->filename
                                               length: strlen(report->filename)
                                             encoding: NSUTF8StringEncoding] autorelease];

    if([env.delegate respondsToSelector: @selector(JSEnvironment:errorOccured:)])
        [env.delegate JSEnvironment: env errorOccured: error];
}

@implementation JSEnvironment

#pragma mark - Init&Dealloc

- (id)init {
    self = [super init];

    if(self && ![self setupSpiderMonkey]) {
        [self release];
        self = nil;
    }

    return self;
}

- (void)dealloc
{
    [self teardownSpiderMonkey];
    [super dealloc];
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
    JS_SetErrorReporter(_context, jsenv_reportError);
    JS_SetContextPrivate(_context, self);
    
    /* Create the global object in a new compartment. */
    _global = JS_NewCompartmentAndGlobalObject(_context, &global_class, NULL);
    
    if (_global == NULL)
        return NO;
    
    /* Populate the global object with the standard globals, like Object and Array. */
    if (!JS_InitStandardClasses(_context, _global))
        return NO;
    
    return YES;
}

- (void) teardownSpiderMonkey {
    if(_context)
        JS_DestroyContext(_context);
    if(_runtime)
        JS_DestroyRuntime(_runtime);
    
    _context = NULL;
    _runtime = NULL;
    _global  = NULL;
}

@end
