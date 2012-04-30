include_directories (${PROJECT_SOURCE_DIR}/llvm-clang-build/include)
link_directories (${PROJECT_SOURCE_DIR}/llvm-clang-build/lib)

add_library (objclint SHARED objclint.cc)

add_definitions (-D_GNU_SOURCE -D__STDC_CONSTANT_MACROS -D__STDC_FORMAT_MACROS -D__STDC_LIMIT_MACROS)

set_target_properties (objclint PROPERTIES LINK_FLAGS "-Wl,-undefined,dynamic_lookup,-flat_namespace")
target_link_libraries (objclint clangAST.a LLVMCore LLVMSupport clangFrontend clangCodeGen clangSerialization clangSema clangBasic clangParse clangLex clangAnalysis)

install (TARGETS objclint DESTINATION ${PROJECT_SOURCE_DIR}/lib/)
