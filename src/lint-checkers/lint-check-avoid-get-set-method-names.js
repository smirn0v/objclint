var targetKinds = ["ObjCInstanceMethodDecl","ObjCClassMethodDecl"];

if(targetKinds.indexOf(lint.kind)!=-1 && !lint.isSynthesizedMethod && !lint.declarationHasBody) {
    var wrong = lint.spelling.toLowerCase().indexOf("set")==0 ||
                lint.spelling.toLowerCase().indexOf("get")==0;
    
    if(wrong)
        lint.reportError("Method name("+lint.spelling+") should not start with 'get' or 'set'");
}