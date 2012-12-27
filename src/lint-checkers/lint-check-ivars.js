if(lint.kind == "ObjCInterfaceDecl" || lint.kind == "ObjCImplementationDecl") {
    lint.ivar_check_last_class_decl = lint.displayName;
}
if(lint.kind == "ObjCIvarDecl") {
    var ivarName = lint.displayName;
    var startWithUnderscore = ivarName.indexOf("_")==0;
    var firstLetterIsLowercase = ivarName.length >=2 && ivarName.charAt(1).toLowerCase() == ivarName.charAt(1);
    if(!startWithUnderscore || !firstLetterIsLowercase)
        lint.reportError("Class '"+lint.ivar_check_last_class_decl+"' ivar '" + lint.displayName + "' should start with underscore and lowercase letter");
}