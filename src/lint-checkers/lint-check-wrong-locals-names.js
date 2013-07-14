var wrongNames = ["btn","btn1","nc","vc","vc1","zabor","skrepa","tmp","temp","tmp1","temp1"];

function validateName(varName) {
    if(varName.length==1) {
        // ForStmt(DeclStmt(VarDecl))
        //    1         0
        var parentCursor = cursor.getPredecessor(1);
        if(cursor.kind == "VarDecl" && parentCursor != null && parentCursor.kind == "ForStmt")
            return;
        lint.reportError("Invalid variable name '"+varName+"'. Var name should not be 1 character long");
    }
    else {
        for(var i=0; i<wrongNames.length; i++) {
            if(varName == wrongNames[i]) {
                lint.reportError("Ivalid variable name '"+varName+"'. Var name should not be in the following list ("+ wrongNames+")");
                return;
            }
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
