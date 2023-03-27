module ast.type;

import ast.node;
import visitor.visitor;
import token;

abstract class Type : Node {
	bool paren;
	
	this (LOC loc = LOC.init) {
		super(loc);
	}
	
	// byte size of the value of this expression
	uint size() @property;
	string mangle;		// mangled string
	string ctype;		// the type in C code
	string definition;	// definition in C
	
	override void accept(Visitor v) { v.visit(this); }
}

final class TupleType : Type {
	Type[] mems;
	
	this (Type[] mems, LOC loc = LOC.init) {
		this.mems = mems;
		super(loc);
	}
	
	private uint _size;
	private bool size_calced;
	override uint size() @property {
		if (!size_calced) {
			foreach (mem; mems)
				if (mem) _size += mem.size;
		}
		return _size;
	}
	
	override void accept(Visitor v) { v.visit(this); }
}

final class ListType : Type {
	Type elem;
	
	this (Type elem, LOC loc = LOC.init) {
		this.elem = elem;
		super(loc);
	}
	
	override uint size() @property {
		import global;
		return global.PTR_SIZE * 2;
	}
	
	override void accept(Visitor v) { v.visit(this); }
}

final class PtrType : Type {
	Type dtp;		// dereferenced type
	
	this (Type dtp, LOC loc = LOC.init) {
		this.dtp = dtp;
		super(loc);
	}
	
	override uint size() @property {
		import global;
		return global.PTR_SIZE;
	}
	
	override void accept(Visitor v) { v.visit(this); }
}

final class FuncType : Type {
	Type[] args;	// argument types
	Type ret;		// return type
	
	this (Type[] args, Type ret, LOC loc = LOC.init) {
		this.args = args;
		this.ret = ret;
		super(loc);
	}
	
	// function pointer and the environment pointer
	override uint size() @property {
		import global;
		return global.PTR_SIZE * 2;
	}
	
	string closure_def;		// the definition of the closure struct
	
	override void accept(Visitor v) { v.visit(this); }
}

final class IdType : Type {
	Token id;
	
	this (Token id) {
		this.id = id;
		super(id.loc);
	}
	
	import sem.symbol;
	Symbol sym;
	
	override uint size() @property {
		assert(sym);
		return sym.size;
	}
	
	override void accept(Visitor v) { v.visit(this); }
}

final class UnitType : Type {
	this (LOC loc = LOC.init) {
		super(loc);
	}
	
	override uint size() @property {
		return 0;
	}
	
	override void accept(Visitor v) { v.visit(this); }
}

final class Int32Type : Type {
	this (LOC loc = LOC.init) {
		super(loc);
	}
	
	override uint size() @property {
		return 4;
	}
	
	override void accept(Visitor v) { v.visit(this); }
}

final class Int64Type : Type {
	this (LOC loc = LOC.init) {
		super(loc);
	}
	
	override uint size() @property {
		return 8;
	}
	
	override void accept(Visitor v) { v.visit(this); }
}
