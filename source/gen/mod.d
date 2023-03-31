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
	import gen.exec;
	
	writeln("########### gen/mod.d");
	
	Mod mod;
	{
		scope p = new Parser("
			let counter = 0;
			let x = 0;
			
			func main() {
				let a = 23;
				let b = 47;
				let c = 0;
				c = multiply(a, b);
				return c+334;
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
	program.code_secs = [new CodeSection("entry_point", [
		Operation.start_call(),
		Operation.push(new Int(global.VALUE_SIZE, global.PTR_SIZE)),
		Operation.goto_(new Label(program.code_secs[0].name, true)),
		Operation.halt()])]
	~ program.code_secs;
	writeln(program);
	program.execute();
	
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
			
			import std.stdio;
			writeln(__LINE__, sym.name, (cast(Function) sym).label);
			writeln(code_secs[$-1].name);
		}
	}
	
	auto static_data = new void[mod.scp.stack_size];
	
	return new Program(code_secs, static_data);
}
