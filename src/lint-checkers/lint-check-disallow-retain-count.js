if(["MemberRefExpr","ObjCMessageExpr"].indexOf(lint.kind)!=-1 && lint.spelling == "retainCount") {
    lint.reportError("When to use -retainCount? NEVER! http://whentouseretaincount.com/");
}