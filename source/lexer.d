module lexer;

import token, message;
import std.ascii;

Token[] getTokens(string source, string path = "") {
	Token[] result;
	size_t index, line;
	
	while (source.length > 0) {
		auto tok = getToken(source, index, line);
		// error
		if (tok.kind == TOK.error) {
			message.error(tok.loc, "unknown character " ~ tok.str);
		}
		else {
			tok.loc = LOC(index, line, path);
			result ~= tok;
		}
		
		// drop characters
		if (tok.str.length >= source.length) break;
		else source = source[tok.str.length .. $];
	}
	
	return result;
}

Token getToken(ref string source, ref size_t index, ref size_t line) {
	size_t ptr = 0;
	
	// ignore spaces and comments (TODO)
	while (source.length > 0 && isWhite(source[0])) {
		if (source[0] == '\n') {
			++line;
			index = 0;
		}
		else {
			++index;
		}
		source = source[1 .. $];
	}
	
	Token result;
	
	// end of file
	if (ptr >= source.length) return Token(TOK.eof, "eof", LOC.init);
	
	// identifier or reserved keywords
	else if (source[ptr].isAlpha() || source[ptr] == '_') {
		// get the identifier
		do {
			result.str ~= source[ptr];
			++ptr;
		}
		while (ptr < source.length && (source[ptr].isAlpha() || source[ptr].isDigit() || source[ptr] == '_'));
		
		with (TOK)
		result.kind =
			result.str == "else" ?			else_ :
			result.str == "func" ?			func :
			result.str == "if" ?			if_ :
			result.str == "int32" ?			int32 :
			result.str == "let" ?			let :
			result.str == "return" ?		return_:
			result.str == "__access" ?		access :
			id;
	}
	
	// number literals
	else if (source[ptr].isDigit()) {
		// get the integer number
		do {
			if (source[ptr] != '_') result.str ~= source[ptr];
			++ptr;
		}
		while (ptr < source.length && (source[ptr].isDigit() || source[ptr] == '_'));
		// get the real number (TODO)
		
		result.kind = TOK.int_;
	}
	
	// symbols
	else with (TOK) {
		auto dict = [
			"="  : ass,
			"==" : eq,
			"<"  : ls,
			"<=" : leq,
			">"  : gt,
			">=" : geq,
			"+"  : add,
			"-"  : sub,
			"*"  : mul,
			"/"  : div,
			"%"  : mod,
			"."  : dot,
			":"  : col,
			";"  : semcol,
			","  : com,
			"("  : lpar,
			")"  : rpar,
			"["  : lbra,
			"]"  : rbra,
			"{"  : lblo,
			"}"  : rblo,
		];
		
		// get the longest possible token
		while (result.str ~ source[ptr] in dict) {
			result.str ~= source[ptr];
			++ptr;
			if (ptr >= source.length) break;
		}
		
		if (auto k = result.str in dict) {
			result.kind = *k;
		}
		else {
			result.str ~= source[ptr];
			result.kind = TOK.error;
		}
	}
	
	index += result.str.length;
	return result;
}
