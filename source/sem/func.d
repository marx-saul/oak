module sem.func;

import global;
import ast;
import sem.scope_;
import sem.symbol;
import visitor.general;

/+unittest {
	import parser, std.stdio;
	writeln("########### sem/func.d");
	
	FuncDecl fd;
	{
		auto p = new Parser(`
		func multiply(n, m) {
			let r = n*m;
			{let a = 4; a};
			n*m
		}
		`, "mult");
		fd = p.parseFuncDecl();
		set_scope(fd, new Scope);
	}
	
	foreach (sym; fd.scp.symbols) {
		writeln(sym.name, ": ", sym.address);
	}
	writeln(fd.scp.stack_size);
}+/
/*
// calculate the address (of symbols) from the STACK_BOTTOM of each variable defined inside the function
void calc_stack_address(FuncDecl fd) {
	if (fd) {
		auto fsc = new FuncStackCalculator();
		fsc.visit(fd);
	}
}

// recursively set the stack address of variables
private class FuncStackCalculator : GeneralVisitor {
	this () {}
	
	private uint address;
	
	alias visit = GeneralVisitor.visit;
	////////////////// stack modifiers /////////////////////
	// function
	override void visit(FuncDecl fd) {
		uint old_address = address;
		scope(exit) address = old_address;
		
		address = (cast (Function) fd.sym).hidden_args_size;
		foreach(arg; fd.args) {
			arg.sym._address = address;
			arg.sym._is_address_calculated = true;
			address += arg.sym.size;
		}
		
		uint arg_size = address;
		
		// function body
		if (fd.body)
			foreach (stmt; fd.body.stmts)
				if (stmt) stmt.accept(this);
		
		// set the stack size
		fd.scp._stack_size = address;
		fd.scp._func_body_size = address - arg_size;
		fd.scp._is_stack_calculated = true;
	}
	
	// variable declaration
	override void visit(LetDecl ld) {
		ld.sym._address = address;
		ld.sym._is_address_calculated = true;
		address += ld.sym.size;
	}
	
	///////////////////// statements /////////////////////
	override void visit(ExprStmt es) {
		es.expr.accept(this);
	}
	
	override void visit(ReturnStmt rs) {
		if (rs.expr) rs.expr.accept(this);
	}
	
	///////////////////// expressions /////////////////////
	override void visit(BinExpr be) {
		be.expr0.accept(this);
		be.expr1.accept(this);
	}
	
	override void visit(UnExpr ue) {
		ue.expr.accept(this);
	}
	
	// block expression
	override void visit(BlockExpr be) {
		uint old_address = address;
		scope(exit) address = old_address;
		
		foreach (stmt; be.stmts) {
			if (stmt) stmt.accept(this);
		}
		
		be.scp._stack_size = address - old_address;
		be.scp._is_stack_calculated = true;
	}
	
	override void visit(FuncExpr fe) {
		fe.fn.accept(this);
		foreach (arg; fe.args) {
			arg.accept(this);
		}
	}
	
	// ignore other expressions
	override void visit(Expr e) {}
}
*/
