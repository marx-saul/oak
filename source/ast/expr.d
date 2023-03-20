module ast.expr;

import ast.node;
import ast.stmt;
import visitor.visitor;
import token;

class Expr : Node {
	bool paren;
	
	this (LOC loc = LOC.init) {
		super(loc);
	}
	
	// byte size of the value of this expression
	uint size() @property { return 4; }
	
	override void accept(Visitor v) { v.visit(this); }
}

// e0 op e1
final class BinExpr : Expr {
	Expr exp0;
	TOK op;
	Expr exp1;
	
	this (Expr exp0, TOK op, Expr exp1, LOC loc = LOC.init) {
		this.exp0 = exp0;
		this.op = op;
		this.exp1 = exp1;
		super(loc);
	}
	
	override void accept(Visitor v) { v.visit(this); }
}

// op e0
final class UnExpr : Expr {
	TOK op;
	Expr exp;
	
	this (TOK op, Expr exp, LOC loc = LOC.init) {
		this.op = op;
		this.exp = exp;
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
