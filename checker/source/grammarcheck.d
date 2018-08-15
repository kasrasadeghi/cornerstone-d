
import std.algorithm;
import std.stdio;

import texp;
import result;
import indentio;
import parse;

R matchValueClass(string a, string b) { return new R(() => true, "trivial success"); }

R isStmt(Texp texp) {
  ("searching Stmt with " ~ texp.paren).println;
  if (texp.isReturn._result) {
    return new R(() => true, "in Stmt matched Return");
  }
  if (texp.isCallLike._result) {
    return new R(() => true, "in Stmt matched CallLike");
  }
  if (texp.isDo._result) {
    return new R(() => true, "in Stmt matched Do");
  }
  return new R(() => false, texp.svalue ~ "matched no Stmt");
}
R isDo(Texp texp) {
  texp.paren.println;
  "(do (* Stmt))".println;
  return new R(() => texp.svalue == "do", "does " ~ texp.svalue ~ " match do?")
       & texp.children[0 .. $].map!(c => c.isStmt).fold!((a, b) => a & b);
}
R isExpr(Texp texp) {
  ("searching Expr with " ~ texp.paren).println;
  if (texp.isCallLike._result) {
    return new R(() => true, "in Expr matched CallLike");
  }
  if (texp.isValue._result) {
    return new R(() => true, "in Expr matched Value");
  }
  return new R(() => false, texp.svalue ~ "matched no Expr");
}
R isDef(Texp texp) {
  texp.paren.println;
  "(def #name ParamList #type Do)".println;
  return new R(() => texp.svalue == "def", "does " ~ texp.svalue ~ " match def?")
       & new R(() => texp.children.length == 4, " ")
       & texp.children[0].svalue.matchValueClass("name")
       & texp.children[1].isParamList
       & texp.children[2].svalue.matchValueClass("type")
       & texp.children[3].isDo;
}
R isTypeList(Texp texp) {
  texp.paren.println;
  "(types (* #type))".println;
  return new R(() => texp.svalue == "types", "does " ~ texp.svalue ~ " match types?")
       & texp.children[0 .. $].map!(c => c.svalue.matchValueClass("type")).fold!((a, b) => a & b);
}
R isReturn(Texp texp) {
  ("searching Return with " ~ texp.paren).println;
  if (texp.isReturnValue._result) {
    return new R(() => true, "in Return matched ReturnValue");
  }
  return new R(() => false, texp.svalue ~ "matched no Return");
}
R isCall(Texp texp) {
  texp.paren.println;
  "(call #name TypeList #type ArgList)".println;
  return new R(() => texp.svalue == "call", "does " ~ texp.svalue ~ " match call?")
       & new R(() => texp.children.length == 4, " ")
       & texp.children[0].svalue.matchValueClass("name")
       & texp.children[1].isTypeList
       & texp.children[2].svalue.matchValueClass("type")
       & texp.children[3].isArgList;
}
R isStrTableEntry(Texp texp) {
  texp.paren.println;
  "(#int #string)".println;
  return texp.svalue.matchValueClass("int")
       & new R(() => texp.children.length == 1, " ")
       & texp.children[0].svalue.matchValueClass("string");
}
R isDecl(Texp texp) {
  texp.paren.println;
  "(decl #name TypeList #type)".println;
  return new R(() => texp.svalue == "decl", "does " ~ texp.svalue ~ " match decl?")
       & new R(() => texp.children.length == 3, " ")
       & texp.children[0].svalue.matchValueClass("name")
       & texp.children[1].isTypeList
       & texp.children[2].svalue.matchValueClass("type");
}
R isParamList(Texp texp) {
  texp.paren.println;
  "(params (* Param))".println;
  return new R(() => texp.svalue == "params", "does " ~ texp.svalue ~ " match params?")
       & texp.children[0 .. $].map!(c => c.isParam).fold!((a, b) => a & b);
}
R isParam(Texp texp) {
  texp.paren.println;
  "(#name #type)".println;
  return texp.svalue.matchValueClass("name")
       & new R(() => texp.children.length == 1, " ")
       & texp.children[0].svalue.matchValueClass("type");
}
R isArgList(Texp texp) {
  texp.paren.println;
  "(args (* Expr))".println;
  return new R(() => texp.svalue == "args", "does " ~ texp.svalue ~ " match args?")
       & texp.children[0 .. $].map!(c => c.isExpr).fold!((a, b) => a & b);
}
R isValue(Texp texp) {
  ("searching Value with " ~ texp.paren).println;
  if (texp.isLiteral._result) {
    return new R(() => true, "in Value matched Literal");
  }
  if (texp.isStrGet._result) {
    return new R(() => true, "in Value matched StrGet");
  }
  if (texp.svalue.matchValueClass("name")._result) {
    return new R(() => true, "in Value matched #name");
  }
  return new R(() => false, texp.svalue ~ "matched no Value");
}
R isReturnValue(Texp texp) {
  texp.paren.println;
  "(return-value Expr #type)".println;
  return new R(() => texp.svalue == "return-value", "does " ~ texp.svalue ~ " match return-value?")
       & new R(() => texp.children.length == 2, " ")
       & texp.children[0].isExpr
       & texp.children[1].svalue.matchValueClass("type");
}
R isCallLike(Texp texp) {
  ("searching CallLike with " ~ texp.paren).println;
  if (texp.isCall._result) {
    return new R(() => true, "in CallLike matched Call");
  }
  return new R(() => false, texp.svalue ~ "matched no CallLike");
}
R isTopLevel(Texp texp) {
  ("searching TopLevel with " ~ texp.paren).println;
  if (texp.isStrTable._result) {
    return new R(() => true, "in TopLevel matched StrTable");
  }
  if (texp.isDef._result) {
    return new R(() => true, "in TopLevel matched Def");
  }
  if (texp.isDecl._result) {
    return new R(() => true, "in TopLevel matched Decl");
  }
  return new R(() => false, texp.svalue ~ "matched no TopLevel");
}
R isStrTable(Texp texp) {
  texp.paren.println;
  "(str-table (* StrTableEntry))".println;
  return new R(() => texp.svalue == "str-table", "does " ~ texp.svalue ~ " match str-table?")
       & texp.children[0 .. $].map!(c => c.isStrTableEntry).fold!((a, b) => a & b);
}
R isStrGet(Texp texp) {
  texp.paren.println;
  "(str-get #int)".println;
  return new R(() => texp.svalue == "str-get", "does " ~ texp.svalue ~ " match str-get?")
       & new R(() => texp.children.length == 1, " ")
       & texp.children[0].svalue.matchValueClass("int");
}
R isLiteral(Texp texp) {
  texp.paren.println;
  "(#int #bool)".println;
  return texp.svalue.matchValueClass("int")
       & new R(() => texp.children.length == 1, " ")
       & t exp.children[0].svalue.matchValueClass("bool");
}
R isProgram(Texp texp) {
  texp.paren.println;
  "(#name (* TopLevel))".println;
  return texp.svalue.matchValueClass("name")
       & texp.children[0 .. $].map!(c => c.isTopLevel).fold!((a, b) => a & b);
}

void test(string filename) {
  import parse : parse;
  import std.conv;
  import std.stdio;

  parseFile(filename).isProgram.writeln;
  //"(decl puts (type i8*) i32)".dup.parse()[0].isStrTable.to!string.writeln;
}
   
