module ast.type;

import ast.node;
import sem.symbol;
import visitor.visitor;
import token;

enum TYPE : ubyte {
	error,
	tuple,
	list,
	ptr,
	func,
	id,
	struct_,
	unit,
	int32,
	int64,
}

abstract class Type : Node {
	bool paren;
	TYPE kind;
	
	this (TYPE kind, LOC loc = LOC.init) {
		super(loc);
		this.kind = kind;
	}
	
	// semantic part
	// byte size of this type
	uint size;
	bool size_ok;
	
	// id type is replaced by the proper one
	bool id_ok;
	
	override void accept(Visitor v) { v.visit(this); }
	
	ErrorType  isErrorType()  @property { return null; }
	TupleType  isTupleType()  @property { return null; }
	ListType   isListType()   @property { return null; }
	PtrType    isPtrType()    @property { return null; }
	FuncType   isFuncType()   @property { return null; }
	IdType     isIdType()     @property { return null; }
	StructType isStructType() @property { return null; }
	UnitType   isUnitType()   @property { return null; }
	Int32Type  isInt32Type()  @property { return null; }
	Int64Type  isInt64Type()  @property { return null; }
	
	bool isNumType() @property {
		import std.algorithm;
		with (TYPE)
		return kind.among!(int32, int64) != 0;
	}
}

final class ErrorType : Type {
	this (string msg = "", LOC loc = LOC.init) {
		super(TYPE.error, loc);
		this.error_msgs = [msg];
	}
	
	override ErrorType isErrorType() @property { return this; }
}

final class TupleType : Type {
	Type[] mems;
	
	this (Type[] mems, LOC loc = LOC.init) {
		this.mems = mems;
		super(TYPE.tuple, loc);
		
		this.alignments.length = mems.length;
	}
	
	override void accept(Visitor v) { v.visit(this); }
	override TupleType isTupleType() @property { return this; }
	
	// semantic part
	
	// alignment of each member
	uint[] alignments;
}

final class ListType : Type {
	Type elem;
	
	this (Type elem, LOC loc = LOC.init) {
		this.elem = elem;
		super(TYPE.list, loc);
		
		import global;
		this.size = global.PTR_SIZE * 2;
		this.size_ok = true;
	}
	
	override void accept(Visitor v) { v.visit(this); }
	override ListType isListType() @property { return this; }
}

final class PtrType : Type {
	Type dtp;		// dereferenced type
	
	this (Type dtp, LOC loc = LOC.init) {
		this.dtp = dtp;
		super(TYPE.ptr, loc);
		
		import global;
		this.size = global.PTR_SIZE;
		this.size_ok = true;
	}
	
	override void accept(Visitor v) { v.visit(this); }
	override PtrType isPtrType() @property { return this; }
}

final class FuncType : Type {
	Type arg;		// argument type
	Type ret;		// return type
	
	this (Type arg, Type ret, LOC loc = LOC.init) {
		this.arg = arg;
		this.ret = ret;
		super(TYPE.func, loc);
		
		import global;
		this.size = global.PTR_SIZE * 2;
		this.size_ok = true;
	}
	
	override void accept(Visitor v) { v.visit(this); }
	override FuncType isFuncType() @property { return this; }
}

// unresolved identifier type (it will be replaced by StructType, ...)
final class IdType : Type {
	Token id;
	
	this (Token id) {
		this.id = id;
		super(TYPE.id, id.loc);
	}
	
	override void accept(Visitor v) { v.visit(this); }
	override IdType isIdType() @property { return this; }
}

final class StructType : Type {
	// semantic part
	Struct sym;
	
	this (Struct sym) {
		this.sym = sym;
		super(TYPE.struct_, sym.decl.loc);
		
		this.id_ok = true;
	}
	
	override void accept(Visitor v) { v.visit(this); }
	override StructType isStructType() @property { return this; }
}

final class UnitType : Type {
	this (LOC loc = LOC.init) {
		super(TYPE.unit, loc);
		
		this.size = 0;
		this.size_ok = true;
		this.id_ok = true;
	}
	
	override void accept(Visitor v) { v.visit(this); }
	override UnitType isUnitType() @property { return this; }
}

final class Int32Type : Type {
	this (LOC loc = LOC.init) {
		super(TYPE.int32, loc);
		
		this.size = 4;
		this.size_ok = true;
		this.id_ok = true;
	}
	
	override void accept(Visitor v) { v.visit(this); }
	override Int32Type isInt32Type() @property { return this; }
}

final class Int64Type : Type {
	this (LOC loc = LOC.init) {
		super(TYPE.int64, loc);		
		
		this.size = 8;
		this.size_ok = true;
		this.id_ok = true;
	}
	
	override void accept(Visitor v) { v.visit(this); }
	override Int64Type isInt64Type() @property { return this; }
}


Type to_common_num_type(Type tp1, Type tp2) {
	assert(tp1.isNumType && tp2.isNumType);
	auto n1 = tp1.kind;
	auto n2 = tp2.kind;
	
	if (n1 >= n2) return tp1;
	else return tp2;
}

