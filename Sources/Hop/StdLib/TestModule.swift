//
//  TestModule.swift
//  Hop iOS
//
//  Created by poisson florent on 07/08/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

// Test module functions
let testFunctionDeclarations: [FunctionClosure] = [
    getExportVariableDeclaration
]

// MARK: - Test functions

/// Native binding for func export(#variable: Any, label: String)
private func getExportVariableDeclaration(declarationScope: Scope) -> Closure {
    // Prototype
    let variableArgument = Argument(name: "variable", type: .any, isAnonymous: true)
    let labelArgument = Argument(name: "label", type: .string, isAnonymous: false)
    let prototype = Prototype(name: "export",
                              arguments: [
                                variableArgument,
                                labelArgument],
                              type: .void)
    
    return getNativeFunctionClosure(prototype: prototype, declarationScope: declarationScope) {
        (arguments, session) in

        // Variable argument
        guard let argumentValue = arguments?[0].value else {
                throw ProgramError(errorType: InterpreterError.nativeFunctionCallParameterError,
                                   debugInfo: nil)
        }
        
        // Label argument
        guard let labelValue = arguments?[1].value as? String else {
            throw ProgramError(errorType: InterpreterError.nativeFunctionCallParameterError,
                               debugInfo: nil)
        }
        
        session.messenger?.post(message: Message(type: .export,
                                                 identifier: labelValue,
                                                 data: argumentValue))
        return nil
    }

}
