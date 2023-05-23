module sem.type;

import ast;
import sem.symbol;
import sem.scope_;

void sem_type(Type* type, Scope scp, ref bool flag) {
	if (!*type) return;
	
	replace_id_type(type, scp, flag);
	set_type_size(type, scp, flag);
}

// replace each id type by the proper types (e.g. StructType)
void replace_id_type(Type* type, Scope scp, ref bool flag) {
	// null
	if (!*type) return;
	// already replaced
	if (type.id_ok) return;
	
	// recursively
	if (auto x = (*type).isTupleType) {
		assert(x.mems.length > 0);
		bool result;
		foreach (y; x.mems) {
			replace_id_type(&y, scp, flag);
		}
	}
	else if (auto x = type.isListType) {
		replace_id_type(&x.elem, scp, flag);
	}
	else if (auto x = type.isPtrType) {
		replace_id_type(&x.dtp, scp, flag);
	}
	else if (auto x = type.isFuncType) {
		replace_id_type(&x.arg, scp, flag);
		replace_id_type(&x.ret, scp, flag);
	}
	
	// identifier type
	else if (auto x = type.isIdType) {
		auto sym = scp.search(x.id.str);
		if (!sym) {
			*type = new ErrorType("Identifier of type '" ~ x.id.str ~ "' was not found", type.loc);
			flag = true;
		}
		else if (auto s = sym.isStruct) {
			*type = new StructType(s);
			flag = true;
		}
		else {
			*type = new ErrorType("Identifier '" ~ x.id.str ~ "' is not a type", type.loc);
			flag = true;
		}
	}
	
	// other types
	else {
		type.id_ok = true;
		flag = true;
	}
}

// calculate type size
void set_type_size(Type* type, Scope scp, ref bool flag) {
	if (!*type) return;
	if (type.size_ok) return;
	
	// replace id type
	replace_id_type(type, scp, flag);
	
	// tuple type
	if (auto x = type.isTupleType) {
		assert(x.mems.length > 0);
		bool size_ok = true;
		// calculate size of each members
		foreach (mem; x.mems) {
			set_type_size(&mem, scp, flag);
			size_ok = size_ok && mem.size_ok;
		}
		
		// if all size of members are ok
		if (size_ok) {
			uint alignment;
			foreach (i, mem; x.mems) {
				x.alignments[i] = alignment;
				alignment += mem.size;
			}
			x.size = alignment;
			x.size_ok = true;
			flag = true;
		}
		
	}
	// id type
	else if (auto x = type.isIdType) {
	}
	// struct type
	else if (auto x = type.isStructType) {
		import sem.struct_;
		sem_struct(x.sym, flag);
		x.size_ok = x.sym.size_ok;
		x.size = x.sym.size;
		flag = true;
		
		import std.stdio;
		writeln("set_type_size, ", x.sym.name);
	}
	
}

