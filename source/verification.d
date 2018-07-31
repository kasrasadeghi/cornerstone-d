import std.algorithm;
import std.range;
import std.conv;
import std.ascii;

import texp;
import indentio : indent, dedent, print, println;
import grammar  : makeDict;

/// generates the identity traversal
void generateVerification(Texp grammar) {
    // grammar.printGrammar;
    auto gmap = grammar.makeDict;
    // auto prods = gmap.foldTraversal("Program");

    "import texp;".println;
    "import std.algorithm;".println;
    "bool matchValueClass(string a, string b) { return true; }".println;
    "".println;

    gmap.keys.each!(prod => gmap.productionVerification(prod));
}

/// creates a traversal from a production in a grammar
void productionVerification(Texp[string] grammar, string current) {
    ("bool is" ~ current ~"(Texp texp) {").println; indent();
    scope(exit) {dedent();"}".println;}

    Texp rule = grammar[current];
    if (rule.value == "|") {
        ("return " ~ rule.children.map!(c => "texp".evalVerify(c)).join(" || ") ~ ";").println;
    } else {
        string[] checks;
        checks ~= "texp".evalVerify(rule);
        foreach (num, c; rule.children.enumerate) {
            if (c.svalue == "*") {
                checks ~= "texp.children["~num.to!string~" .. $].all!(c => " ~ "c".evalVerify(c.children[0]) ~ ")";
            } else {
                checks ~= ("texp.children[" ~ num.to!string ~ "]").evalVerify(c);
            }
        }
        ("return " ~ checks.join("\n      && ") ~ ";").println;
    }
}

/// evaluate the verification of a name with respect to a Texp's value
/// @param name is always expected to be the name of a texp.
string evalVerify(string name, Texp t) {
    if (t.value[0].isUpper) {
        return name ~ ".is" ~ t.svalue;
    }
    if (t.value[0] == '#') {
        return name ~ ".svalue.matchValueClass(\"" ~ t.value[1 .. $].to!string ~ "\")";
    }
    return name ~ ".svalue == \"" ~ t.svalue ~ "\"";
}