module ast.module_;

import ast.node;
import ast.decl;
import ast.stmt;
import visitor.visitor;
import token;

class ModuleDecl : ScopeDecl {
	this (Token id, Decl[] decls, LOC loc = LOC.init) {
		super(id, STMT.module_, decls, loc);
		this.decls = decls;
	}
	
	override void accept(Visitor v) { v.visit(this); }
	override ModuleDecl isModuleDecl() @property { return this; }
}
