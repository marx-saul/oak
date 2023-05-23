module visitor.permissive;

import ast;
import visitor.visitor;

class PermissiveVisitor : Visitor {

	override void visit(Node x) {}
	
	// decl.d
	override void visit(Decl x) {}
	override void visit(ScopeDecl x) {}
	override void visit(LetDecl x) {}
	
	// expr.d
	override void visit(Expr x) {}
	override void visit(BinExpr x) {}
	override void visit(UnExpr x) {}
	override void visit(FuncExpr x) {}
	override void visit(TupleExpr x) {}
	override void visit(IntExpr x) {}
	override void visit(IdExpr x) {}
	override void visit(UnitExpr x) {}

	// func.d
	override void visit(ArgDecl x) {}
	override void visit(FuncDecl x) {}
	
	// mod.d
	override void visit(ModuleDecl x) {}
	
	// stmt.d
	override void visit(Stmt x) {}
	override void visit(ExprStmt x) {}
	override void visit(BlockStmt x) {}
	override void visit(ReturnStmt x) {}
	
	// struct_.d
	override void visit(StructDecl x) {}
	
	// type.d
	override void visit(Type x) {}
	override void visit(TupleType x) {}
	override void visit(ListType x) {}
	override void visit(PtrType x) {}
	override void visit(FuncType x) {}
	override void visit(IdType x) {}
	override void visit(StructType x) {}
	override void visit(UnitType x) {}
	override void visit(Int32Type x) {}
	override void visit(Int64Type x) {}
}
