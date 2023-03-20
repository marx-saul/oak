module message;

import token;
import std.stdio;

void error(LOC loc, string[] msgs...) {
	if (loc != LOC.init) write(loc.toString(), ": ");
	write("\x1b[31mError:\x1b[0m ");
	show_message(msgs);
}

void warning(LOC loc, string[] msgs...) {
	if (loc != LOC.init) write(loc.toString(), ": ");
	write("\x1b[33mWarning:\x1b[0m ");
	show_message(msgs);
}

private void show_message(string[] msgs...) {
	foreach (msg; msgs) {
		write(msg);
	}
	writeln();
}
