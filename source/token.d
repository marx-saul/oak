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
	access,
	else_,
	func,
	if_,
	int32,
	int64,
	let,
	return_,
	struct_,
	
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
	
	amp,		// &
	
	bs,			// \
	
	arrow,		// ->
	mapsto,		// =>
	
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

string toString(TOK k) {
	with (TOK)
	final switch (k) {
	case error: return "ERROR";
	case eof: return "EOF";
	
	// literals
	case id: return "ID";
	case int_: return "INTEGER";
	case real_: return "REAL NUMBER";
	case string_lit: return "\"SOME STRING\"";
	
	// reserved keywords
	case access: return "access";
	case else_: return "else";
	case func: return "func";
	case if_: return "if";
	case int32: return "int32";
	case int64: return "int64";
	case let: return "let";
	case return_: return "return";
	case struct_: return "struct";
	
	// symbols
	case ass: return "=";		// =
	case eq: return "==";			// ==
	case ls: return "<";			// <
	case leq: return "<=";		// <=
	case gt: return ">";			// >
	case geq: return ">=";		// >=
	
	case add: return "+";		// +
	case sub: return "=";		// -
	case mul: return "*";		// *
	case div: return "/";		// /
	case mod: return "%";		// %
	
	case amp: return "&";		// &
	
	case bs: return "\\";			// \
	
	case arrow: return "->";		// ->
	case mapsto: return "=>";		// =>
	
	case dot: return ".";		// .
	
	case col: return ":";		// :
	case semcol: return ";";		// ;
	case com: return ",";		// ,
	
	case lpar: return "(";		// (
	case rpar: return ")";		// )
	case lbra: return "[";		// [
	case rbra: return "]";		// ]
	case lblo: return "{";		// {
	case rblo: return "}";		// }
	}
}
