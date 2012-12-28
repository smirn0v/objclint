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

if(supportedKinds.indexOf(lint.kind)!=-1) {
    open_braces = lint.tokens.filter(function(token) {return token.kind=="Punctuation" && token.spelling=="{";})
    if(open_braces.length > 0) {
        if(lint.tokens[0].lineNumber != open_braces[0].lineNumber)
            lint.reportError("'{' should be on the same line with previous expression/statement");
    }
}