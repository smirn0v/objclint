var wrongNames = ["btn","nc","vc","zabor","skrepa","tmp","temp"];

function validateName(varName) {
    if(varName.length==1) {
        lint.reportError("Invalid variable name '"+varName+"'. Var name should not be 1 character long");
        return;
    }
    for(var i=0; i<wrongNames.length; i++) {
        if(varName.indexOf(wrongNames[i]) == 0) {
            lint.reportError("Ivalid variable name '"+varName+"'. Var name should not be in the following list ("+ wrongNames+")");
            return;
        }
    }
}

if(cursor.kind=="ObjCIvarDecl") {
    if(cursor.displayName.indexOf("_") == 0)
        validateName(cursor.displayName.substring(1));
    else
        validateName(cursor.displayName);
}

if(["VarDecl","ParmDecl"].indexOf(cursor.kind) != -1) {
    validateName(cursor.displayName);
}