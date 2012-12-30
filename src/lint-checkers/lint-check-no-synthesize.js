if(cursor.kind == "ObjCSynthesizeDecl") {
    lint.reportError("No need for '@synthesize', clang will generate it automatically");
}