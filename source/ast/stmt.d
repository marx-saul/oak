module ast.stmt;

import ast.node;
import ast.expr;
import ast.decl;
import visitor.visitor;
import token;

enum STMT {
	expr,
	return_,
	// declaration
	let,
	arg,
	func,
}

class Stmt : Node {
	STMT kind;
	
	this (STMT kind, LOC loc = LOC.init) {
		this.kind = kind;
		super(loc);
	}
	
	override void accept(Visitor v) { v.visit(this); }
}

final class ExprStmt : Stmt {
	Expr expr;
	
	this (Expr expr, LOC loc) {
		this.expr = expr;
		super(STMT.expr, loc);
	}
	
	override void accept(Visitor v) { v.visit(this); }
}

final class ReturnStmt : Stmt {
	Expr expr;
	
	this (Expr expr, LOC loc) {
		this.expr = expr;
		super(STMT.return_, loc);
	}
	
	override void accept(Visitor v) { v.visit(this); }
}

