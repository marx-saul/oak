module sem.scope_;

import sem.symbol;
import ast;
import visitor.permissive;

enum SCP {
	root,	// module
	expr,	// block expression
	func,	// function body
}

class Scope {
	SCP kind;				// the scope kind
	Node node;				// the node that make this scope
	
	Scope parent;			// parent scope
	
	Symbol[] symbols;		// symbols that belongs to this scope
	Symbol[string] table;	// for searching
	
	bool stack_calced;		// for gen.func.calc_stack
	
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
	
	// how many function scopes between this and scp
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
}

// set scopes and symbols
void set_scope(Node node, Scope root) {
	auto sg = new ScopeGenerator(root);
	node.accept(sg);
	assert(root is sg.result);
}

Scope generate_scope(Node node) {
	auto root = new Scope(SCP.root, node, null);
	set_scope(node, root);
	return root;
}

class ScopeGenerator : PermissiveVisitor {
	alias visit = PermissiveVisitor.visit;
	
	Scope result;
	this (Scope root = null) {
		result = root;
	}
	
	// symbols
	override void visit(LetDecl node) {
		result.add_symbol(new Variable(node, result));
	}
	override void visit(ArgDecl node) {
		result.add_symbol(new Argument(node, result));
	}
	
	// scope symbols
	override void visit(FuncDecl node) {
		auto parent = result;
		scope(exit) result = parent;
		
		// create new scope
		result = new Scope(SCP.func, node, parent);
		// set this scope to parent
		parent.add_symbol(new Function(node, parent, result));
		
		// set scope
		node.scp = result;
		// sub nodes
		foreach (arg; node.args) {
			if (arg) arg.accept(this);
		}
		if (node.body) node.body.accept(this);
	}
	
	// others
	override void visit(BlockExpr node) {
		if (!node.is_func_body) result = new Scope(SCP.expr, node, result);
		scope(exit) if (!node.is_func_body) result = result.parent;
		
		// set scope
		node.scp = result;
		// sub nodes
		foreach (stmt; node.stmts) {
			if (stmt) stmt.accept(this);
		}
	}
	
	override void visit(ExprStmt node) {
		if (node.expr) node.expr.accept(this);
	}
	
}
