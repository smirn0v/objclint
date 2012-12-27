/*
lint.log("-----------------------------");
lint.log("line:"+lint.lineNumber);
lint.log("kind:"+lint.kind);
lint.log("displayName:"+lint.displayName);

lint.tokens.map( function(token) {
    lint.log(token.kind + " " + token.spelling);
});

lint.log("-----------------------------");
*/
function reportError() {
    lint.reportError("'{' should be on the same line with previous expression/statement");
}

var supportedKinds = [
                      "ObjCInterfaceDecl",
                      "FunctionDecl",
                      "ObjCImplementationDecl",
                      "IfStmt",
                      "SwitchStmt",
                      "WhileStmt",
                      "DoStmt",
                      "ForStmt",
                      "ObjCAutoreleasePoolStmt"];

if(supportedKinds.indexOf(lint.kind)!=-1) {
    open_braces = lint.tokens.filter(function(token) {return token.kind=="Punctuation" && token.spelling=="{";})
    if(open_braces.length > 0) {
        if(lint.tokens[0].lineNumber != open_braces[0].lineNumber)
            reportError();
    }
}