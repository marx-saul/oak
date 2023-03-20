module gen.func;
/+
import global;
import token;
import ast;
import sem.scope_;
import gen.code;
import gen.expr;
import gen.stmt;
import visitor.general, visitor.permissive;
import std.algorithm;

unittest {
	import parser;
	import std.stdio;
	import std.algorithm;
	import sem.symbol;
	
	writeln("########### gen/func.d");
	
	void show_scope(Scope s, int depth = 1) {
		string indent(int n = depth) {
			string result;
			foreach (i; 0 .. n) result ~= "    ";
			return result;
		}
		writeln(indent(depth-1) ~ "{");
		scope(exit) writeln(indent(depth-1) ~ "}");
		
		foreach (sym; s.symbols) {
			writeln(indent() ~ sym.name, " at ", sym.address);
			if (typeid(sym) == typeid(Function))
				show_scope((cast(ScopeSymbol) sym).scp, depth + 1);
		}
	}
	
	{
		auto p = new Parser(`
		func pow(n, m) {
			let c = 100;
			
			{
				let d = 10;
				{ let e = 11; };
				let f = 12;
			};
			
			func subfunc(c, d, e) {
				let g = 13;
			}
			
			let g = 200;
			n*m
		}
		`, "scope_.d");
		auto n = p.parseFuncDecl();
		auto s = generate_scope(n);
		calc_stack(s);
		show_scope(s);
	}
}

// scp : the scope that func belongs to
Operation[] func_code_gen(FuncDecl func, Scope scp) {
	return [];
}


// calculate stack
void calc_stack(Scope scp) {
	if (scp.stack_calced) return;
	
	auto cs = new CalcStack(scp);
	scp.node.accept(cs);
	scp.stack_calced = true;
}

// calculate the stack position
immutable size_t TYPE_SIZE = 4;		// size of type
private class CalcStack : PermissiveVisitor {
	Scope scp;
	size_t stack_ptr;
	
	this (Scope scp) {
		this.scp = scp;
	}
	
	alias visit = PermissiveVisitor.visit;
	
	override void visit(BlockExpr node) {
		auto old_scp = scp;
		auto old_stack_ptr = stack_ptr;
		scope (exit)
			scp = old_scp,
			stack_ptr = old_stack_ptr;
		
		if (!node.is_func_body)
			scp = node.scp;
		
		foreach (stmt; node.stmts) {
			if (stmt) stmt.accept(this);
		}
	}
	
	override void visit(ExprStmt node) {
		if (node.expr) node.expr.accept(this);
	}
	
	override void visit(FuncDecl node) {
		auto old_scp = scp;
		auto old_stack_ptr = stack_ptr;
		scope (exit)
			scp = old_scp,
			stack_ptr = old_stack_ptr;
		
		scp = node.scp;
		stack_ptr = 0;
		
		foreach (arg; node.args) {
			if (arg) arg.accept(this);
		}
		
		if (node.body) node.body.accept(this);
	}
	
	override void visit(LetDecl node) {
		node.sym.address = stack_ptr;
		stack_ptr += TYPE_SIZE;
	}
	
	override void visit(ArgDecl node) {
		node.sym.address = stack_ptr;
		stack_ptr += TYPE_SIZE;
	}
	
}
+/
