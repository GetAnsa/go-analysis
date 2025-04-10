module Main

import lang::go::ast::AbstractSyntax;
import lang::go::ast::System;
import lang::go::util::Utils;

import IO;

int main(int testArgument=0) {
    println("argument: <testArgument>");

    sampleAst = loadGoFile(|file:///Users/jhight/src/ansa-platform/ansa-server/entrypoints/ansa_server.go|);

    visit(sampleAst) {
      //case callExpr(Expr fun, list[Expr] args, bool hasEllipses): println("Fn: <fun> \n args: <args>");
      case file(str packageName, list[Decl] decls): println(packageName);
    }

    sampleSystem = loadGoFiles(|file:///Users/jhight/src/ansa-platform/ansa-server/entrypoints|);

    for (fileLoc <- sampleSystem.files) {
      println(fileLoc);
      visit(sampleSystem.files[fileLoc]) {
        case file(str packageName, list[Decl] decls): println(packageName);

      }
    }


    return testArgument;
}
