if(["ObjCInterfaceDecl","ObjCImplementationDecl"].indexOf(cursor.kind) != -1) {
    if(typeof lint.check_one_class_one_file_declarations_count == "undefined") {
        lint.check_one_class_one_file_declarations_count = {};
        lint.check_one_class_one_file_declarations_count[cursor.fileName] = 1;
    }
    else
        lint.check_one_class_one_file_declarations_count[cursor.fileName]++;
    
    if(lint.check_one_class_one_file_declarations_count[cursor.fileName] == 2)
        lint.reportError("One class declaration in one file only. Interface and Implementation must be in different files");
}