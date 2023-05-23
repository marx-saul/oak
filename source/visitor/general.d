module visitor.general;

import ast;
import visitor.visitor;

class GeneralVisitor : Visitor {
	
	override void visit(Node x) { assert(0); }
	
	// decl.d
	override void visit(Decl x) { visit(cast(Node) x); }
	override void visit(ScopeDecl x) { visit(cast(Decl) x); }
	override void visit(LetDecl x) { visit(cast(Decl) x); }
	
	// expr.d
	override void visit(Expr x) { visit(cast(Node) x); }
	override void visit(BinExpr x) { visit(cast(Expr) x); }
	override void visit(UnExpr x) { visit(cast(Expr) x); }
	override void visit(FuncExpr x) { visit(cast(Expr) x); }
	override void visit(TupleExpr x) { visit(cast(Expr) x); }
	override void visit(IntExpr x) { visit(cast(Expr) x); }
	override void visit(IdExpr x) { visit(cast(Expr) x); }
	override void visit(UnitExpr x) { visit(cast(Expr) x); }
	
	// func.d
	override void visit(ArgDecl x) { visit(cast(Decl) x); }
	override void visit(FuncDecl x) { visit(cast(ScopeDecl) x); }
	
	// mod.d
	override void visit(ModuleDecl x) { visit(cast(ScopeDecl) x); }
	
	// stmt.d
	override void visit(Stmt x) { visit(cast(Node) x); }
	override void visit(ExprStmt x) { visit(cast(Stmt) x); }
	override void visit(BlockStmt x) { visit(cast(Stmt) x); }
	override void visit(ReturnStmt x) { visit(cast(Stmt) x); }
	
	// struct_.d
	override void visit(StructDecl x) { visit(cast(ScopeDecl) x); }
	
	// type.d
	override void visit(Type x) { visit(cast(Node) x); }
	override void visit(TupleType x) { visit(cast(Type) x); }
	override void visit(ListType x) { visit(cast(Type) x); }
	override void visit(PtrType x) { visit(cast(Type) x); }
	override void visit(FuncType x) { visit(cast(Type) x); }
	override void visit(IdType x) { visit(cast(Type) x); }
	override void visit(StructType x) { visit(cast(Type) x); }
	override void visit(UnitType x) { visit(cast(Type) x); }
	override void visit(Int32Type x) { visit(cast(Type) x); }
	override void visit(Int64Type x) { visit(cast(Type) x); }
}
