import std.conv;
import std.typecons;
import std.stdio;

import strutil : indentLines;

class R {
    bool _result;
    string _message;
    this(bool result, string message) { 
        this._result = result.nullable;
        this._message = message;
    }

    R opBinary(string op)(R rhs) if (op == "&" || op == ">>") {
        if (_result) {
            string rhs_message = (op == ">>") ? rhs._message.indentLines
                                              : rhs._message;
            
            return new R(rhs._result, _message ~ "\n" ~ rhs_message);
        } else {
            return this;
        }
    }

    override string toString() {
        return "R(" ~ _result.to!string ~ ", \"" ~ _message ~ "\")";
    }
}

