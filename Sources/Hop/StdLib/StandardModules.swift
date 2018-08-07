//
//  StandardModules.swift
//  TestLexer
//
//  Created by poisson florent on 04/06/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

//
// Standard modules dictionary
//

private let nativesModules: [String: [FunctionClosure]] = [
    "Sys": sysFunctionDeclarations,
    "Math": mathFunctionsDeclarations,
    "Test": testFunctionDeclarations
]

// MARK: - Helpers

typealias FunctionClosure = (_ declarationScope: Scope) -> Closure

enum ImporterError: ErrorType {
    case moduleNotFound

    func getDescription() -> String {
        return "Module Not Found"
    }
}

func getNativeModule(name: String) -> Module? {
    // NOTE: For now, native modules only contain functions
    if let functionDeclarations = nativesModules[name] {
        let scope = Scope(parent: nil)
        functionDeclarations.forEach {
            let closure = $0(scope)
            scope.symbolTable[closure.prototype.hashId] = closure
        }
        return Module(name: name, scope: scope)
    }
    
    return nil
}

func getNativeFunctionClosure(prototype: Prototype,
                              declarationScope: Scope,
                              evaluation: @escaping (_ arguments: [Variable]?, _ session: Session) throws -> Variable?) -> Closure {
    // Function declaration
    // ====================
    
    // Body
    // ----
    
    // Native function call expression
    var arguments: [NativeFunctionCallExpr.Argument]?
    if let prototypeArguments = prototype.arguments {
        arguments = [NativeFunctionCallExpr.Argument]()
        for prototypeArgument in prototypeArguments {
            arguments?.append(NativeFunctionCallExpr.Argument(name: nil, valueHashId: prototypeArgument.hashId))
        }
    }
    
    let type = prototype.type
    let nativeFunctionCall = NativeFunctionCallExpr(arguments: arguments, evaluation: evaluation) {
        () -> Type in
        return type
    }

    // Embedding return statement
    let statement = ReturnStmt(result: nativeFunctionCall)
    
    // Body block
    let block = BlockStmt(statements: [statement])
    
    // Function declaration closure
    return Closure(prototype: prototype,
                   block: block,
                   declarationScope: declarationScope)
}
