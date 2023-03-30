module visitor.visitor;

import ast;

abstract class Visitor {
	
	// node.d
	void visit(Node);
	
	// decl.d
	void visit(Decl);
	void visit(ScopeDecl);
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
	
	// mod.d
	void visit(Mod);
	
	// stmt.d
	void visit(Stmt);
	void visit(ExprStmt);
	void visit(ReturnStmt);
	
	// type.d
	void visit(Type);
	void visit(TupleType);
	void visit(ListType);
	void visit(PtrType);
	void visit(FuncType);
	void visit(IdType);
	void visit(UnitType);
	void visit(Int32Type);
	void visit(Int64Type);
}
