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
// import verification;
import verbose_check : generateVerification;


void main(string[] args) {
    if (args.length == 1) {
        // writeln("No argument provided.");
        import grammarcheck : test; test();
//        parseFile("docs/backbone-grammar").generateVerification;

    } else if (args[1] == "gen") {
        parseFile("docs/backbone-grammar").generateVerification;
    } else {
        auto program = parseFile(args[1]);
        writeln(program.toString());
    }
}

unittest {
    test.test;
}