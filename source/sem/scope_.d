module sem.scope_;

import sem.symbol;
import ast;
import visitor.general;

enum SCP {
	mod,		// module
	expr,		// block expression
	func,		// function body
}

class Scope {
	SCP kind;				// the scope kind
	Node node;				// the node that make this scope
	
	Scope parent;			// parent scope
	
	Symbol[] symbols;		// symbols that belongs to this scope
	Symbol[string] table;	// for searching
	
	bool stack_calced;		// for gen.func.calc_stack
	
	this () {
		this.symbols = [];
		Symbol[string] table; this.table = table;
	}
	
	this (SCP kind, Node node, Scope parent) {
		this.kind = kind;
		this.node = node;
		this.parent = parent;
		this.symbols = [];
		Symbol[string] table; this.table = table;
	}
	
	// return: null if successfully added; otherwise the conflicting symbol
	Symbol add_symbol(Symbol sym) {
		if (auto p = sym.name in table) {
			return *p;
		}
		symbols ~= sym;
		table[sym.name] = sym;
		
		return null;
	}
	
	// find the closest symbol
	Symbol find_symbol(string name) {
		auto scp = this;
		do {
			if (auto p = name in scp.table) return *p;
			scp = scp.parent;
		} while (scp);
		return null;
	}
	
	// how many stack frames between this and scp
	// -1 : not an ancestor
	// 0 : itself, 1 : parent function, 2 : grandparent function, ...
	uint stack_depth(Scope scp) {
		auto current = this;
		uint i = 0;
		while (current !is scp) {
			current = current.parent;
			if (!current) return -1;
			if (current.kind == SCP.func) ++i;
		}
		return i;
	}
	
	// set the stack address of each symbols
	void calculate_stack() {
		if (_is_stack_calculated) return;
		
		if (this.kind == SCP.mod) {
			import sem.mod;
			calculate_module_static_data(cast (Mod) node);
		}
		
		auto current = this;
		while (current)
			final switch (current.kind) {
			case SCP.mod:
				assert(0);
			
			case SCP.func:
				import sem.func;
				calc_stack_address(cast (FuncDecl) node);
				return;
		
			case SCP.expr:
				current = current.parent;
				break;
			}
	}
	bool _is_stack_calculated;
	
	// the size of all variables defined in this scope
	uint _stack_size;
	uint stack_size() @property {
		calculate_stack();
		return _stack_size;
	}
	// when the scope is a function, func_body_size + (arguments size) = stack_size
	uint _func_body_size;
	uint func_body_size() @property {
		calculate_stack();
		return _func_body_size;
	}
	
}

// set scopes and symbols recursively
void set_scope(Node node, Scope root) {
	auto sg = new ScopeGenerator(root);
	node.accept(sg);
	assert(root is sg.root);
}

class ScopeGenerator : GeneralVisitor {
	Scope root;
	this (Scope root = null) {
		this.root = root;
	}
	
	alias visit = GeneralVisitor.visit;
	
	// decl.d
	override void visit(LetDecl x) {
		if (x.id.str !in root.table) root.add_symbol(new Variable(x, root));
	}
	
	// expr.d
	override void visit(BinExpr x) {
		if (x.expr0) x.expr0.accept(this);
		if (x.expr1) x.expr1.accept(this);
	}
	override void visit(UnExpr x) {
		if (x.expr) x.expr.accept(this);
	}
	override void visit(FuncExpr x) {
		if (x.fn) x.fn.accept(this);
		foreach (arg; x.args)
			if (arg) arg.accept(this);
	}
	override void visit(BlockExpr x) {
		if (!x.is_func_body) root = new Scope(SCP.expr, x, root);
		scope(exit) if (!x.is_func_body) root = root.parent;
		
		x.scp = root;
		foreach (stmt; x.stmts) {
			if (stmt) stmt.accept(this);
		}
	}
	override void visit(IntExpr x) {}
	override void visit(IdExpr x) {}
	override void visit(UnitExpr x) {}
	
	// func.d
	override void visit(ArgDecl x) {}	// done in FuncDecl
	override void visit(FuncDecl x) {
		root = new Scope(SCP.func, x, root);
		scope(exit) root = root.parent;
		
		if (x.id.str !in root.parent.table) root.parent.add_symbol(new Function(x, root.parent, root));
		x.scp = root;
		foreach (arg; x.args) {
			if (arg.id.str !in root.table) root.add_symbol(new Argument(arg, root));
		}
		if (x.body) x.body.accept(this);
	}
	
	// mod.d
	/+override void visit(Mod x) {
		root = new Scope(SCP.mod, x, root);
		scope(exit) root = root.parent;
		
		foreach (decl; x.decls) {
			if (decl) decl.accept(this);
		}
	}+/
	
	// stmt.d
	override void visit(ExprStmt x) {
		if (x.expr) x.expr.accept(this);
	}
	override void visit(ReturnStmt x) {
		if (x.expr) x.expr.accept(this);
	}
}
