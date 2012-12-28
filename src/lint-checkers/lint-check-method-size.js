var supportedKinds = ["FunctionDecl",
                      "ObjCInstanceMethodDecl",
                      "ObjCClassMethodDecl"];

if(supportedKinds.indexOf(lint.kind)!=-1) {
    var size = lint.tokens[lint.tokens.length-1].lineNumber-lint.tokens[0].lineNumber;
    if(size >= 40) {
        lint.reportError("Method/Function declaration must not exceed 40 lines");
    }
}