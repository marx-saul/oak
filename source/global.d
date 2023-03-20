module global;

// the size of pointer. Same as the size of registers
immutable PTR_SIZE = 8;

// currently every value is 4-byte size
immutable VALUE_SIZE = 4;

string unique_label() {
	import std.conv;
	static int count = 0;
	return (count++).to!string;
}
