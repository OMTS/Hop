//
//  UnaryOperatorExpr.swift
//  TestLexer
//
//  Created by poisson florent on 05/06/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

struct UnaryOperatorExpr: Evaluable {
    var debugInfo: DebugInfo?

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
                  session: Session) throws -> Evaluable? {
        switch unOp {
        case .onesComplement:
            return try evaluateOnesComplement(context: context,
                                              session: session)
        case .logicalNegation:
            return try evaluateLogicalNegation(context: context,
                                               session: session)
        case .plus:
            return try evaluatePlus(context: context,
                                    session: session)
        case .minus:
            return try evaluateMinus(context: context,
                                     session: session)
        default:
            return nil
        }
    }

    private func evaluateOnesComplement(context: Scope,
                                        session: Session) throws -> Evaluable? {

        guard let evaluatedVariable = try operand.evaluate(context: context,
                                                           session: session) as? Variable else {
            throw ProgramError(errorType: InterpreterError.expressionEvaluationError, debugInfo: debugInfo)
        }

        guard evaluatedVariable.type == .integer else {
            throw ProgramError(errorType: InterpreterError.expressionEvaluationError, debugInfo: debugInfo)
        }

        guard let evaluatedValue = evaluatedVariable.value else {
            throw ProgramError(errorType: InterpreterError.undefinedVariable, debugInfo: debugInfo)
        }

        return Variable(type: .integer, isConstant: true, value: ~(evaluatedValue as! Int))
    }

    private func evaluateLogicalNegation(context: Scope,
                                         session: Session) throws -> Evaluable? {

        guard let evaluatedVariable = try operand.evaluate(context: context,
                                                           session: session) as? Variable else {
            throw ProgramError(errorType: InterpreterError.expressionEvaluationError, debugInfo: debugInfo)
        }

        guard evaluatedVariable.type == .boolean else {
            throw ProgramError(errorType: InterpreterError.expressionEvaluationError, debugInfo: debugInfo)
        }

        guard let evaluatedValue = evaluatedVariable.value else {
            throw ProgramError(errorType: InterpreterError.undefinedVariable, debugInfo: debugInfo)
        }

        return Variable(type: .boolean, isConstant: true, value: !(evaluatedValue as! Bool))
    }

    private func evaluatePlus(context: Scope,
                              session: Session) throws -> Evaluable? {

        guard let evaluatedVariable = try operand.evaluate(context: context,
                                                           session: session) as? Variable else {
            throw ProgramError(errorType: InterpreterError.expressionEvaluationError, debugInfo: debugInfo)
        }

        // NOTE: First, varibale type is checked,
        //       then, variable value setting is checked.

        if evaluatedVariable.type == .integer {
            guard let evaluatedValue = evaluatedVariable.value else {
                throw ProgramError(errorType: InterpreterError.undefinedVariable, debugInfo: debugInfo)
            }
            return Variable(type: .integer,
                            isConstant: true,
                            value: (evaluatedValue as! Int))

        } else if evaluatedVariable.type == .real {
            guard let evaluatedValue = evaluatedVariable.value else {
                throw ProgramError(errorType: InterpreterError.undefinedVariable, debugInfo: debugInfo)
            }
            return Variable(type: .real,
                            isConstant: true,
                            value: (evaluatedValue as! Double))
        } else {
            throw ProgramError(errorType: InterpreterError.expressionEvaluationError, debugInfo: debugInfo)
        }
    }

    private func evaluateMinus(context: Scope,
                               session: Session) throws -> Evaluable? {

        guard let evaluatedVariable = try operand.evaluate(context: context,
                                                           session: session) as? Variable else {
            throw ProgramError(errorType: InterpreterError.expressionEvaluationError, debugInfo: debugInfo)
        }

        // NOTE: First, varibale type is checked,
        //       then, variable value setting is checked.

        if evaluatedVariable.type == .integer {
            guard let evaluatedValue = evaluatedVariable.value else {
                throw ProgramError(errorType: InterpreterError.undefinedVariable, debugInfo: debugInfo)
            }
            return Variable(type: .integer,
                            isConstant: true,
                            value: -(evaluatedValue as! Int))

        } else if evaluatedVariable.type == .real {
            guard let evaluatedValue = evaluatedVariable.value else {
                throw ProgramError(errorType: InterpreterError.undefinedVariable, debugInfo: debugInfo)
            }
            return Variable(type: .real,
                            isConstant: true,
                            value: -(evaluatedValue as! Double))
        } else {
            throw ProgramError(errorType: InterpreterError.expressionEvaluationError, debugInfo: debugInfo)
        }
    }

}
