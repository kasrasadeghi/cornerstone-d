import std.conv;
import std.typecons;
import std.stdio;

class eagerR {
    bool _result;
    string _message;
    this(bool result, string message) { 
        this._result = result.nullable;
        this._message = message;
    }

    R opBinary(string op)(R rhs) if (op == "&") {
        if (_result) {
            return this;
        } else {
            rhs._message = _message ~ "\n" ~ rhs._message;
            return rhs;
        }
    }

    override string toString() {
        return "R(" ~ _result.to!string ~ ", \"" ~ _message ~ "\")";
    }
}

class R {
    string _message;
    bool delegate() _result;

    this(bool delegate() result, string message) {
        this._result = result;
        this._message = message;
    }

    R opBinary(string op)(R rhs) if (op == "&") {
        ("computing result for message: ("~ _message ~")").writeln;
        if (_result()) {
            rhs._message = _message ~ "\n" ~ rhs._message;
            return rhs;
        } else {
            return this;
        }
    }

    override string toString() {
        return "R(" ~ _result().to!string ~ ", \"" ~ _message ~ "\")";
    }
}