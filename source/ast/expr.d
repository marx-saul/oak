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
	
	Type type;
	bool type_ok() @property {
		return !type && type.sem_ok;
	}
	
	override void accept(Visitor v) { v.visit(this); }
	
	BinExpr   isBinExpr()   @property { return null; }
	UnExpr    isUnExpr()    @property { return null; }
	FuncExpr  isFuncExpr()  @property { return null; }
	TupleExpr isTupleExpr() @property { return null; }
	IdExpr    isIdExpr()    @property { return null; }
	IntExpr   isIntExpr()   @property { return null; }
	UnitExpr  isUnitExpr()  @property { return null; }
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

/+
// block expression
final class BlockExpr : Expr {
	Stmt[] stmts;
	bool has_value;		// ends with expression without semicolon 
	
	this (Stmt[] stmts, bool has_value, LOC loc = LOC.init) {
		this.stmts = stmts;
		this.has_value = has_value;
		super(loc);
	}
	
	bool is_func_body;
	
	import sem.scope_;
	Scope scp;		// the scope this block
	
	Expr last_expr() @property {
		if (has_value)
			return (cast(ExprStmt) stmts[$-1]).expr;
		else
			return null;
	}
	
	override void accept(Visitor v) { v.visit(this); }
}
+/

final class TupleExpr : Expr {
	Expr[] mems;
	
	this (Expr[] mems, LOC loc = LOC.init) {
		this.mems = mems;
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
	
	import sem.symbol;
	Symbol sym;
	
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

// ()
final class UnitExpr : Expr {
	this (LOC loc = LOC.init) {
		super(loc);
	}
	
	override void accept(Visitor v) { v.visit(this); }
}
