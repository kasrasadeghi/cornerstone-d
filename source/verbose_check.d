import std.algorithm;
import std.range;
import std.conv;
import std.ascii;

import texp;
import indentio : indent, dedent, print, println;
import grammar  : makeDict, printGrammar;

/// generates the identity traversal
void generateVerification(Texp grammar) {

    // grammar.printGrammar;
    auto gmap = grammar.makeDict;
    // auto prods = gmap.foldTraversal("Program");
    "import texp;".println;
    "import std.algorithm;".println;
    "import result;".println;
    "import indentio;".println;
    "R matchValueClass(string a, string b) { return new R(true, \"trivial success\"); }".println;
    "".println;
    
    // gmap = filter!((key, value) => key in ["Program", "TopLevel", "StrTable", "StrTableEntry"])(gmap);

    // gmap.productionVerification("Program");

    gmap.keys.each!(prod => gmap.productionVerification(prod));

    `
void test() {
  import parse : parse;
  import std.conv;
  import std.stdio;

  parseFile("docs/hello.bb").isProgram.writeln;
  //"(decl puts (type i8*) i32)".dup.parse()[0].isStrTable.to!string.writeln;
}
   `.println;
}

/// creates a traversal from a production in a grammar
void productionVerification(Texp[string] grammar, string current) {
    ("R is" ~ current ~"(Texp texp) {").println; indent();
    scope(exit) {dedent();"}".println;}

    Texp rule = grammar[current];
    if (rule.value == "|") {
        ("(\"searching "~ current ~" with \" ~ texp.paren).println;").println;
        foreach (c; rule.children) {
            ("if (" ~ "texp".evalVerify(c) ~ "._result) {").println;
            indent();
            ("return new R(true, \"in " ~ current ~ " matched " ~ c.svalue ~ "\");").println;
            dedent();
            "}".println;
        }
        ("return new R(false, texp.svalue ~ \"matched no " ~ current ~ "\");").println;
    } else {
        string[] checks;
        if ()
        checks ~= "newe R(texp.children.length"
        if (rule.value[0] == '#' || rule.value[0].isUpper) {
            checks ~= "texp".evalVerify(rule);
        } else {
            checks ~= ("new R(" ~ "texp".evalVerify(rule) ~ ", \"does \" ~ texp.svalue ~ \" match " ~ rule.svalue ~ "?\")");
        }
        foreach (num, c; rule.children.enumerate) {
            if (c.svalue == "*") {
                checks ~= "texp.children["~num.to!string~" .. $].map!(c => " ~ "c".evalVerify(c.children[0]) ~ ").fold!((a, b) => a & b)";
            } else {
                checks ~= ("texp.children[" ~ num.to!string ~ "]").evalVerify(c);
            }
        }
        ("texp.paren.println;").println;
        ("\"" ~ rule.paren ~ "\".println;").println;
        ("return " ~ checks.join("\n       & ") ~ ";").println;
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