#import <Foundation/Foundation.h>
#include <clang-c/Index.h>

#import "ObjclintCoordinator.h"
#import "ObjclintSession.h"

id<ObjclintCoordinator> aquireObjclintCoordinator() {
    NSConnection* connection = [[NSConnection connectionWithRegisteredName: @"ru.borsch-lab.objclint.coordinator"
                                                                      host: nil] autorelease];
    
    [connection.rootProxy setProtocolForProxy:@protocol(ObjclintCoordinator)];
    return (id<ObjclintCoordinator>) connection.rootProxy;
}

int main(int argc, char *argv[]) {
    // immediately flush stdout
    setvbuf(stdout, NULL, _IONBF, 0);
    
    @autoreleasepool {
            
        id<ObjclintCoordinator> coordinator = aquireObjclintCoordinator();
        ObjclintSession* session = [[ObjclintSession alloc] initWithCoordinator: coordinator];
        
        BOOL successfullValidation = NO;
               
        CXIndex index = clang_createIndex(0, 0);
        CXTranslationUnit translationUnit = clang_parseTranslationUnit(index, 0,(const char**) argv, argc, 0, 0, CXTranslationUnit_None);
        
        if(translationUnit) {
            successfullValidation = [session validateTranslationUnit: translationUnit];
            clang_disposeTranslationUnit(translationUnit);
        }
        clang_disposeIndex(index);
            
        
        return successfullValidation ? 0 : 1;
    }
}