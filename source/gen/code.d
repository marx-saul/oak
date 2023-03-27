// 3-address code
module gen.code;

import std.conv: to;

enum SRC {
	error,

	temp,		// temp var
	result,		// result var
	stack,		// stack pointer
	int_,		// integer literal
	label,
}

abstract class Source {
	SRC kind;
	
	this (SRC kind) {
		this.kind = kind;
	}
}

final class Temp : Source {
	uint size;		// byte size
	uint num;		// identifying the temp var
	
	this (uint size, uint num) {
		this.size = size;
		this.num = num;
		super(SRC.temp);
	}
	
	override string toString() {
		return "t" ~ num.to!string ~ "(" ~ (size*8).to!string ~ ")"; 
	}
}

final class Result : Source {
	uint size;		// byte size
	uint num;		// identifying the result var
	
	this (uint size, uint num) {
		this.size = size;
		this.num = num;
		super(SRC.result);
	}
	
	override string toString() {
		return "r" ~ num.to!string ~ "(" ~ (size*8).to!string ~ ")"; 
	}
}


final class Stack : Source {
	uint size;
	ptrdiff_t address;	// stack_bottom + address
	
	this (uint size, ptrdiff_t address) {
		this.size = size;
		this.address  = address;
		super(SRC.stack);
	}
	
	override string toString() {
		return "s" ~ address.to!string ~ "(" ~ (size*8).to!string ~ ")";
	}
}

final class Int : Source {
	uint size;		// size
	long val;		// value
	
	this (uint size, long val) {
		this.size = size;
		this.val = val;
		super(SRC.int_);
	}
	
	override string toString() {
		return val.to!string~ "(" ~ (size*8).to!string ~ ")";
	}
}

final class Label : Source {
	string name;	// the label name
	bool is_sec;	// is section name (the program is devided into program sections)

	this (string name, bool is_sec = false) {
		this.name = name;
		this.is_sec = is_sec;
		super(SRC.label);
	}
	
	override string toString() {
		if (is_sec) return "[" ~ name ~ "]";
		else return "@" ~ name;
	}
}

/* ********************************************************************************* */

enum OpCode {
	error,	
	
	move,		// assign
	
	add,
	sub,
	mul,
	div,
	mod,
	
	inv,		// reverse the sign
	deref32,
	deref64,
	
	ifgo,		// ifgo Var Label : if Var != 0 then goto Label
	//goto_,
	start_call,
	
	push,		// push N : push N byte
	push32,
	push64,
	pop,		// pop N : pop N byte
	pop32,
	pop64,
	
	ret,
	
	halt,
	
	access,		// special operator
}

class Operation {
	OpCode opcode;		// operator code
	Source s1;			// source 1
	Source s2;			// source 2
	Source dest;		// destination
	bool is_deref;		// is the destination derefed 
	
	this (OpCode opcode, Source s1, Source s2, Source dest, bool is_deref) {
		this.opcode = opcode;
		this.s1 = s1;
		this.s2 = s2;
		this.dest = dest;
		this.is_deref = is_deref;
	}
	
	string label_name;
	
