module ast.func;

import ast.expr;
import ast.decl;
import ast.stmt;
import ast.type;
import visitor.visitor;
import token;

final class ArgDecl : Decl {
	Type type;
	
	this (Token id, Type type) {
		this.type = type;
		super(id, STMT.arg, id.loc);
	}
	
	override void accept(Visitor v) { v.visit(this); }
	override ArgDecl isArgDecl() @property { return this; }
}

final class FuncDecl : ScopeDecl {
	ArgDecl[] args;
	BlockStmt body;
	
	this (Token id, ArgDecl[] args, BlockStmt body, LOC loc = LOC.init) {
		this.args = args;
		this.body = body;
		super(id, STMT.func, null, loc);
	}
	
	override void accept(Visitor v) { v.visit(this); }
	override FuncDecl isFuncDecl() @property { return this; }
}
