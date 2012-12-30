var supportedKinds = ["FunctionDecl",
                      "ObjCInstanceMethodDecl",
                      "ObjCClassMethodDecl"];

if(supportedKinds.indexOf(cursor.kind)!=-1) {
    var tokens = cursor.getTokens();
    var size = tokens[tokens.length-1].lineNumber-tokens[0].lineNumber;
    if(size >= 40) {
        lint.reportError("Method/Function declaration must not exceed 40 lines");
    }
}