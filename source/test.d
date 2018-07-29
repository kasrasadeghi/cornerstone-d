import std.stdio;
import std.file;
import std.path;
import std.algorithm;
import std.range;
import std.array;


/// test root
void test() {
    writeln();
    testDir("parser");
    // testDir("");
}

/// location of the tests/ directory
const testRoot = `D:\projects\cornerstone-tests\tests\`;

/// test a directory of tests
void testDir(string dirname) {
    writeln("testing directory: "~dirname);

    auto ls = (testRoot~dirname)
        .dirEntries(SpanMode.breadth)
        .map!(x => x.name)
        .array;

    auto tests = ls
        .filter!(x => x.endsWith(".bb"))
        .filter!(x => ls.canFind(x[0 .. $ - 3]~".ok"));
    
    writeln("tests");
    tests.each!(t => writeln("  "~t));
}
