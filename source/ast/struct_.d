module ast.struct_;

import ast.decl;
import ast.stmt;
import visitor.visitor;
import token;

class StructDecl : ScopeDecl {
	this (Token id, Decl[] decls, LOC loc = LOC.init) {
		super(id, STMT.struct_, decls, loc);
	}
	
	override void accept(Visitor v) { v.visit(this); }
	override StructDecl isStructDecl() @property { return this; }
}
