import std.string : splitLines;
import std.algorithm : map;
import std.array : join;

string indentLines(string text) {
    return text.splitLines.map!(l => "  " ~ l).join("\n");
}