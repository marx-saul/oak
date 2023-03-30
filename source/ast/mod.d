module ast.mod;

import ast.node;
import ast.decl;
import ast.stmt;
import visitor.visitor;
import token;

class Mod : ScopeDecl {
	Decl[] decls;
	
	this (Token id, Decl[] decls, LOC loc = LOC.init) {
		super(id, STMT.mod, loc);
		this.decls = decls;
	}
	
	override void accept(Visitor v) { v.visit(this); }
}
