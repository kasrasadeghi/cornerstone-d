import std.algorithm;
import std.stdio;
import std.conv;
import std.range;
import std.ascii;

import texp;
import indentio : indent, dedent, print, println;

/// generates the identity traversal
void generateIdentity(Texp grammar) {
    // grammar.printGrammar;
    auto gmap = grammar.makeDict;
    // auto prods = gmap.foldTraversal("Program");
    gmap.keys.each!(prod => gmap.generateTraversal(prod));
}

/// prints productions from a Texp
void printGrammar(Texp grammar) {
    auto maxValueLength = grammar.children.map!(k => k.value.length).maxElement;

    foreach (Texp c; grammar.children()) {
        const k = c.svalue;
        const v = c.children[0];
        const rulerep = v.paren[0] == '(' ? v.paren[1 .. $ - 1] : v.paren;
        writefln("%"~(maxValueLength + 1).to!string~"s ::= %s", k, rulerep);
    }
}

/// makes a dictionary from a grammar texp
Texp[string] makeDict(Texp grammar) {
    Texp[string] gmap;
    foreach (Texp c; grammar.children()) {
        gmap[c.svalue] = c.children[0];
    }
    return gmap;
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
        (rule.svalue ~ "(texp.svalue);").println;

        foreach (num, c; rule.children.enumerate) {
            if (c.svalue == "*") {
                ("texp.children["~num.to!string~" .. $]." ~ c.children[0].svalue ~ ";").println;
            } else {
                (c.paren ~ "(texp.children[" ~ num.to!string ~ "]);").println;
            }
        }
    } 
}

/// keeps track of the history of traversed productions
bool[string] history;

/// traverses grammar from current and adds everything that current depends on
string[] foldTraversal(Texp[string] grammar, string current) {
    if (current in history) {
        return [];
    } 
    history[current] = true;
    string[] acc;

    Texp rule = grammar[current];
    if (rule.value == "|") {
        foreach (c; rule.children) {
            acc ~= c.svalue;
        }
    } else {
        foreach (num, c; rule.children.enumerate) {
            if (c.value[0].isUpper) {                
                acc ~= c.svalue;
            }
            if (c.svalue == "*") {
                auto child = c.children[0];
                if (child.value[0].isUpper) {
                    acc ~= child.svalue;
                }
            }
        }
    }
    
    acc.each!(k => acc ~= grammar.foldTraversal(k));

    return acc;
}
