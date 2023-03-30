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
	
	void nextChar() {
		if (source.length == 0) return;
		if (source[0] == '\n') index = 0, ++line;
		else ++index;
		source = source[1 .. $];
	}
	bool lookahead(char c) {
		if (source.length >= 2) return source[1] == c;
		else return false;
	}
	// ignore spaces and comment
	while (1) {
		// spaces
		while (source.length > 0 && isWhite(source[0]))
			nextChar();
			
		// not a comment
		if (source.length == 0 || source[0] != '/') break;
		
		// one line comment
		else if (lookahead('/')) {
			nextChar(); nextChar();	 // get rid of //
			while (source.length > 0 && source[0] != '\n')
				nextChar();
		}
		
		// multiple line comment
		else if (lookahead('*')) {
			nextChar(); nextChar();	 // get rid of /*
			while (source.length >= 2 && !(source[0] == '*' && source[1] == '/'))
				nextChar();
			// (TODO) not closed by */ error
			//if (source.length <= 1) {  }
			if (source.length >= 2) { nextChar(); nextChar(); }	 // get rid of */
		}
		
		// nested comment
		else if (lookahead('+')) {
			nextChar(); nextChar(); // get rid of /
			uint comment_depth = 1;
			while (comment_depth > 0 && source.length > 0) {
				if	  (source[0] == '+' && lookahead('/')) {
					--comment_depth;
					nextChar(); nextChar();	 // get rid of +/
				}
				else if (source[0] == '/' && lookahead('+')) {
					++comment_depth;
					nextChar(); nextChar();	 // get rid of /+
				}
				else nextChar();
			}
		}
		
		else break;
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
			result.str == "int64" ?			int64 :
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
			"&"  : amp,
			"\\" : bs,
			"->" : arrow,
			"=>" : mapsto,
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
