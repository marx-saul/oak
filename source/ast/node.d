module ast.node;

import token;
import visitor.visitor;

class Node {
	LOC loc;
	
	this (LOC loc = LOC.init) { this.loc = loc; }
	
	void accept(Visitor v) { v.visit(this); }
}
