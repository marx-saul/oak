module visitor.permissive;

import ast;
import visitor.visitor;

class PermissiveVisitor : Visitor {

	override void visit(Node x) {}
	
	// decl.d
	override void visit(Decl x) { }
	override void visit(LetDecl x) { }
	
	// expr.d
	override void visit(Expr x) {}
	override void visit(BinExpr x) {}
	override void visit(UnExpr x) {}
	override void visit(FuncExpr x) {}
	override void visit(BlockExpr x) {}
	override void visit(IntExpr x) {}
	override void visit(IdExpr x) {}
	override void visit(UnitExpr x) {}

	// func.d
	override void visit(ArgDecl x) {}
	override void visit(FuncDecl x) {}
	
	// stmt.d
	override void visit(Stmt x) {}
	override void visit(ExprStmt x) {}
	override void visit(ReturnStmt x) {}
}
