//
//  JSScriptsLoader.m
//  objclint
//
//  Created by Smirnov on 4/13/13.
//  Copyright (c) 2013 Alexander Smirnov. All rights reserved.
//

#import "JSScriptsLoader.h"

@implementation JSScriptsLoader {
    JSContext*      _context;
    NSMutableArray* _validatorsScripts;
}

- (instancetype) initWithContext:(JSContext*) context
                   scriptsFolder:(NSString*) folder {
    self = [super init];
    if (self) {
        _context = context;
        [self setupValidatorsWithPath: folder];
    }
    return self;
}

- (void)dealloc {
    for(NSValue* scriptObjValue in _validatorsScripts) {
        JSObject** scriptObj = (JSObject**)[scriptObjValue pointerValue];
        JS_RemoveObjectRoot(_context, scriptObj);
        free(scriptObj);
    }
    [_validatorsScripts release];
    [super dealloc];
}

- (void) runScriptsWithResultHandler:(void(^)(jsval))handler {
    for(NSValue* scriptObjValue in _validatorsScripts) {
        JSObject** scriptObj = (JSObject**)[scriptObjValue pointerValue];
        
        jsval result;
        
        JS_ExecuteScript(_context, JS_GetGlobalObject(_context), *scriptObj, &result);
        
        if(handler)
            handler(result);
        
        JS_MaybeGC(_context);
    }
}

#pragma mark - Private

- (void) setupValidatorsWithPath:(NSString*) folderPath {
    @autoreleasepool {
        _validatorsScripts = [[NSMutableArray array] retain];
        
        NSFileManager* fileManager = [NSFileManager defaultManager];
        NSDirectoryEnumerator* dirEnumerator = [fileManager enumeratorAtPath: folderPath];
        
        NSString *filePath;
        while (filePath = [dirEnumerator nextObject]) {
            
            filePath = [folderPath stringByAppendingPathComponent: filePath];
            NSString* fileName = filePath.lastPathComponent;
            
            if([fileName hasSuffix:@".js"]) {

                const char* filePathC = [filePath cStringUsingEncoding:NSUTF8StringEncoding];
                
                // Thanks to Philip from #jsapi irc.mozilla.org
                // JS_AddObjectRoot stores pointer to scriptObject, so it MUST be on heap
                JSObject** scriptObj = (JSObject**)malloc(sizeof(JSObject*));
                *scriptObj = JS_CompileFile(_context, JS_GetGlobalObject(_context), filePathC);
                
                if(NULL == *scriptObj || !JS_AddObjectRoot(_context, scriptObj)) {
                    free(scriptObj);
                    continue;
                }
                
                [_validatorsScripts addObject: [NSValue valueWithPointer: scriptObj]];
            }
        }
    }
}


@end
