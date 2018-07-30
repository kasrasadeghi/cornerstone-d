import std.algorithm;
import texp;
import std.stdio;
import std.conv;
import std.range;
import std.ascii;

/// generates the identity traversal
void generateIdentity(Texp grammar) {
    // grammar.printGrammar;
    auto gmap = grammar.makeDict;
    gmap.generateTraversal("Program");
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

/// keeps track of the history of traversed productions
bool[string] history;

/// creates a traversal from a history of productions
void generateTraversal(Texp[string] grammar, string current) {

    if (current in history) {
        return;
    } 
    history[current] = true;

    string[] acc;
    scope(exit) {
        foreach (prod; acc) {
            generateTraversal(grammar, prod);
        }
    }
    Texp rule = grammar[current];
    (current ~"(texp) {").println;
    indent++;
    scope(exit) {indent--;"}".println;}
    if (rule.value == "|") {
        "// a choice of ".print;
        rule.children.map!(c => c.svalue).println;
        if (rule.children.all!(c => grammar[c.svalue].svalue != "|")) {
            "switch (texp.value) {".println;
            foreach (c; rule.children) {
                ("case \"" ~ grammar[c.svalue].svalue ~ "\":").println; indent++;
                (c.svalue ~ "(texp);").println;
                "break;".println;
                indent--;
            }
            "}".println;
        }
        foreach (c; rule.children) {
            acc ~= c.svalue;
        }
    } else {
        (rule.svalue ~ "(texp.svalue);").println;

        foreach (num, c; rule.children.enumerate) {
            if (c.value[0].isUpper) {                
                acc ~= c.svalue;
            }
            if (c.svalue == "*") {
                ("texp.children["~num.to!string~" .. $]").println;
                foreach (cc; c.children) {
                    if (cc.value[0].isUpper) {
                       acc ~= cc.svalue;
                    }
                }
            } else {
                (c.paren ~ "(texp.children[" ~ num.to!string ~ "]);").println;
            }
        }
        // rule.children.map!(c => c.paren).writeln;
    }    
}

/// keeps track of indents for print and println
int indent = 0;

/// accumulate print results for backtracking
string acc;

/// super write
void print(T)(T arg) {
    // only when we have not just printed a newline do we indent
    if (acc.length == 0 || acc[$ - 1] == '\n') {
        acc ~= "  ".replicate(indent);
        "  ".replicate(indent).write;
    }
    acc ~= arg.to!string;
    arg.to!string.write;
}

/// super writeln
void println(T)(T arg) {
    (arg.to!string ~ "\n").print;
}