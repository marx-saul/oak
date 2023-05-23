module sem.symbol;

import global;
import ast;
import sem.scope_;

enum SYM {
	module_,		// module defined by module
	var,			// an argument of a function or a variable defined by let
	func,			// function name defined by func
	struct_,		// struct
}

class Symbol {
	SYM kind;			// the symbol type
	// the symbol name
	@property string name() { return decl.id.str; }
	@property string name(string s) { return decl.id.str = s; }
	Decl decl;			// the corresponding ASTNode
	Scope parent;		// the scope this symbol belongs to
	
	this (SYM kind, Decl decl, Scope parent) {
		this.kind   = kind;
		this.decl   = decl;
		this.parent = parent;
		
		this.decl.sym = this;
	}
	
	Module   isModule()   @property { return null; }
	Variable isVariable() @property { return null; }
	Function isFunction() @property { return null; }
	Struct   isStruct()   @property { return null; }
}

final class Variable : Symbol {
	bool is_arg;
	
	this (ArgDecl decl, Scope parent) {
		super(SYM.var, decl, parent);
		this.is_arg = true;
	}
	this (LetDecl decl, Scope parent) {
	 	super(SYM.var, decl, parent);
	}
	
	// the alignment of the variable (in the stack frame or in a data sequence)
	uint alignment;
	bool alignment_ok;
	
	uint size()    @property { return decl.isLetDecl.type.size; }
	bool size_ok() @property { return decl.isLetDecl.type.size_ok; }
	
	override Variable isVariable() @property { return this; }
}

class ScopeSymbol : Symbol {
	Scope scp;	// the scope this symbol defines
	
	this (SYM type, Decl decl, Scope parent) {
		super(type, decl, parent);
	}
	
	// all symbols are set in the symbol table of scp (including mixin)
	bool symbols_ok() @property {
		// TODO (mixin)
		return scp !is null;
	}
}

final class Module : ScopeSymbol {
	this (ModuleDecl decl, Scope parent) {
		super(SYM.module_, decl, parent);
	}
	
	override Module isModule() @property { return this; }
}

final class Function : ScopeSymbol {
	this (FuncDecl decl, Scope parent) {
		super(SYM.func, decl, parent);
	}
	
	bool hidden_pointer = true;
	
	override Function isFunction() @property { return this; }
}

final class Struct : ScopeSymbol {
	this (StructDecl decl, Scope parent) {
		super(SYM.struct_, decl, parent);
	}
	
	// the size of this struct
	uint size;
	bool size_ok;
	bool size_in_use;		// avoid circular calculation of size
	
	override Struct isStruct() @property { return this; }
}
