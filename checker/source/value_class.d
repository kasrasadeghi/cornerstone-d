import std.string : isNumeric;
import std.algorithm;
import result;

R matchValueClass(string a, string b) {
    if (b == "int") {
        //TODO: not just numeric, only integers.
        return new R(a.isNumeric, a ~ " is numeric");
    }
    if (b == "name") {
        return new R(true, a ~ " in #name");
    }
    if (b == "bool") {
        return new R(a == "true" || a == "false", "is " ~ a ~ " in {\"true\", \"false\"}");
    }
    if (b == "type") {
        return new R(["i32", "i8*"].canFind(a), a ~ " in #type");
    }
    if (b == "string") {
        return new R(a[0] == '\"' && a[$-1] == '\"', a ~ " starts and ends with quotes");
    }
    return new R(true, "TODO: does " ~ a ~ " match class #" ~ b);
}