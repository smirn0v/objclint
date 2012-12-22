#import <Foundation/Foundation.h>
#import "ObjclintSessionManagerProtocol.h"
#include <Index.h>

#if 0
std::string location_description(const CXSourceLocation* location) {
    CXFile file;
    unsigned line;
    unsigned column;
    unsigned offset;
    
    clang_getSpellingLocation(*location,&file,&line,&column,&offset);
    
    CXString fileNameCX = clang_getFileName(file);
    const char* fileNameC = clang_getCString(fileNameCX);
    
    std::ostringstream stringStream;
    
    stringStream << fileNameC << "-" << line << "-" << column << "-" << offset;
    
    clang_disposeString(fileNameCX);
    
    return stringStream.str();
}

bool location_already_analyzed(const string_set& locations, const CXSourceLocation* location) {
    return locations.find(location_description(location)) != locations.end();
}

void mark_location_as_analyzed(string_set& locations, const CXSourceLocation* location) {
    locations.insert(location_description(location));
}

bool is_project_file(const std::string& file_name) {

    char* directory = dir_name(file_name.c_str());
    
    printf("directory: %s\n", directory);
    
    free(directory);
    return true;
}
#endif

enum CXChildVisitResult visitor(CXCursor cursor, CXCursor parent, CXClientData client_data)
{
    
	enum CXCursorKind kind = clang_getCursorKind(cursor);
	CXString spelling = clang_getCursorKindSpelling(kind);
	const char* spellingC = clang_getCString(spelling);
	
	CXSourceLocation location = clang_getCursorLocation(cursor);
    

    //if(location_already_analyzed(*locations, &location))
      //  return CXChildVisit_Continue;

  //  mark_location_as_analyzed(*locations, &location);
    
	CXFile file;
	unsigned line;
	
	clang_getSpellingLocation(location,&file,&line,0,0);
	CXString fileName = clang_getFileName(file);
	const char* fileNameC = clang_getCString(fileName);
	
	enum CXLinkageKind linkageKind = clang_getCursorLinkage(cursor);

    	clang_disposeString(fileName);
	clang_disposeString(spelling);
	return CXChildVisit_Recurse;
}

int main(int argc, char *argv[]) {
    setvbuf(stdout, NULL, _IONBF, 0);
    
    @autoreleasepool {
#if 0
        CXIndex Index = clang_createIndex(0, 0);
        CXTranslationUnit TU = clang_parseTranslationUnit(Index, 0, argv, argc, 0, 0, CXTranslationUnit_None);
        
        if(TU) {
            CXCursor cursor = clang_getTranslationUnitCursor(TU);

            clang_visitChildren(cursor, &visitor, NULL);
        
            clang_disposeTranslationUnit(TU);
        }
        clang_disposeIndex(Index);
#endif
        NSConnection* connection = [NSConnection connectionWithRegisteredName:@"ru.borsch-lab.objclint.coordinator"
                                                                         host:nil];

        
        id<ObjclintSessionManagerProtocol> sessionManager = nil;
        NSLog(@"Connection = %@", connection);
        
        [connection.rootProxy setProtocolForProxy:@protocol(ObjclintSessionManagerProtocol)];
        sessionManager = connection.rootProxy;
        
        NSLog(@"sessionManager = %@", sessionManager);
        
        [sessionManager markLocation:@"sdfdf" checkedForProjectIdentity:@"sdfsdf"];
        
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
