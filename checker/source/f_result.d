import std.conv;
import std.typecons;
import std.stdio;


class fR {
    string _message;
    bool delegate() _result;

    this(bool delegate() result, string message) {
        this._result = result;
        this._message = message;
    }

    fR opBinary(string op)(R rhs) if (op == "&") {
        if (_result()) {
            rhs._message = _message ~ "\n" ~ rhs._message;
            return rhs;
        } else {
            return this;
        }
    }

    fR opBinary(string op)(lazyR lazy_rhs) if (op == "&") {
        if (_result()) {
            fR rhs = lazy_rhs.make();
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

class lazyR {
    Nullable!fR _result;
    fR delegate() _result_f;
    this(fR delegate() result_f) {
        this._result_f = result_f;
    }

    fR make() {
        if (_result.isNull) {
            _result = _result_f();
        }
        return _result;
    }
}
    