if(cursor.kind == "ObjCAtThrowStmt") {
    lint.reportError("Avoid using @throw");
}