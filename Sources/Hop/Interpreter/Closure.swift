//
//  Closure
//  TestLexer
//
//  Created by poisson florent on 23/06/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

class Closure: DebuggableElement, Evaluable {

    let prototype: Prototype
    let block: BlockStmt?
    weak var declarationScope: Scope!
    
    init(prototype: Prototype,
         block: BlockStmt?,
         declarationScope: Scope) {
        self.prototype = prototype
        self.block = block
        self.declarationScope = declarationScope
    }
    
    // NOTE: unused !!!!!!!
    var description: String {
        return ""
    }

    // NOTE: unused !!!!!!!
    func evaluate(context: Scope,
                  environment: Environment) throws -> Evaluable? {
        return self
    }
    
    func evaluate(arguments: [FunctionCallArgument]?,
                  context: Scope,
                  environment: Environment) throws -> Evaluable? {
        // Create parameters scope
        let parametersContext = Scope(parent: declarationScope)
        if let prototypeArguments = prototype.arguments,
            let arguments = arguments {
            for (index, prototypeArgument) in prototypeArguments.enumerated() {
                
                var variable: Variable! = try arguments[index].expr.evaluate(context: context,
                                                                             environment: environment) as? Variable
                guard variable != nil else {
                    throw ProgramError(errorType: InterpreterError.expressionEvaluationError, lineNumber: lineNumber, postion: position)
                }
                
                // Check if types match
                if prototypeArgument.type != .any {     // `Any` welcome any type
                    if prototypeArgument.type != variable.type {
                        if let instance = variable.value as? Instance {
                            if !instance.isInstance(of: prototypeArgument.type) {
                                throw ProgramError(errorType: InterpreterError.expressionTypeMismatch, lineNumber: lineNumber, postion: position)
                            }
                        } else if variable.type == .nil {
                            variable = Variable(type: prototypeArgument.type,
                                                isConstant: true,
                                                value: nil)
                        } else {
                            throw ProgramError(errorType: InterpreterError.expressionTypeMismatch, lineNumber: lineNumber, postion: position)
                        }
                    }
                }
                
                parametersContext.symbolTable[prototypeArgument.hashId] = variable
            }
        }

        _ = try block?.evaluate(context: parametersContext,
                                environment: environment)
        
        // Get returned expression if needed
        var returnedEvaluable: Evaluable?
        
        if prototype.type == .void {
            if returnedEvaluable != nil {
                throw ProgramError(errorType: InterpreterError.shouldReturnNothing, lineNumber: lineNumber, postion: position)
            }
        } else {
            returnedEvaluable = parametersContext.returnedEvaluable
            if returnedEvaluable == nil {
                throw ProgramError(errorType: InterpreterError.missingReturnedExpression, lineNumber: lineNumber, postion: position)
            }
            guard let returnedVariable = returnedEvaluable as? Variable else {
                throw ProgramError(errorType: InterpreterError.expressionEvaluationError, lineNumber: lineNumber, postion: position)
            }

            // Check if types match
            if prototype.type != .any {     // `Any` welcome any type
                if prototype.type != returnedVariable.type {
                    if let instance = returnedVariable.value as? Instance {
                        if !instance.isInstance(of: prototype.type) {
                            throw ProgramError(errorType: InterpreterError.wrongFunctionCallReturnedType, lineNumber: lineNumber, postion: position)
                        }
                    } else if returnedVariable.type == .nil {
                        returnedEvaluable = Variable(type: prototype.type,
                                                     isConstant: true,
                                                     value: nil)
                    } else {
                        throw ProgramError(errorType: InterpreterError.wrongFunctionCallReturnedType, lineNumber: lineNumber, postion: position)
                    }
                }
            }
        }
        
        return returnedEvaluable ?? Variable(type: .void, isConstant: true, value: nil)
    }
    
    static func getFunctionSignatureHashId(name: String,
                                           argumentNames: [String]?) -> Int {
        var signature = name
        signature += "("
        if let argumentNames = argumentNames {
            for argumentName in argumentNames {
                signature += argumentName + ":"
            }
        }
        signature += ")"
        return signature.hashValue
    }

    
}
