module gen.exec;

import global;
import gen.code;

import std.conv, std.algorithm;

import std.stdio : writeln;
unittest {
	writeln("########### gen/exec.d");
	auto cs_main = to_code_sec(
`[main]
start_call
push32 257
push32 34
goto [f]
pop32 t0
access log32 t0

halt`
	);

	auto cs_func = to_code_sec(
`[f]
t0 = *(32) s0
t1 = *(32) s4
t2 = t0 % t1
r0 = t2
ret`);
	
	auto program = new Program([cs_main, cs_func], []);
	
	program.execute();
}

struct SourceVal {
	uint size;
	union {
		int  int32;
		long int64;
		string label;
	}
	
	SourceVal opBinary(string op)(SourceVal right)
	if (op.among!("+", "-", "*", "/", "%"))
	{
		SourceVal result;
		mixin ("result.int64 = this.int64 " ~ op ~ "right.int64;");
		result.size = max(this.size, right.size);
		return result;
	}
	
	SourceVal opUnary(string op)()
	if (op == "-")
	{
		SourceVal result;
		mixin("result.int64 = " ~ op ~ "this.int64;");
		result.size = this.size;
		return result;
	}
}

auto executer(Program program, const size_t stack_size = 2 ^^ 20) {
	auto stack = program.data.dup;
	auto stack_top = stack.length;
	stack.length = stack_size;
	int* to_int32_ptr(long index) {
		assert (index+4 <= min(stack_top, stack_size+1));
		return cast(int*) stack + index;
	}
	long* to_int64_ptr(long index) {
		assert (index+8 <= min(stack_top, stack_size+1));
		return cast(long*) stack + index;
	}
	
	void change_stack_ptr(int diff) {
		if (stack_top + diff >= stack_size) assert(0, "stack overflow");
		stack_top += diff;
	} 
	
	// stacks for program section gotos
	size_t[] sec_stacks = [0];				// the sections that are called
	size_t[] code_ptrs = [0];				// code pointers
	size_t[] stack_ptrs = [stack_top];	// stack pointers
	
	SourceVal[][] tmps = [new SourceVal[program.code_secs[0].tmp_num]];							// tmp variables
	SourceVal[][] results = [new SourceVal[program.code_secs[0].result_num]];					// result variables
	
	// get the source value from the source
	SourceVal get_val(Source s) {
		with (SRC)
		final switch (s.kind) {
		case error:
			assert(0);
			
		case temp:
			auto t = cast(Temp) s;
			return tmps[$-1][t.num];
		
		case result:
			auto t = cast(Result) s;
			return results[$-1][t.num];
		
		case stack:
			auto t = cast(Stack) s;
			SourceVal val;
			val.size = PTR_SIZE;
			val.int64 = cast(long) (stack_ptrs[$-1] + t.address);
			return val;
		
		case int_:
			auto t = cast(Int) s;
			SourceVal val;
			switch (t.size) {
			case 4:
				val.size = 4;
				val.int32 = cast(int) t.val;
				break;
			
			case 8:
				val.size = 8;
				val.int64 = cast(long) t.val;
				break;
			
			default:
				assert(0);
			}
			return val;
		
		case label:
			assert(0);
		}
	}
	
	void set_val(Source dest, bool is_deref, SourceVal val) {
		with (SRC)
		switch (dest.kind) {
		case temp:
			auto t = cast(Temp) dest;
			if (!is_deref) {
				tmps[$-1][t.num] = val;
			}
			else {
				assert (t.size == PTR_SIZE);
				if (val.size == 4) 
					*to_int32_ptr(tmps[$-1][t.num].int64) = val.int32;
				else if (val.size == 8)
					*to_int64_ptr(tmps[$-1][t.num].int64) = val.int64;
				else assert(0);
			}
			break;
		
		case result:
			auto t = cast(Result) dest;
			results[$-1][t.num] = val;
			break;
		
		case stack:
			auto t = cast(Stack) dest;
			assert(is_deref && t.size == val.size);
			
			switch (t.size) {
			case 4:
				*to_int32_ptr(stack_ptrs[$-1] + t.address) = val.int32;
				break;
				
			case 8:
				*to_int64_ptr(stack_ptrs[$-1] + t.address) = val.int64;
				break;
				
			default:
				assert(0);
			}
			break;
		
		default:
			assert(0);
		}
	}
	
	// current code section
	CodeSection code_sec() @property {
		return program.code_secs[sec_stacks[$-1]];
	}
	// current operation
	Operation operation() @property {
		return code_sec.code[code_ptrs[$-1]];
	}
	// to the next code
	void next() {
		++code_ptrs[$-1];
	}
	
	// 0 : continue, 1 : halt
	int one_step(bool show_code = false) {
		import std.stdio: writeln;
		if (show_code) writeln(code_ptrs[$-1], ": ", operation);
		
		with (OpCode)
		final switch (operation.opcode) {
		case error:
			assert(0);
		
		case move:
			set_val(operation.dest, operation.is_deref, get_val(operation.s1));
			break;
		
		case add:
			set_val(operation.dest, operation.is_deref, get_val(operation.s1) + get_val(operation.s2));
			break;
		case sub:
			set_val(operation.dest, operation.is_deref, get_val(operation.s1) - get_val(operation.s2));
			break;
		case mul:
			set_val(operation.dest, operation.is_deref, get_val(operation.s1) * get_val(operation.s2));
			break;
		case div:
			set_val(operation.dest, operation.is_deref, get_val(operation.s1) / get_val(operation.s2));
			break;
		case mod:
			set_val(operation.dest, operation.is_deref, get_val(operation.s1) % get_val(operation.s2));
			break;
		
		case inv:
			set_val(operation.dest, operation.is_deref, -get_val(operation.s1));
			break;
	
		case deref32:
			auto ptr = to_int32_ptr(get_val(operation.s1).int64);
			SourceVal sv;
			sv.size = 4;
			sv.int32 = *ptr;
			set_val(operation.dest, operation.is_deref, sv);
			break;
		
		case deref64:
			auto ptr = to_int64_ptr(get_val(operation.s1).int64);
			assert (get_val(operation.s1).int64 + 8 < stack_top);
			SourceVal sv;
			sv.size = 8;
			sv.int64 = *ptr;
			set_val(operation.dest, operation.is_deref, sv);
			break;
	
		case ifgo:
			auto flag = get_val(operation.s1).int64;
			if (flag != 0) {
				auto ls = cast(Label) operation.s2;
				// section call
				if (ls.is_sec) {
					sec_stacks ~= program.sec_address(ls.name);
					code_ptrs ~= 0;
					//stack_ptrs ~= stack_top;
					tmps ~= [ new SourceVal[code_sec.tmp_num] ];
					results ~= [ new SourceVal[code_sec.result_num] ];
					// stack pointer is stocked by user using "start_call"
				}
				// label call
				else {
					code_ptrs[$-1] = code_sec.label_address(ls.name);
				}
				return 0;
			}
			break;
		
		case start_call:
			stack_ptrs ~= stack_top;
			break;
	
		case push:
			stack_top += get_val(operation.s1).int64;
			break;
			
		case push32:
			change_stack_ptr(4);
			*to_int32_ptr(stack_top-4) = get_val(operation.s1).int32;
			break;
			
		case push64:
			change_stack_ptr(8);
			*to_int64_ptr(stack_top-8) = get_val(operation.s1).int64;
			break;
		
		case pop:
			stack_top -= get_val(operation.s1).int64;
			break;
		
		case pop32:
			auto ptr = to_int32_ptr(stack_top - 4);
			SourceVal sv; sv.size = 4; sv.int32 = *ptr;
			if (operation.dest)
				set_val(operation.dest, operation.is_deref, sv);
			change_stack_ptr(-4);
			break;
			
		case pop64:
			auto ptr = to_int64_ptr(stack_top - 8);
			SourceVal sv; sv.size = 8; sv.int64 = *ptr;
			if (operation.dest)
				set_val(operation.dest, operation.is_deref, sv);
			change_stack_ptr(-8);
			break;
			
		case ret:
			sec_stacks.length -= 1;
			code_ptrs.length -= 1;
			stack_ptrs.length -= 1;
			tmps.length -= 1;
			
			// rollback the stack pointer
			stack_top = stack_ptrs[$-1];
			// push results
			foreach (sv; results[$-1]) {
				switch (sv.size) {
				case 4:
					change_stack_ptr(4);
					*to_int32_ptr(stack_top-4) = sv.int32;
					break; 
				case 8:
					change_stack_ptr(8);
					*to_int64_ptr(stack_top-8) = sv.int64;
					break; 
				default: assert(0);
				}
			}
			
			results.length -= 1;
			
			break;
	
		case halt:
			return 1;
		
		case access:
			assert (operation.s1.kind == SRC.label);
			auto code_name = (cast(Label) operation.s1).name;
			switch (code_name) {
			case "log32":
				import std.stdio : writeln;
				writeln("ACCESS LOG (32) : ", get_val(operation.s2).int32);
				break;
			default:
				assert(0, "Unknown access operation : " ~ code_name);
			}
		}
		
		next();
		return 0;
	}
	
	return &one_step;
}

void execute(Program program, bool show_code = false, const size_t stack_size = 2 ^^ 20) {
	auto one_step = executer(program, stack_size);
	while (1) {
		if (one_step()) break;
	}
}

