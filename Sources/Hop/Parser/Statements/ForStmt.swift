//
//  ForStmt.swift
//  TestLexer
//
//  Created by poisson florent on 07/06/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

/**
 
    For statement
 
 */

class ForStmt: DebuggableElement, Evaluable {

    private let indexName: String
    private let indexHashId: Int
    private let startExpression: Evaluable
    private let endExpression: Evaluable
    private let stepExpression: Evaluable?
    private let block: BlockStmt
    
    init(indexName: String,
         startExpression: Evaluable,
         endExpression: Evaluable,
         stepExpression: Evaluable?,
         block: BlockStmt) {
        self.indexName = indexName
        self.indexHashId = indexName.hashValue
        self.startExpression = startExpression
        self.endExpression = endExpression
        self.stepExpression = stepExpression
        self.block = block
    }
    
    var description: String {
        var description = "for "
            + indexName
            + " in "
            + startExpression.description
            + " to "
            + endExpression.description
            + " {\n"
        description += block.description
        description += "}\n"
        return description
    }
    
    // MARK: - Returnable
    
    func evaluate(context: Scope, environment: Environment) throws -> Evaluable? {
        guard let startVariable = try startExpression.evaluate(context: context,
                                                               environment: environment) as? Variable,
            let startIndex = startVariable.value as? Int else {
            throw ProgramError(errorType: InterpreterError.expressionEvaluationError, lineNumber: lineNumber, postion: position)
        }
        
        guard let endVariable = try endExpression.evaluate(context: context,
                                                           environment: environment) as? Variable,
            let endIndex = endVariable.value as? Int else {
                throw ProgramError(errorType: InterpreterError.expressionEvaluationError, lineNumber: lineNumber, postion: position)
        }

        var stepIncrement = 1
        if let stepEvaluation = try stepExpression?.evaluate(context: context,
                                                             environment: environment) {
            guard let stepVariable = stepEvaluation as? Variable,
                let stepValue = stepVariable.value as? Int else {
                throw ProgramError(errorType: InterpreterError.expressionEvaluationError, lineNumber: lineNumber, postion: position)
            }
            stepIncrement = stepValue
        }

        let indexVariable = Variable(type: .integer, isConstant: false, value: nil)
        let indexContext = Scope(parent: context)
        indexContext.symbolTable[indexHashId] = indexVariable
        
        for i in stride(from: startIndex, to: endIndex, by: stepIncrement) {
            indexVariable.value = i
            
            _ = try block.evaluate(context: indexContext,
                                   environment: environment)
            
            if indexContext.returnedEvaluable != nil {
                break
            }

            if indexContext.isBreakRequested {
                indexContext.isBreakRequested = false
                break
            }

            if indexContext.isContinueRequested {
               indexContext.isContinueRequested = false
                continue
            }
        }
        
        // Propagate returned expression to parent if needed
        context.returnedEvaluable = indexContext.returnedEvaluable
        
        return nil
    }
    
}
