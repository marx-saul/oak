module ast.decl;

import ast.stmt;
import ast.expr;
import ast.type;
import sem.symbol;
import visitor.visitor;
import token;

abstract class Decl : Stmt {
	Token id;
	string name() @property {
		return id.str;
	}
	
	this (Token id, STMT type, LOC loc = LOC.init) {
		this.id = id;
		super(type, loc);
	}
	
	// semantic properties
	Symbol sym;
	
	override void accept(Visitor v) { v.visit(this); }
}

abstract class ScopeDecl : Decl {
	Decl[] decls;
	this (Token id, STMT type, Decl[] decls, LOC loc = LOC.init) {
		super(id, type, loc);
		this.decls = decls;
	}
	
	// semantic properties
	import sem.scope_;
	Scope scp;
	
	override void accept(Visitor v) { v.visit(this); }
}

final class LetDecl : Decl {
	Expr expr;
	Type type;
	
	this (Token id, Expr expr, Type type, LOC loc = LOC.init) {
		this.expr = expr;
		this.type = type;
		super(id, STMT.let, loc);
	}
	
	override void accept(Visitor v) { v.visit(this); }
	override LetDecl isLetDecl() @property { return this; }
}
