import std.stdio;
import std.file;
import std.path;
import std.algorithm;
import std.range;


/// test root
void test() {
    testDir("parser");
}

/// location of the tests/ directory
const testRoot = `D:\projects\cornerstone-tests\tests\`;

/// test a directory of tests
void testDir(string dirname) {
    auto ls = (testRoot~dirname)
        .dirEntries(SpanMode.breadth)
        .map!(x => x.name.baseName)
        .save;

    foreach (f; ls) {
        writeln("  "~f);
    }

    

    writeln(ls);

    auto tests = ls
        .filter!(x => x.endsWith(".bb"));

    // auto tests = ls
    //     .filter!(x => x.endsWith(".bb"))
    //     .filter!(x => ls.canFind(x[0 .. $ - 3]~".ok"));
    
    writeln("tests");
    foreach (t;tests) {
        writeln("    "~t);
    }
}
