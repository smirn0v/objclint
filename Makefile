CLANG_LEVEL := ../..
LIBRARYNAME = objclint

LINK_LIBS_IN_SHARED = 0
SHARED_LIBRARY = 1

include $(CLANG_LEVEL)/Makefile

LDFLAGS=-Wl,-undefined,dynamic_lookup,-flat_namespace,-lclangAST,-lLLVMCore,-lLLVMSupport,-lclangFrontend,-lclangCodeGen,-lclangSerialization,-lclangSema,-lclangBasic,-lclangParse,-lclangLex,-lclangAnalysis

