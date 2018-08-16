import std.range;
import std.conv;
import std.algorithm;

/// the node of the tree we're going to use.
class Texp {
	private char[] _value;
	private Texp[] _children;

	/// varargs ctor, string
	this(Texps...)(string value, Texps children) { _value = value.dup; _children = [children]; }
	/// varargs ctor, char[]
	this(Texps...)(char[] value, Texps children) { _value = value;     _children = [children]; }
	/// slice ctor, string
	this(string value, Texp[] children = [])     { _value = value.dup; _children = children; }
	/// slice ctor, char[]
	this(char[] value, Texp[] children = [])     { _value = value;     _children = children; }

	/// normalization
	override string toString() const {
		return toString(0);
	}

	string toString(int level) const {
		char[] acc = "  ".replicate(level) ~ _value ~ "\n";
		foreach (child; _children) {
			acc ~= child.toString(level + 1);
		}
		return acc.to!string;
	}

	/// paren representation
	string paren() const {
		if (_children.length == 0) {
			return _value.to!string;
		} else {
			return ("(" ~ _value ~ " " ~ _children.map!(c => c.paren).join(" ") ~ ")").to!string;
		}
	}

	/// append to children
	void add(Texp c) {
		_children = _children ~ [c];
	}

	// /* const */ const(Texp[]) children() const {
		// return _children.to!(const(Texp[]));
	// }

	// /* const */ const(char[]) value() const {
		// return _value.to!(const(char[]));
	// }

	/// should return const Texp[] children
	Texp[] children() {
		return _children;
	}

	/// should return const char[] _value
	char[] value() {
		return _value;
	}

	/// returns string value
	string svalue() {
		return _value.to!string;
	}
}