	override string toString() {
		string result = label_name.length > 0 ? "@" ~ label_name ~ ": " : "";
		if (is_deref) result ~= "*";
		
		with (OpCode)
		final switch (opcode) {
		case error:
			assert(0);
		
		case move:
			result ~= dest.toString() ~ " = " ~ s1.toString();
			break;
			
		case add:
			result ~= dest.toString() ~ " = " ~ s1.toString() ~ " + " ~ s2.toString();
			break;
			
		case sub:
			result ~= dest.toString() ~ " = " ~ s1.toString() ~ " - " ~ s2.toString();
			break;
			
		case mul:
			result ~= dest.toString() ~ " = " ~ s1.toString() ~ " * " ~ s2.toString();
			break;
			
		case div:
			result ~= dest.toString() ~ " = " ~ s1.toString() ~ " / " ~ s2.toString();
			break;
			
		case mod:
			result ~= dest.toString() ~ " = " ~ s1.toString() ~ " % " ~ s2.toString();
			break;
			
		case inv:
			result ~= dest.toString() ~ " = - " ~ s1.toString();
			break;
		
		case deref32:
			result ~= dest.toString() ~ " = *(32) " ~ s1.toString();
			break;
		
		case deref64:
			result ~= dest.toString() ~ " = *(64) " ~ s1.toString();
			break;
		
		case ifgo:
			if (s1.toString() == "1(32)")
				result ~= "goto " ~ s2.toString();
			else
				result ~= "if " ~ s1.toString() ~ " goto " ~ s2.toString();
			break;
		
		case start_call:
			result = "start_call";
			break;
		
		case push:
			result ~= "push " ~ s1.toString();
			break;
		
		case push32:
			result ~= "push32 " ~ s1.toString();
			break;
			
		case push64:
			result ~= "push64 " ~ s1.toString();
			break;
		
		case pop:
			result ~= "pop " ~ s1.toString();
			break;
		
		case pop32:
			result ~= "pop32 " ~ (dest ? dest.toString() : "");
			break;
		
		case pop64:
			result ~= "pop64 " ~ (dest ? dest.toString() : "");
			break;
		
		case ret:
			result ~= "ret";
			break;
		
		case halt:
			result ~= "halt";
			break;
		
		case access:
			result ~= "access " ~ s1.toString()[1 .. $];
			if (s2) result ~= " " ~ s2.toString();
			break;
		}
		
		return result;
	}
	
	static Operation move(Source s1, Source dest, bool is_deref) {
		return new Operation(OpCode.move, s1, null, dest, is_deref);
	}
	static Operation add(Source s1, Source s2, Source dest, bool is_deref) {
		return new Operation(OpCode.add, s1, s2, dest, is_deref);
	}
	static Operation sub(Source s1, Source s2, Source dest, bool is_deref) {
		return new Operation(OpCode.sub, s1, s2, dest, is_deref);
	}
	static Operation mul(Source s1, Source s2, Source dest, bool is_deref) {
		return new Operation(OpCode.mul, s1, s2, dest, is_deref);
	}
	static Operation div(Source s1, Source s2, Source dest, bool is_deref) {
		return new Operation(OpCode.div, s1, s2, dest, is_deref);
	}
	static Operation mod(Source s1, Source s2, Source dest, bool is_deref) {
		return new Operation(OpCode.mod, s1, s2, dest, is_deref);
	}
	static Operation inv(Source s1, Source dest, bool is_deref) {
		return new Operation(OpCode.inv, s1, null, dest, is_deref);
	}
	
	static Operation deref32(Source s1, Source dest, bool is_deref) {
		return new Operation(OpCode.deref32, s1, null, dest, is_deref);
	}
	static Operation deref64(Source s1, Source dest, bool is_deref) {
		return new Operation(OpCode.deref64, s1, null, dest, is_deref);
	}
	
	static Operation ifgo(Source s1, Source s2) {
		assert (s2 && s2.kind == SRC.label);
		return new Operation(OpCode.ifgo, s1, s2, null, false);
	}
	static Operation goto_(Source s2) {
		assert (s2 && s2.kind == SRC.label);
		return new Operation(OpCode.ifgo, new Int(4, 1), s2, null, false);
	}
	static Operation start_call() {
		return new Operation(OpCode.start_call, null, null, null, false);
	}
	
	static Operation push(Source s1) {
		return new Operation(OpCode.push, s1, null, null, false);
	}
	static Operation push32(Source s1) {
		return new Operation(OpCode.push32, s1, null, null, false);
	}
	static Operation push64(Source s1) {
		return new Operation(OpCode.push64, s1, null, null, false);
	}
	static Operation pop(Source s1) {
		return new Operation(OpCode.pop, s1, null, null, false);
	}
	static Operation pop32(Source dest, bool is_deref) {
		return new Operation(OpCode.pop32, null, null, dest, is_deref);
	}
	static Operation pop64(Source dest, bool is_deref) {
		return new Operation(OpCode.pop64, null, null, dest, is_deref);
	}
	static Operation ret() {
		return new Operation(OpCode.ret, null, null, null, false);
	}
	
