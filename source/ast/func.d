module ast.func;

import ast.expr;
import ast.decl;
import ast.stmt;
import visitor.visitor;
import token;

class ArgDecl : Decl {
	this (Token id) {
		super(id, STMT.arg, id.loc);
	}
	
	override void accept(Visitor v) { v.visit(this); }
}

class FuncDecl : ScopeDecl {
	ArgDecl[] args;
	BlockExpr body;
	
	this (Token id, ArgDecl[] args, BlockExpr body, LOC loc = LOC.init) {
		this.args = args;
		this.body = body;
		super(id, STMT.func, loc);
	}
	
	override void accept(Visitor v) { v.visit(this); }
}
