#import <Foundation/Foundation.h>
#import "ObjclintSessionManagerProtocol.h"
#import "ClangUtils.h"
#import "LintJSValidatorsRuntime.h"
#include "clang-c/Index.h"

static LintJSValidatorsRuntime* jsRuntime = nil;

BOOL isCursorAlreadyChecked(CXCursor cursor, id<ObjclintSessionManagerProtocol> sessionManager) {
    static NSMutableDictionary* paths = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        paths = @{}.mutableCopy;
    });

    if(NO == [ClangUtils cursorBelongsToProject: cursor])
        return YES;
    
    NSString* filePath = [ClangUtils filePathForCursor: cursor];
    
    if(!filePath)
        return YES;
    
    NSNumber* status = paths[filePath];
    
    if(!status) {
        NSNumber* coordinatorStatus = @([sessionManager checkIfLocation:filePath
                                           wasCheckedForProjectIdentity:ClangUtils.projectPath]);
        if(coordinatorStatus.boolValue) {
            paths[filePath] = @YES; // already checked
        } else {
            // we will handle it
            [sessionManager markLocation:filePath
               checkedForProjectIdentity:ClangUtils.projectPath];
            
            // locally treat it as unchecked
            paths[filePath] = @NO;
        }
    }
    
    return status.boolValue;
}

enum CXChildVisitResult visitor(CXCursor cursor, CXCursor parent, CXClientData client_data) {
    @autoreleasepool {
        
        id<ObjclintSessionManagerProtocol> sessionManager = client_data;
        
        if(!jsRuntime) {
            jsRuntime = [[LintJSValidatorsRuntime runtimeWithLintsFolderPath: [sessionManager lintJSValidatorsFolderPathForProjectIdentity: [ClangUtils projectPath]]] retain];
        }

        if(isCursorAlreadyChecked(cursor, sessionManager)) {
            return CXChildVisit_Continue;
        }

        [jsRuntime runValidatorsForCursor: cursor];

        return CXChildVisit_Recurse;
    }
}

id<ObjclintSessionManagerProtocol> aquireSessionManager() {
    NSConnection* connection = [[NSConnection connectionWithRegisteredName: @"ru.borsch-lab.objclint.coordinator"
                                                                      host: nil] autorelease];
    
    [connection.rootProxy setProtocolForProxy:@protocol(ObjclintSessionManagerProtocol)];
    return (id<ObjclintSessionManagerProtocol>) connection.rootProxy;
}

int main(int argc, char *argv[]) {
    // immediately flush stdout
    setvbuf(stdout, NULL, _IONBF, 0);
    
    @autoreleasepool {

        CXIndex index = clang_createIndex(0, 0);
        CXTranslationUnit translationUnit = clang_parseTranslationUnit(index, 0,(const char**) argv, argc, 0, 0, CXTranslationUnit_None);
        
        if(translationUnit) {
            CXCursor cursor = clang_getTranslationUnitCursor(translationUnit);
            
            clang_visitChildren(cursor, &visitor, aquireSessionManager());
        
            clang_disposeTranslationUnit(translationUnit);
        }
        clang_disposeIndex(index);
        
    }
    
    return jsRuntime.errorsOccured ? 1 : 0;
}
