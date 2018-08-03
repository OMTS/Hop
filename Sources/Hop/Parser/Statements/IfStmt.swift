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
struct IfStmt: Evaluable {
    var debugInfo: DebugInfo?

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

    func evaluate(context: Scope,
                  session: Session) throws -> Evaluable? {
        guard let conditionVariable = try conditionExpression.evaluate(context: context,
                                                                       session: session) as? Variable,
            let conditionValue = conditionVariable.value as? Bool else {
            throw ProgramError(errorType: InterpreterError.expressionEvaluationError, debugInfo: debugInfo)
        }
        
        if conditionValue {
            _ = try thenBlock?.evaluate(context: context,
                                        session: session)
        } else {
            _ = try elseBlock?.evaluate(context: context,
                                        session: session)
        }
        
        return nil
    }
    
}
