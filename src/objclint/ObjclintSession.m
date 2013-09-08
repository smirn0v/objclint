//
//  objclint
//
//  Created by Alexander Smirnov on 1/19/13.
//  Copyright (c) 2013 Alexander Smirnov. All rights reserved.
//

#import "ObjclintSession.h"

#import "ClangBindingsCollection.h"
#import "CursorBinding.h"
#import "ObjclintIssue.h"
#import "LintBinding.h"
#import "JSEnvironment.h"
#import "JSError.h"
#import "JSScriptsLoader.h"

#include "clang-utils.h"
#include "clang-js-utils.h"

@interface ObjclintSession()<JSEnvironmentDelegate, LintBindingDelegate>

@end

@implementation ObjclintSession {
    id<ObjclintCoordinator> _coordinator;
    ClangBindingsCollection* _clangBindings;
    LintBinding*             _lintBinding;
    JSEnvironment*           _jsEnvironment;
    JSScriptsLoader*         _scriptsLoader;
    JSObject*                _lintObject;
    CXCursor                 _currentCursor;
    NSDictionary*            _configuration;
    NSString*                _projectPath;
    NSMutableDictionary*     _checkedPaths;
    BOOL                     _errorOccured;
}

#pragma mark - Init&Dealloc

- (id) initWithCoordinator:(id<ObjclintCoordinator>) coordinator {
    self = [super init];
    if (self) {
        _coordinator    = [coordinator retain];
        _projectPath    = [[[NSFileManager defaultManager] currentDirectoryPath] retain];
        _configuration  = [[_coordinator configurationForProjectIdentity: _projectPath] retain];
        _checkedPaths   = [[NSMutableDictionary alloc] init];
        
        NSArray* paths = [coordinator configurationForProjectIdentity: _projectPath][kObjclintConfigurationLintsDirs];

        //TODO: use all paths
        //TODO: use jsEnv instead of context/runtime. don't use 'runtime' at all
        _jsEnvironment = [[JSEnvironment alloc] init];
        
        _clangBindings = [[ClangBindingsCollection alloc] initWithContext: _jsEnvironment.context];
        
        _lintBinding   = [[LintBinding alloc] initWithContext: _jsEnvironment.context];
        
        _scriptsLoader = [[JSScriptsLoader alloc] initWithContext: _jsEnvironment.context
                                                    scriptsFolder: paths[0]];
        
        _lintObject = [_lintBinding createLintObject];
        
        _lintBinding.delegate = self;
    }
    return self;
}

- (void)dealloc {
    [_scriptsLoader      release];
    [_lintBinding        release];
    [_clangBindings      release];
    [_jsEnvironment      release];
    [_coordinator        release];
    [_configuration      release];
    [_projectPath        release];
    [_checkedPaths       release];
    [super dealloc];
}

#pragma mark - Public

- (BOOL) validateTranslationUnit:(CXTranslationUnit) translationUnit {
    _errorOccured = NO;
    CXCursor cursor = clang_getTranslationUnitCursor(translationUnit);
    CursorArray* predecessors = [[[CursorArray alloc] init] autorelease];
    
    [self visitCursor: cursor withPredecessors:predecessors visitCurrentCursor:NO];
    
    return !_errorOccured;
}

- (void) visitCursor:(CXCursor) cursor
    withPredecessors:(CursorArray*) predecessors
  visitCurrentCursor:(BOOL) visitCurrentCursor {
    
    BOOL visitChilds = YES;

    if(visitCurrentCursor)
        [self validateCursor: cursor withPredecessors: predecessors visitChilds: &visitChilds];
    
    if(!visitChilds)
        return;
    
    [predecessors addCursor: cursor];
    clang_visitChildrenWithBlock(cursor, ^enum CXChildVisitResult(CXCursor child, CXCursor currentCursor) {
        @autoreleasepool {
            [self visitCursor:child withPredecessors:predecessors visitCurrentCursor:YES];
            return CXChildVisit_Continue;
        }
    });
    [predecessors removeCursor: cursor];
}

#pragma mark - JSEnvironmentDelegate

- (void) JSEnvironment:(JSEnvironment*) env errorOccured:(JSError*) error {
    ObjclintIssue* issue = [[ObjclintIssue new] autorelease];
    issue.issueType   = ObjclintIssueType_JSError;
    issue.description = error.message;
    issue.fileName    = error.filename;
    
    [_coordinator reportIssue: issue forProjectIdentity: _projectPath];
}

#pragma mark - LintBindingDelegate

- (void) lintObject:(JSObject*) lintObject issue:(ObjclintIssue*) issue {
    _errorOccured = YES;
    [_coordinator reportIssue: issue forProjectIdentity: _projectPath];
}

- (CXCursor) cursorForLintObject:(JSObject*) lintObject {
    return _currentCursor;
}

#pragma mark - Private

- (void) validateCursor:(CXCursor) cursor
       withPredecessors:(CursorArray*) predecessors
            visitChilds:(BOOL*) visitChilds {

    BOOL safetyTempVar;
    if(!visitChilds)
        visitChilds = &safetyTempVar;
    
    NSString* filePath = [self filePathForCursor: cursor];
    
    if(![self cursorBelongsToProject: cursor] || !filePath) {
        *visitChilds = NO;
        return;
    }
    
    if(!_checkedPaths[filePath]) {
        BOOL coordinatorAlreadyChecked = [_coordinator checkIfLocation: filePath
                                          wasCheckedForProjectIdentity: _projectPath];
        
        BOOL ignored = [self isIgnoredFilePath: filePath];
        
        if(coordinatorAlreadyChecked || ignored) {
            _checkedPaths[filePath] = @YES;
        } else {
            // mark as checked globally
            [_coordinator markLocation: filePath
             checkedForProjectIdentity: _projectPath];
            
            // but fully validate in this session
            _checkedPaths[filePath] = @NO;
        }
    }
    
    NSNumber* alreadyChecked = _checkedPaths[filePath];
    
    *visitChilds = !alreadyChecked.boolValue;

    if(!alreadyChecked.boolValue) {
        _currentCursor = cursor;
        JSObject* cursorObject = [_clangBindings.cursorBinding JSObjectFromCursor: cursor
                                                                 withPredecessors: predecessors];
        setJSProperty_JSObject(_jsEnvironment.context, _jsEnvironment.global, "cursor", cursorObject);
        [_scriptsLoader runScriptsWithResultHandler:^(jsval value) {
            
        }];
    }
}

- (BOOL) isIgnoredFilePath:(NSString*) filePath {
    __block BOOL ignored = NO;
    
    NSArray* ignores = _configuration[kObjclintConfigurationIgnores];

    [ignores enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSString* ignoredPathRegex = [_projectPath stringByAppendingPathComponent: obj];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", ignoredPathRegex];

        ignored = ignored || [predicate evaluateWithObject: filePath];
        *stop = ignored;
    }];
    
    return ignored;
}

- (BOOL) cursorBelongsToProject:(CXCursor) cursor {
    NSString* filePath = [self filePathForCursor: cursor];
    
    return filePath!=nil && [filePath rangeOfString: _projectPath].location == 0;
}

- (NSString*) filePathForCursor:(CXCursor) cursor {
    char* filePathC = copyCursorFilePath(cursor);
    if(filePathC)
        return [[[NSString alloc] initWithBytesNoCopy: filePathC
                                               length: strlen(filePathC)
                                             encoding: NSUTF8StringEncoding
                                         freeWhenDone: YES] autorelease];
    return nil;
}

@end
