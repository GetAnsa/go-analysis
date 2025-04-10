module Main

import lang::go::ast::AbstractSyntax;
import lang::go::ast::System;
import lang::go::util::Utils;

import IO;
import String;

int main(int testArgument=0) {
    println("argument: <testArgument>");

    sampleAst = loadGoFile(|file:///Users/jhight/src/ansa-platform/ansa-server/entrypoints/ansa_server.go|);

    visit(sampleAst) {
      //case callExpr(Expr fun, list[Expr] args, bool hasEllipses): println("Fn: <fun> \n args: <args>");
      case file(str packageName, list[Decl] decls): println(packageName);
    }

    sampleSystem = loadGoFiles(|file:///Users/jhight/src/ansa-platform/ansa-server|);

    for (fileLoc <- sampleSystem.files) {
      println(fileLoc);
      fileAst = sampleSystem.files[fileLoc];
      visit(fileAst) {
        case file(str packageName, list[Decl] decls): {
          println(packageName);
        }
      }
      extractAndPrintImports(fileAst);
    }


    return testArgument;
}

public void extractAndPrintImports(goAst) {
    top-down visit(goAst) {
    case importSpec(givenImportName, literalString(importPath)): {
      str importName = "";
      str path = "";
      switch(givenImportName) {
          case someName(str id): {
            importName = id;
          }
          case noName(): {
            if (contains(importPath, "/")) {
              parts = split("/", importPath);
              importName = parts[-1];
              path = importPath;
            } else {
              importName = importPath;
            }
          }
      }
      println("import name: <importName>");
      println("import path: <importPath>");
      println("_________________________________");
    }

  }

}



