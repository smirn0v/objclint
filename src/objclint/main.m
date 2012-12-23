#import <Foundation/Foundation.h>
#import "ObjclintSessionManagerProtocol.h"
#import "ClangUtils.h"
#import "ClangSpellingLocation.h"
#include <Index.h>

BOOL isLocationAlreadyChecked(const CXSourceLocation* location, id<ObjclintSessionManagerProtocol> sessionManager) {
    static NSMutableDictionary* paths = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        paths = @{}.mutableCopy;
    });

    if(NO == [ClangUtils locationBelongsToProject: location])
        return YES;
    
    ClangSpellingLocation* spellingLocation = [ClangUtils spellingLocationForSourceLocation: location];
    
    if(!spellingLocation.filePath)
        return YES;
    
    NSNumber* status = paths[spellingLocation.filePath];
    
    if(!status) {
        NSNumber* coordinatorStatus = @([sessionManager checkIfLocation:spellingLocation.filePath
                                           wasCheckedForProjectIdentity:ClangUtils.projectPath]);
        if(coordinatorStatus.boolValue) {
            paths[spellingLocation.filePath] = @YES; // already checked
        } else {
            // we will handle it
            [sessionManager markLocation:spellingLocation.filePath
               checkedForProjectIdentity:ClangUtils.projectPath];
            
            // locally treat it as unchecked
            paths[spellingLocation.filePath] = @NO;
        }
    }
    
    return status.boolValue;
}

enum CXChildVisitResult visitor(CXCursor cursor, CXCursor parent, CXClientData client_data) {
    
    id<ObjclintSessionManagerProtocol> sessionManager = client_data;

	CXSourceLocation location = clang_getCursorLocation(cursor);

    if(isLocationAlreadyChecked(&location, sessionManager)) {
        return CXChildVisit_Continue;
    }

    CXString spelling = clang_getCursorSpelling(cursor);
    const char* spellingC = clang_getCString(spelling);
    NSLog(@"%@ - %s",[ClangUtils spellingLocationForSourceLocation:&location],spellingC);
    
    clang_disposeString(spelling);

	return CXChildVisit_Recurse;
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
    
    return 0;
}

#if 0
CXDiagnostic Diag = clang_getDiagnostic(TU, I);
      CXString String = clang_formatDiagnostic(Diag, 
                                             clang_defaultDiagnosticDisplayOptions());
          printf("!!!!!!!! %s\n", clang_getCString(String));
              clang_disposeString(String);
#endif
