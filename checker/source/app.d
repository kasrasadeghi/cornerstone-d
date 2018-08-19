module cornerstone;

import std.stdio;
import std.path;
import grammarcheck : test;

void main(string[] args) {
    string curr = __FILE_FULL_PATH__;
    while (curr.baseName != "cornerstone-d") {
        curr = curr.dirName;
    }
    curr.writeln;
    test(curr ~ "/inputs/hello.bb");
}