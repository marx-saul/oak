module parser;

import ast;
import token;
import lexer;
import message;
import std.conv: to;
import std.algorithm;

unittest {
	{
		scope p = new Parser("a = a + { func suc(n) { n+1 } suc(suc(8*a)) }");
		p.parseExpr();
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
			message.error(token().loc, kind.to!string ~ " expected, not " ~ token().kind.to!string);
		}
		next();
	}
	
	static bool isFirstofExpr(TOK kind) {
		with (TOK)
		return kind.among!(id, int_, real_, string_lit, add, sub, mul, lpar, lbra, lblo, access, if_) != 0;
	}
	
	static bool isFirstofStmt(TOK kind) {
		with (TOK)
		return isFirstofExpr(kind) ||
			kind.among!(let, func, return_, ) != 0;
	}
	/*
	********* Expression *********
	*/
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
		if (token().kind.among!(sub)) {
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
			next();
			if (token().kind == rpar) {
				auto loc = token().loc;
				next();
				return new UnitExpr(loc);
			}
			auto e = parseExpr();
			check(rpar);
			e.paren = true;
			return e;
		
		case lblo:
			return parseBlockExpr();
		
		default:
			message.error(token().loc, "An Expression expected, not " ~ token().kind.to!string);
			next();
			return null;
		}
	}
	
	BlockExpr parseBlockExpr() {
		auto loc = token().loc;
		check(TOK.lblo);
		
		Stmt[] stmts;
		with (TOK)
		while (true) {
			if (isFirstofStmt(token().kind)) {
				stmts ~= parseStmt();
				
			}
			// end with semicolon
			else if (token().kind == rblo) {
				auto rblo_loc = token().loc;
				next();
				// end with an expression
				if (stmts.length > 0 && stmts[$-1].kind == STMT.expr)
					return new BlockExpr(stmts, loc);
				// otherwise
				else return new BlockExpr(stmts, loc);
			}
			else {
				message.error(token().loc, "} of ; expected in { ... }, not " ~ token().str);
				return null;
			}
		}
		
	}
	
	/*
	********* Statement *********
	Stmt:
		Expr
		LetDecl
		FuncDecl
		ReturnStmt
	*/
	Stmt[] parseStmt() {
		auto loc = token().loc;
		
		if (isFirstofExpr(token().kind)) {
			auto exp = parseExpr();
			auto result = new ExprStmt(exp, loc);
			if (token().kind == TOK.semcol) {
				next();
				return [new ExprStmt(exp, loc)];
			}
			else {
				return [new ReturnStmt(exp, loc)];
			}
		}
		
		with (TOK)
		switch (token().kind) {
		case let:
			return cast(Stmt[]) parseLetDecl();
		
		case func:
			return [parseFuncDecl()];
		
		case return_:
			return [parseReturnStmt()];
		
		default:
			message.error(token().loc, "A statement expected, not " ~ token().str);
			next();
			return [];
		}
	}
	
	LetDecl[] parseLetDecl() {
		auto loc = token().loc;
		check(TOK.let);
		
		LetDecl[] result;
		with (TOK)
		while (token().kind == id) {
			auto idtk = token();
			next();
			
			check(ass);
			
			auto exp = parseExpr();
			
			result ~= new LetDecl(idtk, exp, loc);
			
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
			
			args ~= new ArgDecl(arg);
			
			if (token().kind == TOK.com) next(); 
		}
		
		check(TOK.rpar);
		
		auto body = parseBlockExpr();
		body.is_func_body = true;
		
		return new FuncDecl(id, args, body);
	}
	
	ReturnStmt parseReturnStmt() {
		auto loc = token().loc;
		check(TOK.return_);
		next();
		
		Expr expr;
		if (isFirstofExpr(token().kind)) {
			expr = parseExpr();
		}
		
		return new ReturnStmt(expr, loc);
	}
}
