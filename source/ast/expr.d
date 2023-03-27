module ast.expr;

import ast.node;
import ast.stmt;
import ast.type;
import visitor.visitor;
import token;

class Expr : Node {
	bool paren;
	
	this (LOC loc = LOC.init) {
		super(loc);
	}
	
	Type _type;
	Type type() @property {
		if (!_type) _type = new Int32Type();
		return _type;
	}
	
	override void accept(Visitor v) { v.visit(this); }
}

// e0 op e1
final class BinExpr : Expr {
	Expr expr0;
	TOK op;
	Expr expr1;
	
	this (Expr expr0, TOK op, Expr expr1, LOC loc = LOC.init) {
		this.expr0 = expr0;
		this.op = op;
		this.expr1 = expr1;
		super(loc);
	}
	
	override void accept(Visitor v) { v.visit(this); }
}

// op e0
final class UnExpr : Expr {
	TOK op;
	Expr expr;
	
	this (TOK op, Expr expr, LOC loc = LOC.init) {
		this.op = op;
		this.expr = expr;
		super(loc);
	}
	
	override void accept(Visitor v) { v.visit(this); }
}

// fn(args)
final class FuncExpr : Expr {
	Expr fn;
	Expr[] args;
	
	this (Expr fn, Expr[] args, LOC loc = LOC.init) {
		this.fn = fn;
		this.args = args;
		super(loc);
	}
	
	override void accept(Visitor v) { v.visit(this); }
}


// block expression
final class BlockExpr : Expr {
	Stmt[] stmts;
	bool is_func_body;
	
	import sem.scope_;
	Scope scp;		// the scope this block
	
	this (Stmt[] stmts, LOC loc = LOC.init) {
		this.stmts = stmts;
		super(loc);
	}
	
	Expr last_expr() @property {
		return (cast(ExprStmt) stmts[$-1]).expr;
	}
	
	override void accept(Visitor v) { v.visit(this); }
}


// integer literal
final class IntExpr : Expr {
	string str;
	
	this (string str, LOC loc = LOC.init) {
		this.str = str;
		super(loc);
	}
	
	override void accept(Visitor v) { v.visit(this); }
}

// identifier literal
final class IdExpr : Expr {
	string str;
	
	this (string str, LOC loc = LOC.init) {
		this.str = str;
		super(loc);
	}
	
	override void accept(Visitor v) { v.visit(this); }
}

// ()
final class UnitExpr : Expr {
	this (LOC loc = LOC.init) {
		super(loc);
	}
	
	override void accept(Visitor v) { v.visit(this); }
}
