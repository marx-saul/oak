module sem.var;

import message;
import ast;
import sem.expr;
import sem.symbol;
import sem.scope_;
import sem.func;
import sem.struct_;
import sem.module_;

void sem_decl(Decl decl, Scope scp, ref bool flag) {
	if (!decl) return;
	else if (auto x = decl.isLetDecl) {
		sem_variable(x, scp, flag);
	}
	else if (auto x = decl.isArgDecl) {
		sem_argument(x, scp, flag);
	}
	else if (auto x = decl.isFuncDecl) {
		assert(0);
		//sem_function(x, scp, flag)
	}
	else if (auto x = decl.isStructDecl) {
		sem_struct(x, scp, flag);
	}
	else if (auto x = decl.isModuleDecl) {
		sem_module(x, scp, flag);
	}
	assert(0, typeid(decl).toString());
}

void sem_variable(LetDecl decl, Scope scp, ref bool flag) {
	if (!decl) return;
	
	// both type and initializer are given
	// only type is indicated are given
	// 
	
	return;
}

void sem_argument(ArgDecl decl, Scope scp, ref bool flag) {
	assert(0);
}