	static Operation halt() {
		return new Operation(OpCode.halt, null, null, null, false);
	}
	
	static Operation access(Source s1, Source s2 = null) {
		return new Operation(OpCode.access, s1, s2, null, false);
	}
}

/* ********************************************************************************* */

class CodeSection {
	string name;
	Operation[] code;
	
	this (string name, Operation[] code) {
		this.name = name;
		this.code = code;
	}
	
	override string toString() {
		auto result = "[" ~ name ~ "]\n";
		foreach (op; code) {
			result ~= op.toString() ~ "\n";
		}
		return result;
	}
	
	// return the code address of the label
	private size_t[string] _labels = null;
	size_t label_address(string str) {
		// initialize
		if (_labels is null) {
			size_t[string] _labels0;
			_labels = _labels0;
			foreach (index, op; code) {
				if (op.label_name.length > 0) {
					assert(op.label_name !in _labels);
					_labels[op.label_name] = index;
				}
			}
		}
		
		if (auto p = str in _labels) return *p;
		else assert(0);
	}
	
	// the number of temp variables
	uint tmp_num() @property {
		import std.algorithm;
		if (!tmp_num_calculated) {
			foreach (op; code) {
				if (op.dest && op.dest.kind == SRC.temp) _tmp_num = max(_tmp_num, (cast(Temp) op.dest).num);
			}
		}
		return _tmp_num+1;
	}
	private uint _tmp_num;
	private bool tmp_num_calculated;
	
	// the number of result variables
	uint result_num() @property {
		import std.algorithm;
		if (!result_num_calculated) {
			foreach (op; code) {
				if (op.dest && op.dest.kind == SRC.result) _result_num = max(_result_num, (cast(Result) op.dest).num);
			}
		}
		return _result_num+1;
	}
	private uint _result_num;
	private bool result_num_calculated;
	
	// for requesting new labels
	private uint _label_num = 0;
	string new_label() @property {
		import std.conv: to;
		return (_label_num++).to!string;
	}
}

class Program {
	CodeSection[] code_secs;
	void[] data;			// static data
	
	this (CodeSection[] code_secs, void[] data) {
		this.code_secs = code_secs;
		this.data = data;
	}
	
	override string toString() {
		import std.conv: to;
		string result = data.to!string ~ "\n";
		foreach (cs; code_secs) {
			result ~= cs.toString() ~ "\n";
		}
		return result;
	}
	
	// return the code address of the label
	private size_t[string] _sec_names = null;
	size_t sec_address(string str) {
		// initialize
		if (_sec_names is null) {
			size_t[string] _sec_names0;
			_sec_names = _sec_names0;
			foreach (index, cs; code_secs) {
				assert(cs.name !in _sec_names);
				_sec_names[cs.name] = index;
			}
		}
		
		if (auto p = str in _sec_names) return *p;
		else return code_secs.length;
	}
}

CodeSection to_code_sec(string str) {
	import std.array;
	auto code_strs = str.split("\n");
	auto name = code_strs[0][1 .. $-1];
	Operation[] code;
	foreach (ref i, cs; code_strs[1 .. $]) {
		if (cs.length == 0) continue;
		if (cs[0] == '@') {
			// set label name
			auto label_name = cs[1 .. $];
			++i;
			auto op = code_strs[i+1].to_operation();
			if (op) {
				op.label_name = label_name;
				code ~= op;
			}
			else continue;
		}
		else {
			auto op = cs.to_operation();
			if (op) code ~= op;
		}
	}
	
	auto result = new CodeSection(name, code);
	return result;
}

