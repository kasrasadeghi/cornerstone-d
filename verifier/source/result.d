import std.conv;

class R {
    bool _result;
    string _message;
    this(bool result, string message) { 
        this._result = result;
        this._message = message;
    }

    this(bool result) { 
        this._result = result;
        this._message = "";
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
