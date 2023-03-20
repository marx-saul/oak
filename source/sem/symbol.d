module sem.symbol;

import global;
import ast;
import sem.scope_;

enum SYM {
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
	
	// the relative address in the stack from the STACK_BTM (or the align of a struct member)
	// valid for var, arg(negative address), ...
	// invalid for func, struct, ...
	int _address;
	bool is_address_calced = false;
	int address() @property {
		if (is_address_calced) return _address;
		
		import std.stdio;
		
		Scope scp = parent;
		loop:
		while (scp) final switch (scp.kind) {
		case SCP.func:
			import sem.func;
			calc_stack_address(cast(FuncDecl) scp.node);
			break loop;
		
		case SCP.expr:
			scp = scp.parent;
			break;
			
		case SCP.root:
			assert(0);
		}
		
		return _address;
	}
	
	// the size of this symbol on the stack
	uint size() @property { return 0; }
}

class ScopeSymbol : Symbol {
	Scope scp;	// the scope this symbol defines
	
	this (SYM type, Decl decl, Scope parent, Scope scp) {
		this.scp = scp;
		super(type, decl, parent);
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
	
	// TODO
	// the pointer for rollback stacks (and closures)
	bool _need_stack_ptr;
	private bool need_stack_ptr_determined = false;
	
	// the pointer "this"
	bool _need_ptr_this;
	private bool need_this_ptr_determined = false;
}
