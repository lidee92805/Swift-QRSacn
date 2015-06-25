var LDHExtension = function() {};

LDHExtension.prototype = {
	run: function(arguments) {
		arguments.completionFunction({"baseURI" : document.baseURI});
	}
}

var ExtensionPreprocessingJS = new LDHExtension;