module cornerstone;

import std.stdio;
import std.file   : chdir, write;
import std.process;

import parse;
import test;
import indentio;
import verbose_check : generateVerification;


void main(string[] args) {
    
    indentio.isPrinting = false;
    parseFile("docs/backbone-grammar").generateVerification;

    File("checker/source/grammarcheck.d", "w").write(indentio.acc);
    
    // if (args.length == 1) {
    //     writeln("No argument provided.");
    //     import grammarcheck : test; test();
    // } else if (args[1] == "gen") {
    //     parseFile("docs/backbone-grammar").generateVerification;
    // } else {
    //     auto program = parseFile(args[1]);
    //     writeln(program.toString());
    // }
}

unittest {
    test.test;
}