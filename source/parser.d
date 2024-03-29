module parser;

import ast;
import token;
import lexer;
import message;
import std.conv: to;
import std.algorithm;

unittest {
	import std.stdio;
	writeln("########### parser.d");
	{
		scope p = new Parser("
let counter = 0;
let x: int64 = 0;

func main() {
	let a:int32 = 23;
	let b:int64 = 47;
	let c:(int32, &int64) = (-a, &b);
	return c;
}

func multiply(n: int32, m: int32) {
	counter = counter + 1;
	let result = n * m;
	return result;
}

struct calc {
	let member0: int32;
	let member1: int32;
	
	func calc() {
		let k:int32 = n+1;
		func inner(m: int32) {
			return m + k + member0 * member1;
		}
		return inner(k) + 1;
	}
	
	let member2 = 0;
}
		", "parser-1");
		auto mod = p.parseModuleDecl();
	}
}

class Parser {
	private size_t ptr;
	private Token[] tokens;
	
	this (string source, string path = "") {
		tokens = getTokens(source, path);
	}
	
	private Token token() { return ptr >= tokens.length ? tokens[$-1] : tokens[ptr]; }
	private void next() { ++ptr; }
	private void check(TOK kind) {
		if (token().kind != kind) {
			message.error(token().loc, kind.to!string ~ " expected, not " ~ token().str);
		}
		next();
	}
	
	/*
	********* Module **********
	*/
	ModuleDecl parseModuleDecl() {
		auto loc = token().loc;
		auto decls = parseDecls();
		check(TOK.eof);
		return new ModuleDecl(Token.init, decls, loc);
	}
	
	/*
	********* Expression *********
	*/
	static bool isFirstofExpr(TOK kind) {
		with (TOK)
		return kind.among!(id, int_, real_, string_lit, add, sub, mul, amp, lpar, lbra, access, if_) != 0;
	}
	
	Expr parseExpr() {
		return parseAssignExpr();
	}
	
	Expr parseAssignExpr() {
		auto e = parseAddExpr();
		with (TOK)
		if (token().kind.among!(ass)) {
			auto op = token();
			next();
			e = new BinExpr(e, op.kind, parseAssignExpr(), op.loc);
		}
		return e;
	}
	
	Expr parseAddExpr() {
		auto e = parseMulExpr();
		with (TOK)
		while (token().kind.among!(add, sub)) {
			auto op = token();
			next();
			e = new BinExpr(e, op.kind, parseMulExpr(), op.loc);
		}
		return e;
	}
	
	Expr parseMulExpr() {
		auto e = parseUnaryExpr();
		with (TOK)
		while (token().kind.among!(mul, div, mod)) {
			auto op = token();
			next();
			e = new BinExpr(e, op.kind, parseUnaryExpr(), op.loc);
		}
		return e;
	}
	
	Expr parseUnaryExpr() {
		with (TOK)
		if (token().kind.among!(sub, amp, mul)) {
			auto op = token();
			next();
			return new UnExpr(op.kind, parseUnaryExpr(), op.loc);
		}
		else return parseFuncExpr();
	}
	
	Expr parseFuncExpr() {
		auto e = parseAtomExpr();
		
		with (TOK)
		while (token().kind == lpar) {
			auto loc = token().loc;
			next();
			
			Expr[] args;
			while (isFirstofExpr(token().kind)) {
				args ~= parseExpr();
				
				if (token().kind == com) next();
			}
			
			check(rpar);
			
			e = new FuncExpr(e, args, loc);
		}
		return e;
	}
	
	Expr parseAtomExpr() {
		with (TOK)
		switch (token().kind) {
		case int_:
			auto num = token();
			next();
			return new IntExpr(num.str, num.loc);
			
		case id:
			auto num = token();
			next();
			return new IdExpr(num.str, num.loc);
			
		case lpar:
			auto loc = token().loc;
			next();
			if (token().kind == rpar) {
				next();
				return new UnitExpr(loc);
			}
			
			Expr e;
			Expr[] members;
			while (isFirstofExpr(token().kind)) {
				members ~= parseExpr();
				if (token.kind == TOK.com) next();
			}
			if (members.length == 1) {
				members[0].paren = true;
				e = members[0];
			}
			else e = new TupleExpr(members, loc);
			check(rpar);
			
			return e;
		
		default:
			message.error(token().loc, "An Expression expected, not " ~ token().kind.to!string);
			next();
			return null;
		}
	}
	
	/*
	********* Type *********
	*/
	static bool isFirstofType(TOK kind) {
		with (TOK)
		return kind.among!(id, int32, int64, amp, lbra, lpar) != 0;
	}
	
	Type parseType() {
		return parseFuncType();
	}
	/*
	FuncType:
		Type -> Type
	*/
	Type parseFuncType() {
		auto t = parsePtrType();
		if (token().kind == TOK.arrow) {
			auto op = token();
			next();
			t = new FuncType(t, parseFuncType(), op.loc);
		}
		return t;
	}
	
	Type parsePtrType() {
		with (TOK)
		if (token().kind == TOK.amp) {
			auto op = token();
			next();
			auto t = parsePtrType();
			return new PtrType(t, op.loc);
		}
		else return parseAtomType();
	}
	
	Type parseAtomType() {
		with (TOK)
		switch (token().kind) {
		case id:
			auto id = token();
			next();
			return new IdType(id);
			
		case int32:
			auto loc = token().loc;
			next();
			return new Int32Type(loc);
			
		case int64:
			auto loc = token().loc;
			next();
			return new Int64Type(loc);
			
		case lpar:
			auto loc = token().loc;
			next();
			if (token().kind == rpar) {
				next();
				return new UnitType(loc);
			}
			
			Type t;
			Type[] members;
			while (isFirstofType(token().kind)) {
				members ~= parseType();
				if (token.kind == TOK.com) next();
			}
			if (members.length == 1) {
				members[0].paren = true;
				t = members[0];
			}
			else t = new TupleType(members, loc);
			check(rpar);
			
			return t;
		
		case lbra:
			auto loc = token().loc;
			next();
			auto type = parseType();
			check(rbra);
			return new ListType(type, loc);
		
		default:
			message.error(token().loc, "A Type expected, not " ~ token().kind.to!string);
			next();
			return null;
		}
	}
	
	/*
	********* Statement *********
	Stmt:
		ReturnStmt
		Decl
	*/
	
	static bool isFirstofStmt(TOK kind) {
		with (TOK)
		return isFirstofExpr(kind) || isFirstofDecl(kind) || kind.among!(lblo, return_) != 0;
	}
	
	Stmt[] parseStmt() {
		auto loc = token().loc;
		
		if (isFirstofExpr(token().kind)) {
			return [parseExprStmt()];
		}
		else if (isFirstofDecl(token().kind)) {
			return cast(Stmt[]) parseDecls();
		}
		else
			with (TOK)
			switch (token().kind) {
			case lblo:
				return [parseBlockStmt()];
			
			case return_:
				return [parseReturnStmt()];
			
			default:
				message.error(token().loc, "A statement expected, not " ~ token().str);
				next();
				return [];
			}
	}
	
	ExprStmt parseExprStmt() {
		auto loc = token().loc;
		
		auto expr = parseExpr();
		
		check(TOK.semcol);
		
		return new ExprStmt(expr, loc);
	}
	
	BlockStmt parseBlockStmt() {
		auto loc = token().loc;
		check(TOK.lblo);
		
		Stmt[] stmts;
		while (isFirstofStmt(token().kind)) {
			stmts ~= parseStmt();
		}
		
		check(TOK.rblo);
		
		return new BlockStmt(stmts, loc);
	}
	
	ReturnStmt parseReturnStmt() {
		auto loc = token().loc;
		check(TOK.return_);
		
		Expr expr;
		if (isFirstofExpr(token().kind)) {
			expr = parseExpr();
		}
		
		check(TOK.semcol);
		return new ReturnStmt(expr, loc);
	}
	/*
	********* Declaration *********
	Decl:
		LetDecl
		FuncDecl
		StructDecl
	*/
	
	static bool isFirstofDecl(TOK kind) {
		with (TOK)
		return kind.among!(let, func, struct_) != 0;
	}
	
	Decl[] parseDecls() {
		Decl[] decls;
		with (TOK)
		loop:
		while (1)
		switch (token().kind) {
		case let:
			decls ~= parseLetDecl();
			break;
		
		case func:
			decls ~= parseFuncDecl();
			break;
		
		case struct_:
			decls ~= parseStructDecl();
			break;
		
		default:
			break loop;
		}
		return decls;
	}
	
	LetDecl[] parseLetDecl() {
		auto loc = token().loc;
		check(TOK.let);
		
		LetDecl[] result;
		with (TOK)
		while (token().kind == id) {
			auto idtk = token();
			next();
			
			Type type;
			if (token().kind == col) {
				next();
				type = parseType();
			}
			
			Expr expr;
			if (token.kind == ass) {
				next();
				expr = parseExpr();
			}
			
			result ~= new LetDecl(idtk, expr, type, loc);
			
			if (token().kind == com) next(); 
		}
		
		check(TOK.semcol);
		return result;
	}
	
	FuncDecl parseFuncDecl() {
		auto loc = token().loc;
		check(TOK.func);
		
		if (token().kind != TOK.id) {
			message.error(token().loc, "An identifier expected after func, not " ~ token().str);
			return null;
		}
		Token id = token();
		next();
		
		check(TOK.lpar);
		
		ArgDecl[] args;
		while (token().kind == TOK.id) {
			auto arg = token();
			next();
			check(TOK.col);
			auto type = parseType();
			args ~= new ArgDecl(arg, type);
			if (token().kind == TOK.com) next(); 
		}
		
		check(TOK.rpar);
		
		auto body = parseBlockStmt();
		
		return new FuncDecl(id, args, body, loc);
	}
	
	StructDecl parseStructDecl() {
		auto loc = token().loc;
		check(TOK.struct_);
		
		if (token().kind != TOK.id) {
			message.error(token().loc, "An identifier expected after struct, not " ~ token().str);
			return null;
		}
		Token id = token();
		next();
				
		check(TOK.lblo);
		
		Decl[] decls;
		while (isFirstofDecl(token().kind)) {
			decls ~= parseDecls();
		}
		
		check(TOK.rblo);
		
		return new StructDecl(id, decls, loc);
	}
}
