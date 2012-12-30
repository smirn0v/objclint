var targetKinds = ["ObjCInstanceMethodDecl","ObjCClassMethodDecl"];

if(targetKinds.indexOf(cursor.kind)!=-1 && !cursor.isSynthesizedMethod && !cursor.declarationHasBody) {
    var wrong = cursor.spelling.toLowerCase().indexOf("set")==0 ||
                cursor.spelling.toLowerCase().indexOf("get")==0;
    
    if(wrong)
        lint.reportError("Method name("+cursor.spelling+") should not start with 'get' or 'set'");
}