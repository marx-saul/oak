module sem.scope_;

import message;
import sem.symbol;
import ast;
import visitor.general;

enum SCP {
	mod,		// module
	func,		// function body
	struct_,	// struct
	
}

// the scope class
// carries the data of symbols defined in that scope
class Scope {
	SCP kind;					// the scope kind
	ScopeDecl decl;				// the node that make this scope
	Scope parent;				// parent scope
	
	SymbolTable table;				// symbols of this scope
	Decl[] unexpanded_decls;		// mixins, etc
	bool symbols_ok;				// are symbols all determined (TODO)
	
	this (SCP kind, ScopeDecl decl, Scope parent) {
		this.kind = kind;
		this.decl = decl;
		this.parent = parent;
		
		this.table = new SymbolTable();
	}
	
	void add_symbol(Symbol sym) {
		if (auto conflict = table.add(sym)) {
			decl.add_error("Symbol conflict: '" ~ sym.name ~ "' in " ~ conflict.decl.loc.toString() ~ " and " ~ sym.decl.loc.toString());
		}
	}
	void add_symbol(Symbol[] syms) {
		foreach (sym; syms)
			add_symbol(sym);
		this.symbols_ok = true;
	}
	
	void add_decl(Decl decl) {
		if (auto x = decl.isLetDecl) {
			add_symbol(x.sym ? x.sym : new Variable(x, this));
		}
		else if (auto x = decl.isArgDecl) {
			add_symbol(x.sym ? x.sym : new Variable(x, this));
		}
		else if (auto x = decl.isFuncDecl) {
			add_symbol(x.sym ? x.sym : new Function(x, this));
		}
		else if (auto x = decl.isStructDecl) {
			add_symbol(x.sym ? x.sym : new Struct(x, this));
		}
		else if (auto x = decl.isModuleDecl) {
			add_symbol(x.sym ? x.sym : new Module(x, this));
		}
		else assert(0, typeid(decl).toString());
	}
	
	void add_decl(Decl[] decls) {
		foreach (decl; decls)
			add_decl(decl);
	}
	
	// TODO
	void expand_decls(ref bool flag) {
		symbols_ok = true;
	}
	
	// go up the scope and search the symbol
	Symbol search(string name) {
		auto current = this;
		while (current) {
			if (auto p = name in table.symbols) return *p;
			else current = current.parent;
		}
		return null;
	}
}

class SymbolTable {
	Symbol[string] symbols;
	
	this () {}
	
	// return: conflicting symbol
	Symbol add(Symbol sym) {
		if (!sym) return null;
		if (auto ptr = sym.name in symbols) {
			return *ptr;
		}
		else {
			symbols[sym.name] = sym;
			return null;
		}
	}
}
