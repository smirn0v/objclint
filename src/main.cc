#include <Index.h>
#include <stdio.h>

enum CXChildVisitResult visitor(CXCursor cursor, CXCursor parent, CXClientData client_data)
{
	enum CXCursorKind kind = clang_getCursorKind(cursor);
	CXString spelling = clang_getCursorKindSpelling(kind);
	const char* spellingC = clang_getCString(spelling);
	
	CXSourceLocation location = clang_getCursorLocation(cursor);
	CXFile file;
	unsigned line;
	
	clang_getSpellingLocation(location,&file,&line,0,0);
	CXString fileName = clang_getFileName(file);
	const char* fileNameC = clang_getCString(fileName);
	
	enum CXLinkageKind linkageKind = clang_getCursorLinkage(cursor);
	
	printf("%s[%d,linkage = %d]: %s\n",fileNameC,line,linkageKind,spellingC);
	clang_disposeString(fileName);
	clang_disposeString(spelling);
	return CXChildVisit_Recurse;
}

int main(int argc, char *argv[]) {
    CXIndex Index = clang_createIndex(0, 0);
    CXTranslationUnit TU = clang_parseTranslationUnit(Index, 0, argv, argc, 0, 0, CXTranslationUnit_None);
	
	CXCursor cursor = clang_getTranslationUnitCursor(TU);
	
    clang_visitChildren(cursor, &visitor, NULL);
	
    clang_disposeTranslationUnit(TU);
    clang_disposeIndex(Index);
    return 0;
}

#if 0
CXDiagnostic Diag = clang_getDiagnostic(TU, I);
      CXString String = clang_formatDiagnostic(Diag, 
                                             clang_defaultDiagnosticDisplayOptions());
          printf("!!!!!!!! %s\n", clang_getCString(String));
              clang_disposeString(String);
#endif
