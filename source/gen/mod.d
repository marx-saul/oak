module gen.mod;

import global;
import ast;
import sem.mod;
import sem.func;
import sem.scope_;
import sem.symbol;
import gen.code;
import gen.func;

unittest {
	import parser;
	import std.stdio;
	writeln("########### gen/mod.d");
	
	Mod mod;
	{
		scope p = new Parser("
			let counter = 0;
			let x = 0;
			
			func main() {
				let a = 23;
				let b = 47;
				let c = multiply(a, b);
				return c;
			}
			
			func multiply(n, m) {
				counter = counter + 1;	// does not work yet
				let result = n * m;
				result
			}
		", "sem/mod-1");
		mod = p.parseMod();
	}
	
	auto program = mod_program_gen(mod);
	writeln(program);
}

Program mod_program_gen(Mod mod) {
	if (!mod) return null;
	
	set_module_scope(mod);
	calculate_module_static_data(mod);
	
	CodeSection[] code_secs;
	foreach (sym; mod.scp.symbols) {
		if (sym.kind == SYM.func) {
			set_scope(cast(FuncDecl) sym.decl, mod.scp);
			code_secs ~= func_code_gen(cast(FuncDecl) sym.decl);
		}
	}
	
	auto static_data = new void[mod.scp.stack_size];
	
	return new Program(code_secs, static_data);
}
