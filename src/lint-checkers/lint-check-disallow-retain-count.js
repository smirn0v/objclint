if(["MemberRefExpr","ObjCMessageExpr"].indexOf(cursor.kind)!=-1 && cursor.spelling == "retainCount") {
    lint.reportError("When to use -retainCount? NEVER! http://whentouseretaincount.com/");
}