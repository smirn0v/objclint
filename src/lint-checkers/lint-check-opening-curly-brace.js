var supportedKinds = [
                      "ObjCInterfaceDecl",
                      "FunctionDecl",
                      "ObjCImplementationDecl",
                      "IfStmt",
                      "SwitchStmt",
                      "WhileStmt",
                      "DoStmt",
                      "ForStmt",
                      "ObjCAutoreleasePoolStmt",
                      "ObjCInstanceMethodDecl",
                      "ObjCClassMethodDecl",
                      "ObjCAtTryStmt",
                      "ObjCAtCatchStmt",
                      "ObjCAtFinallyStmt",
                      "ObjCAtSynchronizedStmt"];

if(supportedKinds.indexOf(cursor.kind)!=-1) {
    var tokens = cursor.getTokens();
    open_braces = tokens.filter(function(token) {return token.kind=="Punctuation" && token.spelling=="{";})
    if(open_braces.length > 0) {
        if(tokens[0].lineNumber != open_braces[0].lineNumber) {
            var semanticParent = open_braces[0].cursor.getSemanticParent();
            if((semanticParent != null && semanticParent.equal(cursor)) || open_braces[0].cursor.equal(cursor)) {
                lint.reportError("'{' should be on the same line with previous expression/statement");
            }
        }
    }
}