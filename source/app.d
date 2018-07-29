module cornerstone;

import std.stdio;
import std.string;
import std.file;
import std.path;
import std.uni;
import std.range;
import std.conv;

import parse;
import test;
import identity;

void main(string[] args) {
	if (args.length == 1) {
		// writeln("No argument provided.");
		auto grammar = parseFile("docs/backbone-grammar");
		grammar.generateIdentity;

	} else if (args[1] == "test") {

		test.test;
	} else {
		auto program = parseFile(args[1]);
		program.generateIdentity;
		writeln(program.toString());
	}
}

unittest {
	test.test;
}