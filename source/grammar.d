import std.stdio;
import std.range;
import std.ascii;
import std.algorithm;
import std.conv;

import texp;

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
