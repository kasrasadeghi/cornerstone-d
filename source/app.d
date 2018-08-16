module cornerstone;

import std.stdio;
import std.file   : chdir, write;
import std.process;

import parse;
import test;
import indentio;
import result_check : generateVerification;


void main(string[] args) {
    
    indentio.isPrinting = false;
    parseFile("docs/def-grammar").generateVerification;

    File("checker/source/grammarcheck.d", "w").write(indentio.acc);
}

unittest {
    test.test;
}