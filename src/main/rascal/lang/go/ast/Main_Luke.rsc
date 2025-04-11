module lang::go::ast::Main_Luke

import lang::go::ast::AbstractSyntax;
import lang::go::ast::System;
import lang::go::util::Utils;
import List;
import IO;
import String;

// void getFilesRecursively(str inputFilePathStr) {
//     println("starting recursion at <inputFilePathStr>");

//     loc inputFilePath = |file:///| + inputFilePathStr;
//     println(inputFilePath);
//     sampleAst = loadGoFiles(inputFilePath);

//     visit(sampleAst) {
//       //case callExpr(Expr fun, list[Expr] args, bool hasEllipses): println("Fn: <fun> \n args: <args>");
//       case file(str packageName, list[Decl] decls): println(packageName);
//     }

//     listOfImportPaths = extractAndPrintImports(sampleAst);
//     for (importPath <- listOfImportPaths) {
//       if (!contains(importPath, "/")) {
//         continue;
//       }
//       try {
//         getFilesRecursively(importPath);
//       } catch value _: {
//         println("No such path");
//       }
      
//     }

// }

void mapFnToModule(str inputFilePathStr) {
    set[str] builtInFunctions = {"append", "len", "cap", "make", "new", "delete", "copy", "close", "complex", "real", "imag", "panic", "recover"};
    println("starting analysis at <inputFilePathStr>");

    loc inputFilePath = |file:///| + inputFilePathStr;

    fileAST = loadGoFile(inputFilePath);

    fileModules = extractAndPrintImports(fileAST);

    // A bridge type is any intermediary var that still originates from a module
    // This block of code:
    // ```
    // import merchants
    // merchantService := merchants.NewMerchantDBService(tx)
    // merchant, err := merchantService.GetMerchantById(ctx, segment.MerchantId)
    // ```
    // Would be represented as 
    // {"merchantService": "merchants"}
    // which, when we encounter the last line, would map the merchantService selector 
    // to the merchants module
    map[str, str] bridgeTypes = ();

    visit(fileAST) {
      case assignStmt(list[Expr] targets, list[Expr] values, AssignOp assignOp): {
        aValue = values[0];
        visit(aValue) {
          case callExpr(selectorExpr(ident(str id), str meth), _, _): {
              println(meth);
              // List of Go built-in functions                
              if (meth in builtInFunctions) {
                println("functionName <meth>");
              } else {
                if (indexOf(fileModules, id) != -1) {
                  for (target <- targets) {
                    if (ident(str name, at=loc _) := target) {
                      bridgeTypes[name] = id;
                      bridgeTypes[meth] = id;
                    }
                  }
                } else {
                  if (id in bridgeTypes) {
                    for (target <- targets) {
                      if (ident(str name, at=loc _) := target) {
                        bridgeTypes[name] = bridgeTypes[id];
                        bridgeTypes[meth] = bridgeTypes[id];
                      }
                    }
                  }
                }
            }
          }
        }
      }  
    }
    println(bridgeTypes);

    // listOfImportPaths = extractAndPrintImports(fileAST);
    // for (importPath <- listOfImportPaths) {
    //   if (!contains(importPath, "/")) {
    //     continue;
    //   }
    //   try {
    //     getFilesRecursively(importPath);
    //   } catch value _: {
    //     println("No such path");
    //   }
      
    // }

}

public list[str] extractAndPrintImports(goAst) {
    rootDir = "Users/lukeyeom/code";
    list[str] output = [];
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
              importPath = replaceFirst(importPath, "github.com/GetAnsa", rootDir);
              parts = split("/", importPath);
              importName = parts[-1];
              path = importPath;
            } else {
              importName = importPath;
            }
          }
      }
      // println("import name: <importName>");
      // println("import path: <importPath>");
      // println("_________________________________");
      output += [importName];
    }
  }
  return output;
}



