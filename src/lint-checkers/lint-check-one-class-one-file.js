if(["ObjCInterfaceDecl","ObjCImplementationDecl"].indexOf(lint.kind) != -1) {
    if(typeof lint.check_one_class_one_file_declarations_count == "undefined") {
        lint.check_one_class_one_file_declarations_count = {};
        lint.check_one_class_one_file_declarations_count[lint.fileName] = 1;
    }
    else
        lint.check_one_class_one_file_declarations_count[lint.fileName]++;
    
    if(lint.check_one_class_one_file_declarations_count[lint.fileName] == 2)
        lint.reportError("One class declaration in one file only. Interface and Implementation must be in different files");
}