//
//  IfStmt.swift
//  TestLexer
//
//  Created by poisson florent on 05/06/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

/**
 
 If statement
 
 */
class IfStmt: DebuggableElement, Evaluable {
    
    var conditionExpression: Evaluable
    var thenBlock: BlockStmt?
    var elseBlock: BlockStmt?

    init(conditionExpression: Evaluable, thenBlock: BlockStmt?, elseBlock: BlockStmt?) {
        self.conditionExpression = conditionExpression
        self.thenBlock = thenBlock
        self.elseBlock = elseBlock
    }

    var description: String {
        var description = "if " + conditionExpression.description + " {\n"
        if let thenBlock = thenBlock {
            description += thenBlock.description
        }
        description += "}"
        if let elseBlock = elseBlock {
            description += " else "
            if let firstStatement = elseBlock.statements.first,
                firstStatement is IfStmt {
                description += firstStatement.description
            } else {
                description += "{\n"
                description += elseBlock.description
                description += "}\n"
            }
        }
        return description
    }

    func evaluate(context: Scope, environment: Environment) throws -> Evaluable? {
        guard let conditionVariable = try conditionExpression.evaluate(context: context,
                                                                       environment: environment) as? Variable,
            let conditionValue = conditionVariable.value as? Bool else {
            throw ProgramError(errorType: InterpreterError.expressionEvaluationError, lineNumber: lineNumber, postion: position)
        }
        
        if conditionValue {
            _ = try thenBlock?.evaluate(context: context,
                                        environment: environment)
        } else {
            _ = try elseBlock?.evaluate(context: context,
                                        environment: environment)
        }
        
        return nil
    }
    
}
