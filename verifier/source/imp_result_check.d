import std.algorithm;
import std.range;
import std.conv;
import std.ascii;
import std.functional;

import texp;
import indentio : indent, dedent, print, println;
import grammar  : makeDict, printGrammar;

/// generates verification code
void generateVerification(Texp grammar) {

    // grammar.printGrammar;
    auto gmap = grammar.makeDict;
    // auto prods = gmap.foldTraversal("Program");
    `
import std.algorithm;
import std.stdio;
import std.range;

import texp;
import result;
import indentio;
import parse;
import value_class;
`.println;
    
    // gmap = filter!((key, value) => key in ["Program", "TopLevel", "StrTable", "StrTableEntry"])(gmap);

    // gmap.productionVerification("Program");

    gmap.keys.each!(prod => gmap.productionVerification(prod));

    `
void test(string filename) {
  import parse : parse;
  import std.conv;
  import std.stdio;

  "".println;

  auto r = parseFile(filename).isProgram;
  //auto r = "(decl puts (types i8*) i32)".dup.parse()[0].isDecl;

  "".println;
  r._result.writeln;
  r._message.writeln;
}
   `.println;
}

/// creates a traversal from a production in a grammar
void productionVerification(Texp[string] grammar, string current) {
    ("R is" ~ current ~"(Texp texp) {").println; indent();
    scope(exit) {dedent();"}".println;}

    Texp rule = grammar[current];
    if (rule.isChoice) {
        // choice verification
        ("(\"searching "~ current ~" with \" ~ texp.paren).println;").println;
        "R current_result;".println;
        foreach (c; rule.children) {
            ("current_result = " ~ "texp".evalVerify(c) ~ ";").println;
            ("if (current_result._result) ").print;
            block(() {
                (`(texp.paren ~ " ==> ` ~ c.paren ~ `").println;`).println;
                ("return new R(true, \"in " ~ current ~ " matched " ~ c.svalue ~ "\")\n        >> current_result;").println;
            });
        }
        ("return new R(false, texp.svalue ~ \" matched no " ~ current ~ "\");").println;
    } else {
        // tree regexp verification

        ("texp.paren.println;").println;
        ("\"" ~ rule.paren ~ "\".println;").println;
        "".println;
        "indent();".println;
        "scope(exit) dedent();".println;
        "".println;

        // - check length
        lengthVerify(rule);

        // - check value
        ("R value_check = " ~ "texp".evalVerify(rule) ~ ";").println;
        ("if (!value_check._result) ").print;
        block(() {
            `return new R(false, "failed: " ~ value_check._message);`.println;
        });
        
        // - check children
        Texp last = rule.children[$ - 1];

        // - if last is many and only,
        if (last.svalue == "*" && rule.children.length == 1) {
            // - process everything that might match the many
            (`foreach (num, c; texp.children[` ~ (rule.children.length - 1).to!string ~ " .. $].enumerate) ").print;
            block(() {
                (`R result_name = ` ~ "c".evalVerify(last.children[0]) ~ `;`).println;
                ("if (!result_name._result) ").print;
                block(() {
                    (`return new R(false, "failed matching ` ~ last.children[0].paren ~ `");`).println;
                });
            });
        } else

        // - if last is many,
        if (last.svalue == "*") {
            // - process everything before many with zip
            foreach (num, c; rule.children[0 .. $ - 1].enumerate) {
                string result_name = "child" ~ num.to!string ~ "_check";
                ("R " ~ result_name ~ " = " ~ ("texp.children[" ~ num.to!string ~ "]").evalVerify(c) ~ ";").println;
                (`if (!` ~ result_name ~ `._result)`).print;
                block(() {
                    (`return ` ~ result_name ~ `;`).println;
                });
            }

            // - process everything that might match the many
            (`foreach (num, c; texp.children[` ~ (rule.children.length - 1).to!string ~ " .. $].enumerate)").print;
            block(() {
                (`R result_name = ` ~ "c".evalVerify(last.children[0]) ~ `;`).println;
                ("if (!result_name._result)").print;
                block(() {
                    (`return new R(false, "failed matching ` ~ last.children[0].paren ~ `");`).println;
                });
            });
        } else {
            foreach (num, c; rule.children.enumerate) {
                string result_name = "child" ~ num.to!string ~ "_check";
                ("R " ~ result_name ~ " = " ~ ("texp.children[" ~ num.to!string ~ "]").evalVerify(c) ~ ";").println;
                (`if (!` ~ result_name ~ `._result)`).print; 
                block(() {
                    (`return ` ~ result_name ~ `;`).println;
                });
            }
        }

        "return value_check;".println;
    }
}

void block(void delegate() contents) {
    "{".println;
    indent();
    contents();
    dedent();
    "}".println;
}

/// if a texp's value is capitalized in a grammar, it leads to a future production
bool isProd(Texp t) { return t.value[0].isUpper; }

/// if a texp's value starts with a #, then it's a value class
bool isValueClass(Texp t) { return t.value[0] == '#'; }

/// checks if a texp represents a klein star
bool isMany(Texp t) { 
    const pass = t.svalue == "*";
    if (pass) {
        assert (t.children.length >= 1, t.paren ~ " should have more than one child because it is many");
    }
    return pass;
}

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
    assert (t.value[0].isLower, t.svalue ~ " does not start with a lowercase alpha");
    const cond = name ~ ".svalue == \"" ~ t.svalue ~ "\"";
    return `new R(` ~ cond ~ `, "does " ~ texp.svalue ~ " == ` ~ t.svalue ~ `?")`;
}

void lengthVerify(Texp rule) {
    const child_count = rule.children.length;
    if (rule.children[$ - 1].isMany) {
        auto length_check = "texp.children.length >= " ~ (child_count - 1).to!string;
        (`if (!(` ~ length_check ~ `)) {`).println;
        indent();
        (`return new R(false, texp.svalue ~ " doesn't have ` ~ (child_count - 1).to!string ~ ` or more children");`).println;
        dedent();
        "}".println;
    } else {
        auto length_check = "texp.children.length >= " ~ child_count.to!string;
        (`if (!(` ~ length_check ~ `)) {`).println;
        indent();
        (`return new R(false, texp.svalue ~ " doesn't have ` ~ child_count.to!string ~ ` children");`).println;
        dedent();
        "}".println;
    }
}