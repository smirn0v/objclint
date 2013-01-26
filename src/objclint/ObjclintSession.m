//
//  objclint
//
//  Created by Alexander Smirnov on 1/19/13.
//  Copyright (c) 2013 Alexander Smirnov. All rights reserved.
//

#import "ObjclintSession.h"
#import "JSValidatorsRunner.h"
#import "ClangUtils.h"

@implementation ObjclintSession {
    id<ObjclintCoordinator> _coordinator;
    JSValidatorsRunner*     _jsValidatorsRunner;
    NSString*               _projectPath;
    NSMutableDictionary*    _checkedPaths;
}

#pragma mark - Init&Dealloc

- (id) initWithCoordinator:(id<ObjclintCoordinator>) coordinator {
    self = [super init];
    if (self) {
        _coordinator  = [coordinator retain];
        _projectPath  = [[[NSFileManager defaultManager] currentDirectoryPath] retain];
        _checkedPaths = [[NSMutableDictionary alloc] init];
        
        NSString* lintsPath = [coordinator lintJSValidatorsFolderPathForProjectIdentity: _projectPath];
        _jsValidatorsRunner = [[JSValidatorsRunner alloc] initWithLintsFolderPath: lintsPath];
    }
    return self;
}

- (void)dealloc {
    [_coordinator        release];
    [_projectPath        release];
    [_checkedPaths       release];
    [_jsValidatorsRunner release];
    [super dealloc];
}

#pragma mark - Public

- (BOOL) validateTranslationUnit:(CXTranslationUnit) translationUnit {
    CXCursor cursor = clang_getTranslationUnitCursor(translationUnit);
    
    clang_visitChildrenWithBlock(cursor, ^enum CXChildVisitResult(CXCursor cursor, CXCursor parent) {
        @autoreleasepool {
            
            BOOL visitChilds = NO;
            [self validateCursor: cursor visitChilds: &visitChilds];
            
            if(visitChilds)
                return CXChildVisit_Recurse;
            
            return CXChildVisit_Continue;
            
        }
    });
    
    return !_jsValidatorsRunner.errorsOccured;
}

#pragma mark - Private

- (void) validateCursor:(CXCursor) cursor visitChilds:(BOOL*) visitChilds {
    BOOL safetyTempVar;
    if(!visitChilds)
        visitChilds = &safetyTempVar;
    
    NSString* filePath = [ClangUtils filePathForCursor: cursor];
    
    if(![self cursorBelongsToProject: cursor] || !filePath) {
        *visitChilds = NO;
        return;
    }
    
    if(!_checkedPaths[filePath]) {
        BOOL coordinatorStatus = [_coordinator checkIfLocation: filePath
                                  wasCheckedForProjectIdentity: _projectPath];
        
        if(coordinatorStatus) {
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
        [_jsValidatorsRunner runValidatorsForCursor: cursor];
    }
}

- (BOOL) cursorBelongsToProject:(CXCursor) cursor {
    NSString* filePath = [ClangUtils filePathForCursor: cursor];
    
    return filePath!=nil && [filePath rangeOfString: _projectPath].location == 0;
}

@end
