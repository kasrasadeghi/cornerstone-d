import std.algorithm;
import std.stdio;
import std.conv;
import std.range;
import std.ascii;

import texp;
import indentio : indent, dedent, print, println;
import grammar  : makeDict;

/// generates the identity traversal
void generateIdentity(Texp grammar) {
    // grammar.printGrammar;
    auto gmap = grammar.makeDict;
    // auto prods = gmap.foldTraversal("Program");
    gmap.keys.each!(prod => gmap.generateTraversal(prod));
}

/// creates a traversal from a production in a grammar
void generateTraversal(Texp[string] grammar, string current) {
    (current ~"(texp) {").println; indent();
    scope(exit) {dedent();"}".println;}

    Texp rule = grammar[current];
    if (rule.value == "|") {
        if (rule.children.all!(c => grammar[c.svalue].svalue != "|")) {
            "switch (texp.value) {".println;
            foreach (c; rule.children) {
                ("case \"" ~ grammar[c.svalue].svalue ~ "\":").println; indent();
                (c.svalue ~ "(texp);").println;
                "break;".println;
                dedent();
            }
            "}".println;
        } else {
            foreach (num, c; rule.children.enumerate) {
                if (num != 0) {
                    "else ".print;
                }
                ("if (is"~c.svalue~"(texp)) {").println; indent();
                (c.svalue ~ "(texp);").println;
                
                dedent();
                "}".println;
            }
        }
    } else {
        if (rule.value[0] == '#') {
            ("// texp.svalue matches " ~ rule.svalue).println;
        } else {
            ("assert \"" ~ rule.svalue ~ "\" == texp.svalue;").println;
        }

        foreach (num, c; rule.children.enumerate) {
            if (c.svalue == "*") {
                ("texp.children["~num.to!string~" .. $]." ~ c.children[0].svalue ~ ";").println;
            } else {
                (c.paren ~ "(texp.children[" ~ num.to!string ~ "]);").println;
            }
        }
    } 
}
