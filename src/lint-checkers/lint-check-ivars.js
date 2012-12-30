if(cursor.kind == "ObjCInterfaceDecl" || cursor.kind == "ObjCImplementationDecl") {
    lint.ivar_check_last_class_decl = lint.displayName;
}
if(cursor.kind == "ObjCIvarDecl") {
    var ivarName = cursor.displayName;
    var startWithUnderscore = ivarName.indexOf("_")==0;
    var firstLetterIsLowercase = ivarName.length >=2 && ivarName.charAt(1).toLowerCase() == ivarName.charAt(1);
    if(!startWithUnderscore || !firstLetterIsLowercase)
        lint.reportError("Class '"+lint.ivar_check_last_class_decl+"' ivar '" + lint.displayName + "' should start with underscore and lowercase letter");
}