//
//  CursorBinding.m
//  objclint
//
//  Created by Alexander Smirnov on 1/20/13.
//  Copyright (c) 2013 Alexander Smirnov. All rights reserved.
//

#import "CursorBinding.h"

#import "TokenBinding.h"
#import "ObjCMethodDeclarationBinding.h"

#include <objc/runtime.h>
#include "clang-js-utils.h"

static NSString* const kCursorBindingKey = @"kCursorBindingKey";
static NSString* const kCursorPredecessorsKey = @"kCursorPredecessorsKey";

static JSClass cursor_class = {
    .name        = "Cursor",
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

void extract_privates(JSContext* context,
                      jsval* parameters,
                      CursorBinding** cursorBinding,
                      CursorArray** predecessors,
                      CXCursor* cursor) {
    
    JSObject* cursorObject = JS_THIS_OBJECT(context, parameters);
    NSDictionary* dict = JS_GetPrivate(context, cursorObject);
    CursorBinding* binding = dict[kCursorBindingKey];
    CursorArray*   cursorPredecessors = dict[kCursorPredecessorsKey];
    
    if(cursorBinding)
        *cursorBinding = binding;
    
    if(predecessors)
        *predecessors = cursorPredecessors;
    
    if(cursor)
        *cursor = [binding cursorFromJSObject: cursorObject];
}

JSBool cursor_get_lexical_parent(JSContext* context, uintN argc, jsval* parameters) {
    CursorBinding* cursorBinding;
    CXCursor cursor;
    extract_privates(context, parameters, &cursorBinding, NULL, &cursor);
    
    CXCursor lexicalParentCursor = clang_getCursorLexicalParent(cursor);
    if(clang_Cursor_isNull(lexicalParentCursor)) {
        JS_SET_RVAL(context, parameters, JSVAL_NULL);
        return JS_TRUE;
    }
    
    JSObject* lexicalParentCursorObj = [cursorBinding JSObjectFromCursor: lexicalParentCursor
                                                        withPredecessors: nil];
    
    jsval result = OBJECT_TO_JSVAL(lexicalParentCursorObj);
    JS_SET_RVAL(context, parameters, result);
    
    return JS_TRUE;
}

JSBool cursor_get_semantic_parent(JSContext* context, uintN argc, jsval* parameters) {
    CursorBinding* cursorBinding;
    CXCursor cursor;
    extract_privates(context, parameters, &cursorBinding, NULL, &cursor);
    
    CXCursor semanticParentCursor = clang_getCursorSemanticParent(cursor);
    if(clang_Cursor_isNull(semanticParentCursor)) {
        JS_SET_RVAL(context, parameters, JSVAL_NULL);
        return JS_TRUE;
    }
    
    JSObject* semanticParentCursorObj = [cursorBinding JSObjectFromCursor: semanticParentCursor
                                                         withPredecessors: nil];
    
    jsval result = OBJECT_TO_JSVAL(semanticParentCursorObj);
    JS_SET_RVAL(context, parameters, result);
    
    return JS_TRUE;
}

JSBool cursor_visit_children(JSContext* context, uintN argc, jsval* parameters) {
    
    // Using JS_ConvertArguments only to test input parameter.
    // Thanks to Jeff Hubbard who answered my question on stackoverflow
    // http://stackoverflow.com/questions/14092952/calling-callback-function-in-spidermonkey-js-enginge
    JSFunction* ignoreFunction;
    if (!JS_ConvertArguments(context, argc, JS_ARGV(cx, parameters), "f", &ignoreFunction))
        return JS_FALSE;
    
    CursorBinding* cursorBinding;
    CXCursor cursor;
    extract_privates(context, parameters, &cursorBinding, NULL, &cursor);
    
    clang_visitChildrenWithBlock(cursor, ^enum CXChildVisitResult(CXCursor childCursor, CXCursor parent) {
        
        JSObject* childCursorObject = [cursorBinding JSObjectFromCursor: childCursor
                                                       withPredecessors: nil];
        
        jsval retVal;
        jsval childVal = OBJECT_TO_JSVAL(childCursorObject);
        
        JS_CallFunctionValue(context, JS_GetGlobalObject(context), *(JS_ARGV(context, parameters)), 1, &childVal, &retVal);
        
        return CXChildVisit_Recurse;
    });
    
    return JS_TRUE;
}

JSBool cursor_get_tokens(JSContext* context, uintN argc, jsval* parameters) {
    CursorBinding* cursorBinding;
    CXCursor cursor;
    extract_privates(context, parameters, &cursorBinding, NULL, &cursor);
    
    JSObject* tokens = [cursorBinding.bindings.tokenBinding tokensJSArrayFromCursor: cursor];
    JS_SET_RVAL(context, parameters, OBJECT_TO_JSVAL(tokens));
    return JS_TRUE;
}

JSBool cursor_is_declaration(JSContext* context, uintN argc, jsval* parameters) {
    CursorBinding* cursorBinding;
    CXCursor cursor;
    extract_privates(context, parameters, &cursorBinding, NULL, &cursor);
    
    bool isDeclaration = clang_isDeclaration(clang_getCursorKind(cursor));
    JS_SET_RVAL(context, parameters, BOOLEAN_TO_JSVAL(isDeclaration));
    return JS_TRUE;
}

JSBool cursor_get_objc_method_declaration(JSContext* context, uintN argc, jsval* parameters) {
    CursorBinding* cursorBinding;
    CXCursor cursor;
    extract_privates(context, parameters, &cursorBinding, NULL, &cursor);
    
    ObjCMethodDeclarationBinding* binding = cursorBinding.bindings.objCMethodDeclarationBinding;
    JSObject* declarationObj = [binding declarationJSObjectFromCursor: cursor];
    
    jsval returnValue = OBJECT_TO_JSVAL(declarationObj);
    JS_SET_RVAL(context, parameters, returnValue);
    
    return JS_TRUE;
}

JSBool cursor_equal(JSContext* context, uintN argc, jsval* parameters) {
    CursorBinding* cursorBinding;
    CXCursor cursor;
    extract_privates(context, parameters, &cursorBinding, NULL, &cursor);
    
    JSObject* anotherCursorObject;
    if (!JS_ConvertArguments(context, argc, JS_ARGV(context, parameters), "o", &anotherCursorObject))
        return JS_FALSE;
    
    CXCursor anotherCursor = [cursorBinding cursorFromJSObject: anotherCursorObject];
    
    bool equals = clang_equalCursors(cursor, anotherCursor);
    JS_SET_RVAL(context, parameters, equals);
    
    return JS_TRUE;
}

JSBool cursor_get_predecessor(JSContext* context, uintN argc, jsval* parameters) {
    CursorBinding* cursorBinding;
    CursorArray* predecessors;
    CXCursor cursor;
    extract_privates(context, parameters, &cursorBinding, &predecessors, &cursor);

    uint32_t distance;
    if (!JS_ConvertArguments(context, argc, JS_ARGV(context, parameters), "u", &distance))
        return JS_FALSE;

    jsval returnValue;
    if(!predecessors || predecessors.length <= distance)
        returnValue = JSVAL_NULL;
    else {
        CXCursor precedingCursor = [predecessors cursorAtIndex: predecessors.length - distance - 1];
        if(clang_Cursor_isNull(precedingCursor))
            returnValue = JSVAL_NULL;
        else {
            JSObject* precedingCursorJS = [cursorBinding JSObjectFromCursor: precedingCursor
                                                           withPredecessors: nil];
            returnValue = OBJECT_TO_JSVAL(precedingCursorJS);
        }
    }
    
    JS_SET_RVAL(context, parameters, returnValue);
    
    return JS_TRUE;
}

static JSFunctionSpec cursor_methods[] = {
    JS_FS("getPredecessor",   cursor_get_predecessor,1,0),
    JS_FS("getLexicalParent", cursor_get_lexical_parent,0,0),
    JS_FS("getSemanticParent",cursor_get_semantic_parent,0,0),
    JS_FS("visitChildren",    cursor_visit_children,1,0),
    JS_FS("getTokens",        cursor_get_tokens,0,0),
    JS_FS("isDeclaration",    cursor_is_declaration,0,0),
    JS_FS("getObjCMethodDeclaration", cursor_get_objc_method_declaration,0,0),
    JS_FS("equal",            cursor_equal,1,0),
    JS_FS_END
};

@implementation CursorBinding

@synthesize bindings       = _bindings,
            jsClass        = _jsClass,
            jsFunctionSpec = _jsFunctionSpec,
            jsPrototype    = _jsPrototype;

#pragma mark - Init&Dealloc

- (id) initWithBindingsCollection:(ClangBindingsCollection*) collection {
    self = [super init];
    if (self) {
        _bindings = collection;
        
        _jsClass  = &cursor_class;
        _jsFunctionSpec = cursor_methods;

        _jsPrototype = JS_InitClass(/* context       */ _bindings.context,
                                    /* global obj    */ JS_GetGlobalObject(_bindings.context),
                                    /* parent proto  */ NULL,
                                    /* class         */ &cursor_class,
                                    /* constructor   */ NULL,
                                    /* nargs         */ 0,
                                    /* property spec */ NULL,
                                    /* function spec */ cursor_methods,
                                    /* static property spec */ NULL,
                                    /* static func spec     */ NULL);
        
        // not sure if must to, but it's definetely safer to 'retain' prototype here.
        // please correct me if we can ommit this.
        JS_AddNamedObjectRoot(_bindings.context, &_jsPrototype, "cursor-prototype");
    }
    return self;
}

- (void)dealloc {
    JS_RemoveObjectRoot(_bindings.context, &_jsPrototype);
    [super dealloc];
}

#pragma mark - Public

- (CXCursor) cursorFromJSObject:(JSObject*) object {
    CXCursor cursorObj;
    
    jsval value;
    JS_GetProperty(_bindings.context, object, "_kind", &value);
    cursorObj.kind  = (enum CXCursorKind)JSVAL_TO_INT(value);
    
    JS_GetProperty(_bindings.context, object, "_xdata", &value);
    cursorObj.xdata = JSVAL_TO_INT(value);
    
    JS_GetProperty(_bindings.context, object, "_data0", &value);
    cursorObj.data[0] = JSVAL_TO_PRIVATE(value);
    
    JS_GetProperty(_bindings.context, object, "_data1", &value);
    cursorObj.data[1] = JSVAL_TO_PRIVATE(value);
    
    JS_GetProperty(_bindings.context, object, "_data2", &value);
    cursorObj.data[2] = JSVAL_TO_PRIVATE(value);
    
    return cursorObj;
}

- (JSObject*) JSObjectFromCursor:(CXCursor) cursor
                withPredecessors:(CursorArray*) predecessors {
    
    JSObject* cursorJSObject = JS_NewObject(_bindings.context, _jsClass, _jsPrototype, NULL);
    
    CXSourceLocation location = clang_getCursorLocation(cursor);
    
    CXFile   file;
    unsigned line, column, offset;
    
    [self storeClangCursorEssentials:cursor intoJSObject:cursorJSObject];
    
    clang_getSpellingLocation(location,&file,&line,&column,&offset);
    
    setJSProperty_UInt(_bindings.context, cursorJSObject, "lineNumber", line);
    setJSProperty_UInt(_bindings.context, cursorJSObject, "column", column);
    setJSProperty_UInt(_bindings.context, cursorJSObject, "offset", offset);
    
    CXString fileName = clang_getFileName(file);
    setJSProperty_CXString(_bindings.context, cursorJSObject, "fileName", fileName);
    clang_disposeString(fileName);
    
    CXString displayName = clang_getCursorDisplayName(cursor);
    setJSProperty_CXString(_bindings.context, cursorJSObject, "displayName", displayName);
    clang_disposeString(displayName);
    
    CXString usr = clang_getCursorUSR(cursor);
    setJSProperty_CXString(_bindings.context, cursorJSObject, "USR", usr);
    clang_disposeString(usr);
    
    CXString spelling = clang_getCursorSpelling(cursor);
    setJSProperty_CXString(_bindings.context, cursorJSObject, "spelling", spelling);
    clang_disposeString(spelling);
    
    enum CXCursorKind cursorKind = clang_getCursorKind(cursor);
    CXString kind = clang_getCursorKindSpelling(cursorKind);
    setJSProperty_CXString(_bindings.context, cursorJSObject, "kind", kind);
    clang_disposeString(kind);
    
    if(!predecessors)
        predecessors = [[[CursorArray alloc] init] autorelease];

    // TODO: make sure predecessors array lives as long as cursor
    //    objc_setAssociatedObject(self,predecessors,predecessors,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    JS_SetPrivate(_bindings.context, cursorJSObject, @{
                  kCursorBindingKey: self,
                  kCursorPredecessorsKey: predecessors
                  });
    
    return cursorJSObject;
}

#pragma mark - Private

- (void) storeClangCursorEssentials:(CXCursor)cursor intoJSObject:(JSObject*) object {
    
    setJSProperty_Int(_bindings.context, object, "_kind", cursor.kind);
    setJSProperty_Int(_bindings.context, object, "_xdata", cursor.xdata);
    setJSProperty_Ptr(_bindings.context, object, "_data0", (void*)cursor.data[0]);
    setJSProperty_Ptr(_bindings.context, object, "_data1", (void*)cursor.data[1]);
    setJSProperty_Ptr(_bindings.context, object, "_data2", (void*)cursor.data[2]);

}

@end


