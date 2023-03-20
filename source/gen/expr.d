module gen.expr;

import global;
import message;
import token;
import ast;
import sem.scope_;
import sem.symbol;
import gen.code;
import gen.stmt;
import visitor.general;
import std.algorithm;

unittest {
	import parser, std.stdio;
	writeln("########### gen/expr.d");
	
	Scope root_scp;
	{
		auto p = new Parser(`
		func mult(n, m) {
			let result = n*m;
			n*m
		}
		`, "mult");
		auto fd = p.parseFuncDecl();
		root_scp = generate_scope(fd);
		root_scp.kind = SCP.func;
	}
	
	BlockExpr exp;
	{
		auto p = new Parser(`{let a = 10 ; mult(2, a + 9)}`, "ex"); // {let a = 10 ; multiply(2, a)}
		exp = p.parseBlockExpr();
		
		set_scope(exp, root_scp);
	}
	
	uint tmp_num = 0;
	auto ops = exp_code_gen(exp, root_scp, &tmp_num);
	foreach (op; ops) writeln(op);
	
}

// the temp variable number starts from tmp_num
Operation[] exp_code_gen(Expr exp, Scope scp, uint* tmp_num) {
	if (exp) {
		auto eg = new ExprGen(scp, tmp_num);
		exp.accept(eg);
		return eg.result;
	}
	else return [];
}


private class ExprGen : GeneralVisitor {
	Operation[] result;
	bool is_lval = false;		// whether an identifier is regarded as a left value or a right value
	Scope scp;
	uint* tmp_num;
	
	this (Scope scp, uint* tmp_num) {
		this.scp = scp;
		this.tmp_num = tmp_num;
	}
	
	alias visit = GeneralVisitor.visit;
	
	override void visit(BinExpr e) {
		// numerical operators
		if (auto op = e.op in [
			TOK.add: OpCode.add,
			TOK.sub: OpCode.sub,
			TOK.mul: OpCode.mul,
			TOK.div: OpCode.div,
			TOK.mod: OpCode.mod,
		]) {
			e.exp0.accept(this);
			auto tn0 = *tmp_num-1;
			
			e.exp1.accept(this);
			auto tn1 = *tmp_num-1;
			
			result ~= new Operation(
				*op,
				new Temp(global.VALUE_SIZE, tn0),
				new Temp(global.VALUE_SIZE, tn1),
				new Temp(global.VALUE_SIZE, *tmp_num),
				false
			);
			++*tmp_num;
		}
		
		// assign
		else if (e.op == TOK.ass) {
			e.exp1.accept(this);
			auto tn_right = *tmp_num-1;
			
			is_lval = true;
			e.exp0.accept(this);
			auto tn_left = *tmp_num-1;
			
			result ~= Operation.move(new Temp(global.VALUE_SIZE, tn_right), new Temp(global.VALUE_SIZE, tn_left), true);
		}
		
		else assert(0);
	}
	
	override void visit(UnExpr e) {
		if (auto op = e.op in [
			TOK.sub: OpCode.inv,
		]) {
			e.exp.accept(this);
			auto tn = *tmp_num-1;
			
			result ~= new Operation(
				*op,
				new Temp(global.VALUE_SIZE, tn),
				null,
				new Temp(global.VALUE_SIZE, *tmp_num),
				false
			);
			++*tmp_num;
		}
		
		else assert(0);
	}
	
	/*
	function call :
	push all arguments
	goto [label]
	pop results from stack
	*/
	override void visit(FuncExpr e) {
		// TODO we only support simple function call, not something like funcs[i](0, 2, 3)
		if (typeid(e.fn) != typeid(IdExpr)) {
			// error
			message.error(e.loc, "Unsupported function call.");
			return;
		}
		auto fn_id = cast(IdExpr) e.fn;
		
		auto fn_sym = scp.find_symbol(fn_id.str);
		// TODO function not found error
		if (!fn_sym) {
			message.error(e.loc, "The function '" ~ fn_id.str ~ "' was not found.");
			return;
		}
		// TODO not a function error
		if (fn_sym.kind != SYM.func) {
			message.error(e.loc, "'" ~ fn_id.str ~ "' is not a function.");
			return;
		}
		
		auto sym = cast(Function) fn_sym;	// function symbol
		
		// push arguments
		foreach (arg; e.args) {
			if (arg) arg.accept(this);
			// TODO replace by general pushes
			result ~= Operation.push32(new Temp(global.VALUE_SIZE, *tmp_num-1));
		}
		
		// goto
		result ~= Operation.goto_(new Label(sym.label, true));
		
		// pop the result from stack
		result ~= Operation.pop32(new Temp(global.VALUE_SIZE, *tmp_num), false);
		++*tmp_num;
	}
	
	override void visit(BlockExpr e) {
		auto old_scp = scp;
		scope(exit) scp = old_scp;
		
		scp = e.scp;
		
		foreach (stmt; e.stmts) {
			result ~= stmt_code_gen(stmt, scp, tmp_num);
		}
	}
	
	override void visit(IdExpr e) {
		auto sym = scp.find_symbol(e.str);
		// not found
		if (sym is null) {
			message.error(e.loc, "An undefined identifier " ~ e.str);
			return;
		}
		
		switch (sym.kind) {
		case SYM.var:
		case SYM.arg:
			// how far from the current scope
			auto depth = scp.stack_depth(sym.parent);
			// TODO
			if (depth > 0) assert(0, "reading parent scope variables has not been implemented");
			
			if (is_lval) {
				result ~= Operation.move(new Stack(global.VALUE_SIZE, sym.address), new Temp(global.VALUE_SIZE, *tmp_num), false);
				++*tmp_num;
			}
			else {
				result ~= Operation.deref32(new Stack(global.VALUE_SIZE, sym.address), new Temp(global.VALUE_SIZE, *tmp_num), false);
				++*tmp_num;
			}
			
			break;
			
		default:
			assert(0, "IdExpr undefined behavior");
		}
	}
	
	// push the integer
	override void visit(IntExpr e) {
		import std.conv: to;
		result ~= Operation.move(
			new Int(global.VALUE_SIZE, e.str.to!long),
			new Temp(global.VALUE_SIZE, *tmp_num),
			false
		);
		++*tmp_num;
	}
	
	// do nothing
	override void visit(UnitExpr) {
		
	}
}
