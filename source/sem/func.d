module sem.func;

import global;
import ast;
import sem.scope_;
import sem.symbol;
import visitor.general;

unittest {
	import parser, std.stdio;
	writeln("########### sem/func.d");
	
	FuncDecl fd;
	{
		auto p = new Parser(`
		func multiply(n, m) {
			let r = n*m;
			n*m
		}
		`, "mult");
		fd = p.parseFuncDecl();
		generate_scope(fd);
	}
	
	fd.calc_stack_address();
	foreach (sym; fd.scp.symbols) {
		writeln(sym.name, ": ", sym.address);
	}
}

// calculate the address (of symbols) from the STACK_BOTTOM of each variable defined inside the function
void calc_stack_address(FuncDecl fd) {
	if (fd) {
		auto fsc = new FuncStackCalculator();
		fsc.visit(fd);
	}
}

private class FuncStackCalculator : GeneralVisitor {
	this () {}
	
	private int address;
	
	alias visit = GeneralVisitor.visit;
	////////////////// stack modifiers /////////////////////
	// function
	override void visit(FuncDecl fd) {
		// arguments have negative address
		int arg_address;
		foreach_reverse(ad; fd.args) {
			ad.sym._address = (arg_address -= 4);
			ad.sym.is_address_calced = true;
		}
		
		// new stack
		int old_address = address;
		scope(exit) address = old_address;
		address = 0;
		
		// function body
		fd.body.accept(this);
	}
	
	// block expression
	override void visit(BlockExpr be) {
		foreach (stmt; be.stmts) {
			stmt.accept(this);
		}
	}
	
	// variable declaration
	override void visit(LetDecl ld) {
		ld.sym._address = address;
		ld.sym.is_address_calced = true;
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
		be.exp0.accept(this);
		be.exp1.accept(this);
	}
	
	override void visit(UnExpr ue) {
		ue.exp.accept(this);
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
