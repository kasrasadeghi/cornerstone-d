module cornerstone;

import std.stdio;
import std.file : chdir, write;
import std.process;
import std.path : baseName, dirName;

import parse;
import test;
import indentio;
import imp_result_check : generateVerification;


void main(string[] args) {
    
    indentio.isPrinting = false;
    string curr = __FILE_FULL_PATH__;
    while (curr.baseName != "cornerstone-d") {
        curr = curr.dirName;
    }
    chdir(curr);
    parseFile("docs/hello-grammar").generateVerification;

    File("checker/source/grammarcheck.d", "w").write(indentio.acc);
}

unittest {
    test.test;
}