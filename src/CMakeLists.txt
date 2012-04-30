#set(ARCH i386)
include_directories (${PROJECT_SOURCE_DIR}/llvm-clang-build/include)
link_directories (${PROJECT_SOURCE_DIR}/llvm-clang-build/lib)

add_library (objclint SHARED objclint.cc)

add_definitions (-D_GNU_SOURCE -D__STDC_CONSTANT_MACROS -D__STDC_FORMAT_MACROS -D__STDC_LIMIT_MACROS)

#set_target_properties (objclint PROPERTIES LINK_FLAGS "-Wl -undefined dynamic_lookup -flat_namespace")
set_target_properties (objclint PROPERTIES LINK_FLAGS "-undefined dynamic_lookup -flat_namespace -fno-rtti")

#target_link_libraries (objclint ${PROJECT_SOURCE_DIR}/llvm-clang-build/lib/libclangAST.a ${PROJECT_SOURCE_DIR}/llvm-clang-build/lib/libLLVMCore.a ${PROJECT_SOURCE_DIR}/llvm-clang-build/lib/libLLVMSupport.a ${PROJECT_SOURCE_DIR}/llvm-clang-build/lib/libclangFrontend.a ${PROJECT_SOURCE_DIR}/llvm-clang-build/lib/libclangCodeGen.a ${PROJECT_SOURCE_DIR}/llvm-clang-build/lib/libclangSerialization.a ${PROJECT_SOURCE_DIR}/llvm-clang-build/lib/libclangSema.a ${PROJECT_SOURCE_DIR}/llvm-clang-build/lib/libclangBasic.a ${PROJECT_SOURCE_DIR}/llvm-clang-build/lib/libclangParse.a ${PROJECT_SOURCE_DIR}/llvm-clang-build/lib/libclangLex.a ${PROJECT_SOURCE_DIR}/llvm-clang-build/lib/libclangAnalysis.a)
target_link_libraries (objclint ${PROJECT_SOURCE_DIR}/llvm-clang-build/lib/libclangAST.a ${PROJECT_SOURCE_DIR}/llvm-clang-build/lib/libLLVMCore.a ${PROJECT_SOURCE_DIR}/llvm-clang-build/lib/libLLVMSupport.a ${PROJECT_SOURCE_DIR}/llvm-clang-build/lib/libclangFrontend.a ${PROJECT_SOURCE_DIR}/llvm-clang-build/lib/libclangCodeGen.a ${PROJECT_SOURCE_DIR}/llvm-clang-build/lib/libclangSerialization.a ${PROJECT_SOURCE_DIR}/llvm-clang-build/lib/libclangSema.a ${PROJECT_SOURCE_DIR}/llvm-clang-build/lib/libclangBasic.a ${PROJECT_SOURCE_DIR}/llvm-clang-build/lib/libclangParse.a ${PROJECT_SOURCE_DIR}/llvm-clang-build/lib/libclangLex.a ${PROJECT_SOURCE_DIR}/llvm-clang-build/lib/libclangAnalysis.a)

install (TARGETS objclint DESTINATION ${PROJECT_SOURCE_DIR}/lib/)
