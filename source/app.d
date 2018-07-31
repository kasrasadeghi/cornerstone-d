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
import verification;


void main(string[] args) {
	if (args.length == 1) {
		// writeln("No argument provided.");
		static if ("source/grammarcheck.d") {
			parseFile("docs/backbone-grammar").generateVerification;
		} else {
			import grammarcheck;
			parseFile("docs/hello.bb").isProgram.writeln;
		}
	} else if (args[1] == "test") {

		test.test;
	} else {
		auto program = parseFile(args[1]);
		writeln(program.toString());
	}
}

unittest {
	test.test;
}