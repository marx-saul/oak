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
	void visit(TupleExpr);
	void visit(IntExpr);
	void visit(IdExpr);
	void visit(UnitExpr);
	
	// func.d
	void visit(ArgDecl);
	void visit(FuncDecl);
	
	// mod.d
	void visit(ModuleDecl);
	
	// stmt.d
	void visit(Stmt);
	void visit(ExprStmt);
	void visit(BlockStmt);
	void visit(ReturnStmt);
	
	// struct_.d
	void visit(StructDecl);
	
	// type.d
	void visit(Type);
	void visit(TupleType);
	void visit(ListType);
	void visit(PtrType);
	void visit(FuncType);
	void visit(IdType);
	void visit(StructType);
	void visit(UnitType);
	void visit(Int32Type);
	void visit(Int64Type);
}
