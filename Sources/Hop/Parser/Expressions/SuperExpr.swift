//
//  SuperExpr.swift
//  TestLexer
//
//  Created by poisson florent on 27/06/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

class SuperExpr: DebuggableElement, Evaluable {

    var description: String {
        return Token.superToken.rawValue
    }
    
    func evaluate(context: Scope, environment: Environment) throws -> Evaluable? {
        // Search for self in scope hierarchy (super.<instance method> case)
        if let selfValue = context.getSymbolValue(for: SelfParameter.hashId) {
            if let selfVariable = selfValue as? Variable,
                let selfInstance = selfVariable.value as? Instance {
                if selfInstance.class.superclass == nil {
                    throw ProgramError(errorType: InterpreterError.useOfSuperInRootClassMember, lineNumber: lineNumber, postion: position)
                }
                return selfVariable
            } else {
                throw ProgramError(errorType: InterpreterError.expressionEvaluationError, lineNumber: lineNumber, postion: position)
            }
        }
        
        // Search for superclass in scope hierarchy (super.<class method> case)
        if let superValue = context.getSymbolValue(for: SuperParameter.hashId) {
            if superValue is Null {
                // 'super' members cannot be referenced in a root class
                throw ProgramError(errorType: InterpreterError.useOfSuperInRootClassMember, lineNumber: lineNumber, postion: position)
            
            } else if let superclass = superValue as? Class {
                return superclass
                
            } else {
                throw ProgramError(errorType: InterpreterError.expressionEvaluationError, lineNumber: lineNumber, postion: position)
            }
        }
        
        // 'super' cannot be used outside of class members
        throw ProgramError(errorType: InterpreterError.useOfSuperOutsideAClassMember, lineNumber: lineNumber, postion: position)
    }

}
