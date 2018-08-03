import std.algorithm;
import std.range;
import std.conv;
import std.ascii;

import texp;
import indentio : indent, dedent, print, println;
import grammar  : makeDict, printGrammar;

/// generates verification code
void generateVerification(Texp grammar) {

    // grammar.printGrammar;
    auto gmap = grammar.makeDict;
    // auto prods = gmap.foldTraversal("Program");
    `
import texp;.println;
import std.algorithm;
import result;
import indentio;
R matchValueClass(string a, string b) { return new R(true, "trivial success"); }
`.println;
    
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
        checks ~= "texp".evalVerify(rule);
        // if (rule.value[0] == '#' || rule.value[0].isUpper) {
        //     checks ~= "texp".evalVerify(rule);
        // } else {
        //     checks ~= ("new R(" ~ "texp".evalVerify(rule) ~ ", \"does \" ~ texp.svalue ~ \" match " ~ rule.svalue ~ "?\")");
        // }
        if (rule.children[$ - 1].isMany) {
            const child_count = rule.children.length;
            assert (child_count >= 1, rule.paren ~ " failed child_count >= 1.");
            checks ~= "texp.children.length >=" ~ (child_count - 1).to!string;
        }
        checks ~= `new R(texp.children.length > `;
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

/// if a texp's value is capitalized in a grammar, it leads to a future production
bool isProd(Texp t) { return t.value[0].isUpper; }

/// if a texp's value starts with a #, then it's a value class
bool isValueClass(Texp t) { return t.value[0] == '#'; }

/// checks if a texp represents a klein star
bool isMany(Texp t) { return t.svalue == "*"; }

/// checks if a texp represents a choice
bool isChoice(Texp t) { return t.value == "|"; }


/// evaluate the verification of a name with respect to a Texp's value
/// @param name is always expected to be the name of a texp.
/// results in a representation of R
string evalVerify(string name, Texp t) {
    if (t.isProd) {
        return name ~ ".is" ~ t.svalue;
    }
    if (t.isValueClass) {
        return name ~ ".svalue.matchValueClass(\"" ~ t.value[1 .. $].to!string ~ "\")";
    }
    assert (t.value[0].isLower);
    const cond = name ~ ".svalue == \"" ~ t.svalue ~ "\"";
    return `new R(` ~ cond ~ `, "does " ~ texp.svalue ~ " match ` ~ t.svalue ~ `?")`;
}