if(cursor.kind == "ObjCPropertyDecl") {

    var tokens = cursor.getTokens();
    var propertyName = tokens[tokens.length-2].spelling.toLowerCase();

    if(propertyName.indexOf("delegate")!=-1) {

        var retainKeywords = tokens.filter(function(token) {return token.kind=="Identifier" && token.spelling=="retain"});

        if(retainKeywords.length != 0) {
            lint.reportError("Delegate property '"+tokens[tokens.length-2].spelling+"' must not be declared with 'retain' qualifier");
        }
        
    }
}