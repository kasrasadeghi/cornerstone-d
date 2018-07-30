import std.algorithm;
import texp;
import std.stdio;
import std.conv;
import std.range;
import std.ascii;

void generateIdentity(Texp grammar) {
    auto gmap = grammar.makeDict;
    gmap.generateTraversal("Program");
}

void printGrammar(Texp grammar) {
    auto maxValueLength = grammar.children.map!(k => k.value.length).maxElement;

    foreach (Texp c; grammar.children()) {
        auto k = c.svalue;
        auto v = c.children[0];
        gmap[k] = v;
        auto rulerep = v.paren[0] == '(' ? v.paren[1 .. $ - 1] : v.paren;
        // writefln("%"~(maxValueLength + 1).to!string~"s ::= %s", k, rulerep);
    }
}

Texp[string] makeDict(Texp grammar) {
    Texp[string] gmap;
    foreach (Texp c; grammar.children()) {
        auto k = c.svalue;
        auto v = c.children[0];
        gmap[k] = v;
    }

    // grammar.children.each!(c => gmap[c.svalue] = c.children[0]);
    // gmap.each((k, v) => (k ~ v.paren).writeln);
    // auto maxKeyLength = gmap.keys.map!(k => k.length).maxElement;
    // foreach (k, v; gmap) {
    //     writefln("%"~(maxKeyLength + 1).to!string~"s ::= %s", k, v.paren[0] == '(' ? v.paren[1 .. $ - 1] : v.paren );
    // }q
    return gmap;
}

bool[string] history;
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
    switch (rule.value) {
    case "*":
        "many of ".print;
        rule.children.map!(c => c.paren).println;
        foreach (c; rule.children) {
            acc ~= c.svalue;
        }
        // rule.children.each!(c => generateTraversal(grammar, c.value));
        break;
        
    case "|":
        "a choice of ".print;
        rule.children.map!(c => c.paren).println;
        foreach (c; rule.children) {
            acc ~= c.svalue;
        }
        break;
    
    default:
        "// texp matches ".print;

        foreach (c; rule.children) {
            if (c.value[0].isUpper) {
                acc ~= c.svalue;
            }
            if (c.svalue == "*") {
                ("texp.children["~num.to!string~" .. $]").println;
                num.to!string.println;
                foreach (cc; c.children) {
                    if (cc.value[0].isUpper) {
                       acc ~= cc.svalue;
                    }
                }
            } else {
                (c.paren ~ "(texp.children[" ~ num.to!string ~ "])").println;
            }
        }
        // rule.children.map!(c => c.paren).writeln;
        break;
    }    
}

int indent = 0;
string acc;

void print(T)(T arg) {
    // only when we have not just printed a newline do we indent
    if (acc.length == 0 || acc[$ - 1] == '\n') {
        acc ~= "  ".replicate(indent);
        "  ".replicate(indent).write;
    }
    acc ~= arg.to!string;
    arg.to!string.write;
}

void println(T)(T arg) {
    (arg.to!string ~ "\n").print;
}