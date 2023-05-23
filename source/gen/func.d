module gen.func;

import global;
import token;
import ast;
import sem.scope_;
import sem.symbol;
import sem.func;
import gen.code;
import gen.expr;
/+
unittest {
	import parser;
	import std.stdio;
	
	writeln("########### gen/func.d");
	
	/+{
		auto p = new Parser(`
			func main() {
				let a = 23;
				let b = 47;
				let c = a*b;
				return c;
			}
		`, "scope_.d");
		auto fd = p.parseFuncDecl();
		auto root_scp = new Scope;
		set_scope(fd, root_scp);
		
		auto cs = func_code_gen(fd);
		writeln(cs);
	}+/
}

// scp : the scope that func belongs to
CodeSection func_code_gen(FuncDecl func) {
	if (!func) return null;
	
	//set_scope(fd, func.scp.parent);
	uint tmp_num = 0;
	auto ops = expr_code_gen(func.body, func.scp.parent, &tmp_num);
	return new CodeSection((cast (Function) func.sym).label, ops);
}
+/
