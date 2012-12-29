if(lint.kind == "ObjCPropertyDecl") {

    var propertyName = lint.tokens[lint.tokens.length-2].spelling.toLowerCase();

    if(propertyName.indexOf("delegate")!=-1) {

        var retainKeywords = lint.tokens.filter(function(token) {return token.kind=="Identifier" && token.spelling=="retain"});

        if(retainKeywords.length != 0) {
            lint.reportError("Delegate property '"+lint.tokens[lint.tokens.length-2].spelling+"' must not be declared with 'retain' qualifier");
        }
        
    }
}