import std.string;
import std.file;
import std.path;
import std.uni;
import std.algorithm.searching;

import texp;

/// string -> Texp
/// collects the texps in the file to a single texp with the basename of the filename
Texp parseFile(string filename) {
	return new Texp(filename.baseName.dup, filename.readText.dup.parse);
}

/// char[] -> Texp[]
Texp[] parse(char[] content) {
	Texp[] acc;
	while (!content.empty) {
		content.pWhitespace;
		acc ~= pSexp(content);
		content.pWhitespace;
	}
	return acc;
}

/// ref char[] -> Texp
Texp pSexp(ref char[] content) {
	content.pWhitespace;
	if (content[0] == '(') return pList(content);
	return pAtom(content);
}

/// ref char[] -> Texp
Texp pAtom(ref char[] content) {
	if (content[0] == '\"') {
		auto res = content[1 .. $].findSplitAfter("\"");
		auto before = "\""~res[0];
		content = res[1];
		return new Texp(before);
	} else if (content[0] == '\'') {
		auto res = content[1 .. $].findSplitAfter("\'");
		auto before = "\'"~res[0];
		content = res[1];
		return new Texp(before);
	}
	return new Texp(content.pWord);
}

/// ref char[] -> Texp
Texp pList(ref char[] content) {
	content = content[1 .. $]; // pop (
	auto curr = new Texp(content.pWord);
	while (content[0] != ')') {
		curr.add(content.pSexp);
		content.pWhitespace;
	}
	
	content = content[1 .. $]; // pop )
	return curr;
}

/// ref char[] -> char[]
char[] pWord(ref char[] content) {
	content.pWhitespace;
	char[] acc;
	while (!content.empty && content[0] != '(' && content[0] != ')' && !content[0].isWhite) {
		acc = acc ~ [content[0]];
		content = content[1 .. $];
	}
	return acc;
}

/// ref char[] -> ()
void pWhitespace(ref char[] content) {
	while (!content.empty && content[0].isWhite) {
		content = content[1 .. $];
	}
}