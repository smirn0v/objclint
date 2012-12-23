#import <Foundation/Foundation.h>
#import "ObjclintSessionManagerProtocol.h"
#include <Index.h>

NSString* filePathForLocation(const CXSourceLocation* location) {
    CXFile file;
    clang_getSpellingLocation(*location, &file, NULL, NULL, NULL);
    CXString fileNameCX = clang_getFileName(file);
    const char* fileNameC = clang_getCString(fileNameCX);
    
    NSString* filePath = [NSString stringWithFormat:@"%s",fileNameC];
    
    clang_disposeString(fileNameCX);
    
    return filePath;
}

NSString* locationDescription(const CXSourceLocation* location) {
    CXFile file;
    unsigned line;
    unsigned column;
    unsigned offset;
    
    clang_getSpellingLocation(*location,&file,&line,&column,&offset);
    
    CXString fileNameCX = clang_getFileName(file);
    const char* fileNameC = clang_getCString(fileNameCX);
    
    NSMutableString* locationDescription = [NSMutableString string];
    [locationDescription appendFormat:@"%s-", fileNameC];
    [locationDescription appendFormat:@"%u-%u-%u",line,column,offset];
    
    clang_disposeString(fileNameCX);
    
    return locationDescription;
}

NSString* projectPath() {
    static NSString* currentDirPath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        currentDirPath = [[[NSFileManager defaultManager] currentDirectoryPath] retain];
    });
    
    return currentDirPath;
}

BOOL isLocationBelongsToProject(const CXSourceLocation* location) {
    return [filePathForLocation(location) rangeOfString: projectPath()].location == 0;
}

BOOL isLocationAlreadyChecked(const CXSourceLocation* location, id<ObjclintSessionManagerProtocol> sessionManager) {
    static NSMutableDictionary* paths = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        paths = @{}.mutableCopy;
    });
    
    if(NO == isLocationBelongsToProject(location))
        return YES;
    
    NSString* filePath = filePathForLocation(location);
    
    if(!filePath)
        return YES;
    
    NSNumber* status = paths[filePath];
    
    if(!status) {
        NSNumber* coordinatorStatus = @([sessionManager checkIfLocation:filePath wasCheckedForProjectIdentity:projectPath()]);
        if(coordinatorStatus.boolValue) {
            paths[filePath] = @YES; // already checked
        } else {
            // we will handle it
            [sessionManager markLocation:filePath checkedForProjectIdentity:projectPath()];
            // locally treat it as unchecked
            paths[filePath] = @NO;
        }
    }
    
    return status.boolValue;
}

enum CXChildVisitResult visitor(CXCursor cursor, CXCursor parent, CXClientData client_data) {
    
    id<ObjclintSessionManagerProtocol> sessionManager = client_data;

	CXSourceLocation location = clang_getCursorLocation(cursor);

    NSString* locationDescriptionStr = locationDescription(&location);
    
    if(isLocationAlreadyChecked(&location, sessionManager)) {
        return CXChildVisit_Continue;
    }
    
    [sessionManager markLocation:locationDescriptionStr
       checkedForProjectIdentity:projectPath()];
    

    CXString spelling = clang_getCursorSpelling(cursor);
    const char* spellingC = clang_getCString(spelling);
    NSLog(@"%@ - %s",locationDescriptionStr,spellingC);
    
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
