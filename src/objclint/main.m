#import <Foundation/Foundation.h>
#include <clang-c/Index.h>

#import "ObjclintCoordinator.h"
#import "ObjclintSession.h"

id<ObjclintCoordinator> aquireObjclintCoordinator() {
    NSConnection* connection = [NSConnection connectionWithRegisteredName: kObjclintServiceName
                                                                     host: nil];
    
    [connection.rootProxy setProtocolForProxy:@protocol(ObjclintCoordinator)];
    return (id<ObjclintCoordinator>) connection.rootProxy;
}

int main(int argc, char *argv[]) {
    // immediately flush stdout
    setvbuf(stdout, NULL, _IONBF, 0);

    @autoreleasepool {
            
        id<ObjclintCoordinator> coordinator = aquireObjclintCoordinator();
        ObjclintSession* session = [[[ObjclintSession alloc] initWithCoordinator: coordinator] autorelease];
               
        CXIndex index = clang_createIndex(0, 0);
        CXTranslationUnit translationUnit = clang_parseTranslationUnit(index, 0,(const char**) argv, argc, 0, 0, CXTranslationUnit_None);
        
        if(translationUnit) {
            [session validateTranslationUnit: translationUnit];
            clang_disposeTranslationUnit(translationUnit);
        }
        clang_disposeIndex(index);
        
        // failed to force XCode ignore build errors and continue build process. just return 0
        return 0;
    }
}