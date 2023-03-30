module sem.symbol;

import global;
import ast;
import sem.scope_;

enum SYM {
	mod,		// module defined by module
	var,		// variable defined by let
	arg,		// argument of a function
	func,		// function name defined by func
}

class Symbol {
	SYM kind;		// the symbol type
	// the symbol name
	@property string name() { return decl.id.str; }
	@property string name(string s) { return decl.id.str = s; }
	Decl decl;		// the corresponding ASTNode
	Scope parent;	// the scope this symbol belongs to
	
	this (SYM kind, Decl decl, Scope parent) {
		this.kind   = kind;
		this.decl   = decl;
		this.parent = parent;
		
		this.decl.sym = this;
	}
	
	// the size of this symbol
	uint size() @property { return 0; }
	
	// the address of this symbol from the stack frame
	uint _address;
	bool _is_address_calculated = false;
	uint address() @property {
		if (!_is_address_calculated) parent.calculate_stack();
		return _address;
	}
}

class ScopeSymbol : Symbol {
	Scope scp;	// the scope this symbol defines
	
	this (SYM type, Decl decl, Scope parent, Scope scp) {
		this.scp = scp;
		super(type, decl, parent);
	}
}

class Module : ScopeSymbol {
	this (Mod decl, Scope parent, Scope scp) {
		super(SYM.mod, decl, parent, scp);
	}
}

class Variable : Symbol {
	this (LetDecl decl, Scope parent) {
	 	super(SYM.var, decl, parent);
	}
	
	override uint size() @property { return VALUE_SIZE; }
}

class Argument : Symbol {
	this (ArgDecl decl, Scope parent) {
	 	super(SYM.arg, decl, parent);
	}
	
	override uint size() @property { return VALUE_SIZE; }
}

class Function : ScopeSymbol {
	this (FuncDecl decl, Scope parent, Scope scp) {
		super(SYM.func, decl, parent, scp);
	}
	
	string _label;	// the label of this function
	string label() @property {
		import global;
		if (_label.length == 0)
			return _label = unique_label();
		else
			return _label;
	}
	
	// for class method
	bool need_this_pointer;
	uint hidden_args_size() @property {
		if (need_this_pointer) return 2 * PTR_SIZE;
		else return PTR_SIZE;
	}

}
