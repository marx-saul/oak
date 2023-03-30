module sem.mod;

import global;
import ast;
import sem.scope_;
import sem.symbol;
import visitor.general;
/*
unittest {
	import parser;
	import std.stdio;
	writeln("########### sem/mod.d");
	
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
				counter = counter + 1;
				let result = n * m;
				result
			}
		", "sem/mod-1");
		mod = p.parseMod();
	}
	
	set_module_scope(mod);
	calculate_module_static_data(mod);
	
	foreach (sym; mod.scp.symbols) {
		writeln(sym.kind, " ", sym.name, " ", sym.address);
	}
}
*/

// get the symbols table of the module
void set_module_scope(Mod mod) {
	if (!mod) return;
	if (!mod.scp) {
		mod.scp = new Scope(SCP.mod, mod, null);
		auto msg = new ModuleScopeGenerator(mod.scp);
		foreach (decl; mod.decls) {
			decl.accept(msg);
		}
		mod.sym = new Module(mod, null, mod.scp);
	}
}

private class ModuleScopeGenerator : GeneralVisitor {
	Scope scp;
	this (Scope scp) { this.scp = scp; }
	
	alias visit = GeneralVisitor.visit;
	
	override void visit(LetDecl x) {
		scp.add_symbol(new Variable(x, scp));
	}
	override void visit(FuncDecl x) {
		scp.add_symbol(new Function(x, scp, null));
	}
}

// calculate the static data of this module
void calculate_module_static_data(Mod mod) {
	uint address = 0;
	foreach (sym; mod.scp.symbols) {
		sym._address = address;
		sym._is_address_calculated = true;
		address += sym.size;
	}
	mod.scp._stack_size = address;
	mod.scp._is_stack_calculated = true;
}
