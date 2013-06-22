//
//  LintBinding.m
//  objclint
//
//  Created by Smirnov on 4/12/13.
//  Copyright (c) 2013 Alexander Smirnov. All rights reserved.
//

#import "LintBinding.h"
#import "ObjclintIssue.h"
#import <objc/message.h>

#include "clang-utils.h"

static JSClass lint_class = {
    .name        = "Lint",
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

JSBool common_report(ObjclintIssueType issueType, JSContext *cx, uintN argc, jsval *vp) {

    JSString* descriptionS;
    if (!JS_ConvertArguments(cx, argc, JS_ARGV(cx, vp), "S", &descriptionS))
        return JS_FALSE;
    
    JSObject* lintObject = JS_THIS_OBJECT(cx, vp);
    LintBinding* binding = JS_GetPrivate(cx, lintObject);
    
    if(!binding)
        return JS_TRUE;
    
    CXCursor cursor = [binding.delegate cursorForLintObject: lintObject];
    
    char* descriptionC = JS_EncodeString(cx, descriptionS);
    NSString* description = [[[NSString alloc] initWithBytesNoCopy: descriptionC
                                                            length: strlen(descriptionC)
                                                          encoding: NSUTF8StringEncoding
                                                      freeWhenDone: YES] autorelease];
    
    char* filePathC = copyCursorFilePath(cursor);
    NSString* filePath = [[[NSString alloc] initWithBytesNoCopy: filePathC
                                                         length: strlen(filePathC)
                                                       encoding: NSUTF8StringEncoding
                                                   freeWhenDone: YES] autorelease];
    
    unsigned int line, column;
    cursorLocation(cursor, &line, &column);
    
    ObjclintIssue* issue = [[[ObjclintIssue alloc] init] autorelease];
    issue.description = description;
    issue.fileName    = filePath;
    issue.line        = line;
    issue.column      = column;
    issue.issueType   = issueType;

    if([binding.delegate respondsToSelector: @selector(lintObject:issue:)])
        [binding.delegate lintObject: lintObject issue: issue];
    
    return JS_TRUE;
}

JSBool lint_reportError(JSContext *cx, uintN argc, jsval *vp) {
    return common_report(ObjclintIssueType_Error, cx, argc, vp);
}

JSBool lint_reportWarning(JSContext *cx, uintN argc, jsval *vp) {
    return common_report(ObjclintIssueType_Warning, cx, argc, vp);
}

JSBool lint_reportInfo(JSContext *cx, uintN argc, jsval *vp) {
    return common_report(ObjclintIssueType_Info, cx, argc, vp);
}

static JSFunctionSpec lint_methods[] = {
    JS_FS("log",           lint_log,           1, 0),
    JS_FS("reportError",   lint_reportError,   1, 0),
    JS_FS("reportWarning", lint_reportWarning, 1, 0),
    JS_FS("reportInfo",    lint_reportInfo,    1, 0),
    JS_FS_END
};

@implementation LintBinding

#pragma mark - Init&Dealloc

- (id) initWithContext:(JSContext*) context runtime:(JSRuntime*) runtime {
    self = [super init];
    if (self) {
        _context = context;
        _runtime = runtime;
        
        _jsClass  = &lint_class;
        _jsFunctionSpec = lint_methods;
        
        _jsPrototype = JS_InitClass(/* context       */ _context,
                                    /* global obj    */ JS_GetGlobalObject(_context),
                                    /* parent proto  */ NULL,
                                    /* class         */ &lint_class,
                                    /* constructor   */ NULL,
                                    /* nargs         */ 0,
                                    /* property spec */ NULL,
                                    /* function spec */ lint_methods,
                                    /* static property spec */ NULL,
                                    /* static func spec     */ NULL);
        
        // not sure if must to, but it's definetely safer to 'retain' prototype here.
        // please correct me if we can ommit this.
        JS_AddNamedObjectRoot(_context, &_jsPrototype, "lint-prototype");
    }
    return self;
}

- (void) dealloc {
    JS_RemoveObjectRoot(_context, &_jsPrototype);
    [super dealloc];
}

#pragma mark - Public

- (JSObject*) createLintObject {
    
    JSObject* lintObject = NULL;
    // TODO: should not be named here.
    lintObject = JS_DefineObject(_context, JS_GetGlobalObject(_context), "lint", _jsClass, _jsPrototype, 0);
    
    JS_SetPrivate(_context, lintObject, self);
    
    return lintObject;
}

@end
