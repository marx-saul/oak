module sem.struct_;

import message;
import ast;
import sem.symbol;
import sem.scope_;
import sem.type;

unittest {
	import std.stdio, parser;
	writeln("-----1----- sem/struct.d");
	
	StructDecl sd;
	{
		scope p = new Parser(`
			struct S {
				let x: int32;
				let y: int64;
				
				struct innerS {
					let innerx: &int32;
					let innery: &int32;
				}
				
				let inner: innerS;
				
			}
		`);
		sd = p.parseStructDecl();
	}
	
	scope root_scp = new Scope(SCP.mod, null, null);
	scope s = new Struct(sd, root_scp);
	
	bool flag;
	flag = false;
	sem_struct(s, flag);
	writeln("1:", s.size_ok, s.size, flag);
	
	flag = false;
	sem_struct(s, flag);
	writeln("2:", s.size_ok, s.size, flag);
	
	flag = false;
	sem_struct(s, flag);
	writeln("3:", s.size_ok, s.size, flag);
	
	flag = false;
	sem_struct(s, flag);
	writeln("4:", s.size_ok, s.size, flag);
	
	flag = false;
	sem_struct(s, flag);
	writeln("5:", s.size_ok, s.size, flag);
}

// return: true if changes are made, false if nothing changed
void sem_struct(StructDecl sd, Scope scp, ref bool flag) {
	if (!sd) return;
	
	bool result;
	// create new symbol
	if (!sd.sym) {
		sd.sym = new Struct(sd, scp);
		flag = true;
	}
	
	sem_struct(sd.sym.isStruct, flag);
}

void sem_struct(Struct s, ref bool flag) {
	assert(s);
	set_scope(s, flag);
	set_struct_size(s, flag);
}

void set_scope(Struct s, ref bool flag) {
	if (!s.scp) {
		s.scp = new Scope(SCP.struct_, s.decl.isStructDecl, s.parent);
		s.scp.add_decl(s.decl.isStructDecl.decls);
		flag = true;
	}
}

void set_struct_size(Struct s, ref bool flag) {
	if (!s) return;
	// already known
	if (s.size_ok) return;
	
	import std.stdio;
	writeln(s.name, " set_struct_size");
	
	// avoid circular calculation
	if (s.size_in_use) {
		error(s.decl.loc, "Circular calculation of the size of struct '" ~ s.name ~ "'.");
		s.size_ok = true;
		flag = true;
	}
	
	// in use
	s.size_in_use = true;
	
	// expand mixins
	s.scp.expand_decls(flag);
	if (!s.scp.symbols_ok) {
		s.size_in_use = false;
		return;
	}
	
	// whether all variables are size_ok
	bool s_size_ok = true;
	foreach (decl; s.decl.isStructDecl.decls) {
		if (auto var = decl.sym.isVariable) {
			auto var_decl = decl.isLetDecl;
			// set the size of this variable
			set_type_size(&var_decl.type, s.scp, flag);
			s_size_ok = s_size_ok && var_decl.type.size_ok;
			
			writeln("\t", var.name, var_decl.type.size_ok, var_decl.type.kind);
		}
	}
	
	// if all variables are size_ok, then calculate alignments and the size of the struct
	if (s_size_ok) {
		writeln(s.name, " size_ok");
		s.size_ok = true;
		flag = true;
		s.size_in_use = false;
		
		uint alignment;
		foreach (decl; s.decl.isStructDecl.decls) {
			if (auto var = decl.sym.isVariable) {
				// set the alignment
				var.alignment = alignment;
				var.alignment_ok = true;
				alignment += decl.isLetDecl.type.size;
			}
		}
		s.size = alignment;
	}
	else {
		s.size_in_use = false;
	}
}
