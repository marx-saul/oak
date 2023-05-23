module ast.node;

import token;
import visitor.visitor;

class Node {
	// syntax level
	LOC loc;
	this (LOC loc = LOC.init) { this.loc = loc; }
	
	// for semantic (if true, there is no more semantic things to be done)
	bool sem_ok = false;
	string[] error_msgs = null;
	void add_error(string msg) {
		if (!error_msgs) error_msgs = [msg];
		else error_msgs ~= msg;
	}
	
	void accept(Visitor v) { v.visit(this); }
}
