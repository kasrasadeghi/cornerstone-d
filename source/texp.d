import std.range;
import std.conv;

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

	/// append to children
	void add(Texp c) {
		_children = _children ~ [c];
	}
}
