//
//  UnaryOperatorExpr.swift
//  TestLexer
//
//  Created by poisson florent on 05/06/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

class UnaryOperatorExpr: DebuggableElement, Evaluable {
    
    var unOp: Token
    var operand: Evaluable

    init(unOp: Token, operand: Evaluable) {
        self.unOp = unOp
        self.operand = operand
    }
    
    var description: String {
        return "\(unOp.rawValue)" + operand.description
    }
    
    func evaluate(context: Scope,
                  environment: Environment) throws -> Evaluable? {
        switch unOp {
        case .onesComplement:
            return try evaluateOnesComplement(context: context,
                                              environment: environment)
        case .logicalNegation:
            return try evaluateLogicalNegation(context: context,
                                               environment: environment)
        case .plus:
            return try evaluatePlus(context: context,
                                    environment: environment)
        case .minus:
            return try evaluateMinus(context: context,
                                     environment: environment)
        default:
            return nil
        }
    }
    
    private func evaluateOnesComplement(context: Scope,
                                        environment: Environment) throws -> Evaluable? {
        
        guard let evaluatedVariable = try operand.evaluate(context: context,
                                                           environment: environment) as? Variable else {
            throw ProgramError(errorType: InterpreterError.expressionEvaluationError, lineNumber: lineNumber, postion: position)
        }
        
        guard evaluatedVariable.type == .integer else {
            throw ProgramError(errorType: InterpreterError.expressionEvaluationError, lineNumber: lineNumber, postion: position)
        }
        
        guard let evaluatedValue = evaluatedVariable.value else {
            throw ProgramError(errorType: InterpreterError.undefinedVariable, lineNumber: lineNumber, postion: position)
        }
        
        return Variable(type: .integer, isConstant: true, value: ~(evaluatedValue as! Int))
    }
    
    private func evaluateLogicalNegation(context: Scope,
                                         environment: Environment) throws -> Evaluable? {
        
        guard let evaluatedVariable = try operand.evaluate(context: context,
                                                           environment: environment) as? Variable else {
            throw ProgramError(errorType: InterpreterError.expressionEvaluationError, lineNumber: lineNumber, postion: position)
        }

        guard evaluatedVariable.type == .boolean else {
            throw ProgramError(errorType: InterpreterError.expressionEvaluationError, lineNumber: lineNumber, postion: position)
        }
        
        guard let evaluatedValue = evaluatedVariable.value else {
            throw ProgramError(errorType: InterpreterError.undefinedVariable, lineNumber: lineNumber, postion: position)
        }

        return Variable(type: .boolean, isConstant: true, value: !(evaluatedValue as! Bool))
    }
    
    private func evaluatePlus(context: Scope,
                              environment: Environment) throws -> Evaluable? {
        
        guard let evaluatedVariable = try operand.evaluate(context: context,
                                                           environment: environment) as? Variable else {
            throw ProgramError(errorType: InterpreterError.expressionEvaluationError, lineNumber: lineNumber, postion: position)
        }
        
        // NOTE: First, varibale type is checked,
        //       then, variable value setting is checked.
        
        if evaluatedVariable.type == .integer {
            guard let evaluatedValue = evaluatedVariable.value else {
                throw ProgramError(errorType: InterpreterError.undefinedVariable, lineNumber: lineNumber, postion: position)
            }
            return Variable(type: .integer,
                            isConstant: true,
                            value: (evaluatedValue as! Int))
            
        } else if evaluatedVariable.type == .real {
            guard let evaluatedValue = evaluatedVariable.value else {
                throw ProgramError(errorType: InterpreterError.undefinedVariable, lineNumber: lineNumber, postion: position)
            }
            return Variable(type: .real,
                            isConstant: true,
                            value: (evaluatedValue as! Double))
        } else {
            throw ProgramError(errorType: InterpreterError.expressionEvaluationError, lineNumber: lineNumber, postion: position)
        }
    }
    
    private func evaluateMinus(context: Scope,
                               environment: Environment) throws -> Evaluable? {
        
        guard let evaluatedVariable = try operand.evaluate(context: context,
                                                           environment: environment) as? Variable else {
            throw ProgramError(errorType: InterpreterError.expressionEvaluationError, lineNumber: lineNumber, postion: position)
        }
        
        // NOTE: First, varibale type is checked,
        //       then, variable value setting is checked.
        
        if evaluatedVariable.type == .integer {
            guard let evaluatedValue = evaluatedVariable.value else {
                throw ProgramError(errorType: InterpreterError.undefinedVariable, lineNumber: lineNumber, postion: position)
            }
            return Variable(type: .integer,
                            isConstant: true,
                            value: -(evaluatedValue as! Int))

        } else if evaluatedVariable.type == .real {
            guard let evaluatedValue = evaluatedVariable.value else {
                throw ProgramError(errorType: InterpreterError.undefinedVariable, lineNumber: lineNumber, postion: position)
            }
            return Variable(type: .real,
                            isConstant: true,
                            value: -(evaluatedValue as! Double))
        } else {
            throw ProgramError(errorType: InterpreterError.expressionEvaluationError, lineNumber: lineNumber, postion: position)
        }
    }
    
}
