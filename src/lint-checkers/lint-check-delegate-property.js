if(cursor.kind == "ObjCPropertyDecl") {

    var tokens = cursor.getTokens();
    var propertyName = tokens[tokens.length-2].spelling.toLowerCase();
    var propertyDecl = cursor.getObjCPropertyDeclaration();

    if(propertyDecl != null && propertyName.indexOf("delegate")!=-1) {
        if(propertyDecl.isRetaining()) {
            lint.reportError("Delegate property '"+tokens[tokens.length-2].spelling+"' must not be declared with 'retain' or 'strong' qualifier");
        }
        
    }
}
