module gen.stmt;

import global;
import message;
import token;
import ast;
import sem.scope_;
import gen.code;
import gen.expr;
import visitor.general;


unittest {
	import parser;
	
}

Operation[] stmt_code_gen(Stmt stmt, Scope scp, uint* tmp_num) {
	if (stmt) {
		auto sg = new StmtGen(scp, tmp_num);
		stmt.accept(sg);
		return sg.result;
	}
	else return [];
}


private class StmtGen : GeneralVisitor {
	Operation[] result;
	Scope scp;
	uint* tmp_num;
	
	this (Scope scp, uint* tmp_num) {
		this.scp = scp;
		this.tmp_num = tmp_num;
	}
	
	alias visit = GeneralVisitor.visit;
	
	override void visit(ExprStmt node) {
		if (node.expr) result ~= exp_code_gen(node.expr, scp, tmp_num);
	}
	
	// function return (for specification, see gen/expr.d)
	override void visit(ReturnStmt node) {
		// return the expression (TODO)
		if (node.expr) {
			// need to separate for *tmp_num to change
			result ~= exp_code_gen(node.expr, scp, tmp_num);
			result ~= Operation.move(new Temp(global.VALUE_SIZE, *tmp_num-1), new Result(global.VALUE_SIZE, 0), false);	
			result ~= Operation.ret();
		}
	}
	
	// assign an expression to the stack
	override void visit(LetDecl node) {
		result ~=
			exp_code_gen(node.expr, scp, tmp_num)
		 ~ [Operation.move(new Temp(global.VALUE_SIZE, *tmp_num), new Stack(global.VALUE_SIZE, node.sym.address), true)];
	}
	
	override void visit(FuncDecl node) {
		assert(0, "inner function has not been implemented");
		
	}
}
