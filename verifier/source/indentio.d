import std.conv;
import std.range;
import std.stdio;

/// keeps track of indents for print and println
int indent_count = 0;

/// whether or not indentio actions actually print, or just accumulate
bool isPrinting = true;

/// indent++
void indent() {
    .indent_count++;
}

void dedent() {
    .indent_count--;
    assert(.indent_count >= 0);
}

/// accumulate print results for backtracking
string acc;

/// super write
void print(T)(T arg) {
    // only when we have not just printed a newline do we indent
    if (acc.length == 0 || acc[$ - 1] == '\n') {
        acc ~= "  ".replicate(indent_count);
        if (isPrinting) "  ".replicate(indent_count).write;
    }
    acc ~= arg.to!string;
    if (isPrinting) arg.to!string.write;
}

/// super writeln
void println(T)(T arg) {
    (arg.to!string ~ "\n").print;
}