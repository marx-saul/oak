module ast.decl;

import ast.stmt;
import ast.expr;
import sem.symbol;
import visitor.visitor;
import token;

class Decl : Stmt {
	Token id;
	
	this (Token id, STMT type, LOC loc = LOC.init) {
		this.id = id;
		super(type, loc);
	}
	
	Symbol sym;
	
	override void accept(Visitor v) { v.visit(this); }
}

class LetDecl : Decl {
	Expr expr;
	
	this (Token id, Expr expr, LOC loc = LOC.init) {
		this.expr = expr;
		super(id, STMT.let, loc);
	}
	
	override void accept(Visitor v) { v.visit(this); }
}
