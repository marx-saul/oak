module visitor.visitor;

import ast;

abstract class Visitor {
	
	// node.d
	void visit(Node);
	
	// decl.d
	void visit(Decl);
	void visit(LetDecl);
	
	// expr.d
	void visit(Expr);
	void visit(BinExpr);
	void visit(UnExpr);
	void visit(FuncExpr);
	void visit(BlockExpr);
	void visit(IntExpr);
	void visit(IdExpr);
	void visit(UnitExpr);
	
	// func.d
	void visit(ArgDecl);
	void visit(FuncDecl);
	
	// stmt.d
	void visit(Stmt);
	void visit(ExprStmt);
	void visit(ReturnStmt);
}
