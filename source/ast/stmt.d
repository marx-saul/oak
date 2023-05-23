module ast.stmt;

import ast.node;
import ast.expr;
import ast.decl;
import visitor.visitor;
import token;

enum STMT {
	expr,
	block,
	return_,
	// declaration
	let,
	arg,
	func,
	module_,
	struct_,
}

class Stmt : Node {
	STMT kind;
	
	this (STMT kind, LOC loc = LOC.init) {
		this.kind = kind;
		super(loc);
	}
	
	override void accept(Visitor v) { v.visit(this); }
	
	import ast;
	ExprStmt   isExprStmt()   @property { return null; }
	BlockStmt  isBlockStmt()  @property { return null; }
	ReturnStmt isReturnStmt() @property { return null; }
	LetDecl    isLetDecl()    @property { return null; }
	ArgDecl    isArgDecl()    @property { return null; }
	FuncDecl   isFuncDecl()   @property { return null; }
	StructDecl isStructDecl() @property { return null; }
	ModuleDecl isModuleDecl() @property { return null; }
}

final class ExprStmt : Stmt {
	Expr expr;
	
	this (Expr expr, LOC loc) {
		this.expr = expr;
		super(STMT.expr, loc);
	}
	
	override void accept(Visitor v) { v.visit(this); }
	
	override ExprStmt isExprStmt() @property { return this; }
}

final class BlockStmt : Stmt {
	Stmt[] stmts;
	
	this (Stmt[] stmts, LOC loc) {	
		this.stmts = stmts;
		super(STMT.block, loc);
	}
	
	override void accept(Visitor v) { v.visit(this); }
	
	override BlockStmt isBlockStmt() @property { return this; }
}

final class ReturnStmt : Stmt {
	Expr expr;
	
	this (Expr expr, LOC loc) {
		this.expr = expr;
		super(STMT.return_, loc);
	}
	
	override void accept(Visitor v) { v.visit(this); }
	
	override ReturnStmt isReturnStmt() @property { return this; }
}

