//
//  SysModule.swift
//  Hop iOS
//
//  Created by poisson florent on 07/08/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

// Sys module functions
let sysFunctionDeclarations: [FunctionClosure] = [
    getPrintDeclaration,
    getStringDeclaration
]

// MARK: - System functions

/// Native binding for print(String)
private func getPrintDeclaration(declarationScope: Scope) -> Closure {
    // Prototype
    let argument = Argument(name: "text", type: .string, isAnonymous: true)
    let prototype = Prototype(name: "print", arguments: [argument], type: .void)
    
    return getNativeFunctionClosure(prototype: prototype, declarationScope: declarationScope) {
        (expressions, environment) in
        
        guard let string = expressions?.first?.value as? String else {
            throw ProgramError(errorType: InterpreterError.nativeFunctionCallParameterError, debugInfo: nil)
        }
        
        let message = "[\(Date().timeIntervalSinceReferenceDate)] -- \(string)"
        
        print(message)
        
        environment.messenger?.post(message: Message(type: .stdout,
                                                     identifier: nil,
                                                     data: message))
        return nil
    }
}

// MARK: - Type conversion

private func getStringDeclaration(declarationScope: Scope) -> Closure {
    // Prototype
    let argument = Argument(name: "value", type: .any, isAnonymous: true)
    let prototype = Prototype(name: "string", arguments: [argument], type: .string)
    
    return getNativeFunctionClosure(prototype: prototype, declarationScope: declarationScope) {
        (expressions, _) in
        
        guard let variable = expressions?.first else {
            throw ProgramError(errorType: InterpreterError.nativeFunctionCallParameterError, debugInfo: nil)
        }
        
        if let integer = variable.value as? Int {
            return Variable(type: .string, isConstant: true, value: String(integer))
            
        } else if let real = variable.value as? Double {
            return Variable(type: .string, isConstant: true, value: String(real))
            
        } else if let boolean = variable.value as? Bool {
            return Variable(type: .string, isConstant: true, value: String(boolean))
            
        } else if let string = variable.value as? String {
            return Variable(type: .string, isConstant: true, value: string)
        }
        
        return Variable(type: .string, isConstant: true, value: "")    // TODO: throwing error instead of default empty value
    }
}
