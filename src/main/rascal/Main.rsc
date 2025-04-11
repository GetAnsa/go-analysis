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
  pathToPackageName = ();
  // these parts should probably be parameterized someday
  repoName = "ansa-platform";
  repoPrefix = "github.com/GetAnsa";

  for (fileLoc <- sampleSystem.files, fileLoc.uri != "file:///Users/jhight/src/ansa-platform/ansa-server/restapi/embedded_spec.go") {
//    println(fileLoc);
    fileAst = sampleSystem.files[fileLoc];
    visit(fileAst) {
      case file(str packageName, list[Decl] decls): {
        // paths are always / delimited in rascal
        pathParts = split("/", fileLoc.uri);
        // first part will always be the "file:" part and last part will be filename
        pathParts = pathParts[1..-1];
        pathBuilder = repoPrefix;
        // then handle the rest of the stuff
        foundPackage = false;
        seenRepoName = false;
        for (part <- pathParts[1..]) {
          // we do this first because we do want to include the repo name in the path
          if (part == repoName) {
            seenRepoName = true;
          }
          if (seenRepoName) {
            pathBuilder += "/" + part;
            if (pathBuilder in pathToPackageName && pathToPackageName[pathBuilder] == packageName) {
              foundPackage = true;
            }
          }
        }
        if (!foundPackage) {
          pathToPackageName[pathBuilder] = packageName;
        }
        println(packageName);
      }
//      case callExpr(Expr fun, list[Expr] args, bool hasEllipses): {
//        println(fun);
//      }
//      case ident(str name): {
//        println(name);
//      }
//      case selectorExpr(Expr expr, str selector): {
//        // coolsies, so we can find begin and commit now
//        // guess it's time for the control flow analysis part now    
//        if (selector == "Begin") {
//          println("Found selector <selector> at <fileLoc>");
//        }
//        if (selector == "Commit") {
//          println("Found selector <selector> at <fileLoc>");
//        }
//      }
    }
    extractAndPrintImports(fileAst);
  }
  println(pathToPackageName);

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
//      println("import name: <importName>");
//      println("import path: <importPath>");
//      println("_________________________________");
    }
  }
}