Operation to_operation(string str) {
	import std.array, std.ascii;
	auto strs = str.split!isWhite;
	if (strs.length == 0) return null;
	
	// operation first
	switch (strs[0]) {
	case "ifgo":
		auto s1 = strs[1].to_source();
		auto s2 = strs[2].to_source();
		assert(s2.kind == SRC.label);
		return Operation.ifgo(s1, s2);
		
	case "goto":
		auto s2 = strs[1].to_source();
		assert(s2.kind == SRC.label);
		return Operation.goto_(s2);
	
	case "start_call":
		return Operation.start_call();
	
	case "push":
		return Operation.push(strs[1].to_source());
		
	case "push32":
		return Operation.push32(strs[1].to_source());
		
	case "push64":
		return Operation.push64(strs[1].to_source());
	
	case "pop":
		return Operation.pop(strs[1].to_source());
	
	case "pop32":
		auto dest_str = strs[1];
		bool is_deref = dest_str[0] == '*';
		if (is_deref) dest_str = dest_str[1 .. $];
		auto dest = dest_str.to_source();
		return Operation.pop32(dest, is_deref);
		
	case "pop64":
		auto dest_str = strs[1];
		bool is_deref = dest_str[0] == '*';
		if (is_deref) dest_str = dest_str[1 .. $];
		auto dest = dest_str.to_source();
		return Operation.pop64(dest, is_deref);
	
	case "ret":
		return Operation.ret();
	
	case "halt":
		return Operation.halt();
	
	case "access":
		if (strs.length == 2) 
			return Operation.access(new Label(strs[1]));
		else
			return Operation.access(new Label(strs[1]), strs[2].to_source());
	
	default:
		break;
	}
	
	// destination first
	auto dest_str = strs[0];
	bool is_deref = strs[0][0] == '*';
	if (is_deref) dest_str = dest_str[1 .. $];
	auto dest = dest_str.to_source();
	
	assert(strs[1] == "=");
	
	// dest = op
	if (strs[2] == "*(32)") {
		return Operation.deref32(strs[3].to_source(), dest, is_deref);
	}
	else if (strs[2] == "*(64)") {
		return Operation.deref64(strs[3].to_source(), dest, is_deref);
	}
	else if (strs[2] == "-") {
		return Operation.inv(strs[3].to_source(), dest, is_deref);
	}
	
	// dest = s1
	// dest = s1 op s2
	auto s1 = strs[2].to_source();
	if (strs.length == 3) return Operation.move(s1, dest, is_deref);
	
	auto s2 = strs[4].to_source();
	
	switch (strs[3]) {
	case "+":
		return Operation.add(s1, s2, dest, is_deref);
	case "-":
		return Operation.sub(s1, s2, dest, is_deref);
	case "*":
		return Operation.mul(s1, s2, dest, is_deref);
	case "/":
		return Operation.div(s1, s2, dest, is_deref);
	case "%":
		return Operation.mod(s1, s2, dest, is_deref);
	default:
		assert(0);
	}
}

private immutable DEFAULT_SIZE = "32";

Source to_source(string str) {
	import std.typecons, std.conv: to;
	
	if (str.length == 0) assert(0);
	
	// "123(89)" -> ("123", "89")
	Tuple!(string, string) split(string s) {
		size_t index = s.length;
		foreach (i, c; s) {
			if (c == '(') index = i;
		}
		if (index < s.length)
			return tuple(s[0 .. index], s[index+1 .. $-1]);
		else
			return tuple(s[0 .. index], DEFAULT_SIZE);
	}
	
	switch (str[0]) {
	case 't':
		auto splitted = split(str[1 .. $]);
		return new Temp(splitted[1].to!uint / 8, splitted[0].to!uint);
	
	case 'r':
		auto splitted = split(str[1 .. $]);
		return new Result(splitted[1].to!uint / 8, splitted[0].to!uint);
	
	case 's':
		auto splitted = split(str[1 .. $]);
		return new Stack(splitted[1].to!uint / 8, splitted[0].to!ptrdiff_t);
	
	case '@':
		return new Label(str[1 .. $]);
		
	case '[':
		return new Label(str[1 .. $-1], true);
	
	case '-': case '0': case '1': case '2': case '3': case '4': case '5': case '6': case '7': case '8': case '9':
		auto splitted = split(str[0 .. $]);
		return new Int(splitted[1].to!uint / 8, splitted[0].to!long);
	
	default:
		assert(0, str);
	}
}
