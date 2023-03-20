module token;

enum TOK : ubyte {
	error = 0,
	eof,
	
	// literals
	id,
	int_,
	real_,
	string_lit,
	
	// reserved keywords
	else_,
	func,
	if_,
	int32,
	let,
	return_,
	
	access,
	
	// symbols
	ass,		// =
	eq,			// ==
	ls,			// <
	leq,		// <=
	gt,			// >
	geq,		// >=
	
	add,		// +
	sub,		// -
	mul,		// *
	div,		// /
	mod,		// %
	
	dot,		// .
	
	col,		// :
	semcol,		// ;
	com,		// ,
	
	lpar,		// (
	rpar,		// )
	lbra,		// [
	rbra,		// ]
	lblo,		// {
	rblo,		// }
	
}

struct LOC {
	size_t index;
	size_t line;
	string path;
	
	string toString() {
		import std.conv: to;
		return "\x1b[1m" ~ path ~ "(" ~ line.to!string ~ ":" ~ index.to!string ~ ")\x1b[0m";
	}
	
	/// a < b means "a precedes b"
	int opCmp(LOC right) {
		alias left = this;
		if (left.line < right.line || (left.line == right.line && left.index < right.index)) return -1;
		else if (left.line == right.line && left.index == right.index) return 0;
		else return 1;
	}
}

struct Token {
	TOK kind;		/// the kind of the token
	string str;		/// the string of the token
	LOC loc;		/// the location of the token in the file
}
