//
//  ArrayLiteralExpr.swift
//  Hop iOS
//
//  Created by poisson florent on 05/08/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

class ArrayLiteralExpr: Evaluable {

    let itemExpressions: [Evaluable]
    var debugInfo: DebugInfo?
    
    init(itemExpressions: [Evaluable]) {
        self.itemExpressions = itemExpressions
    }
    
    var description: String {
        // TODO: ...
        return "Array literal"
    }
    
    func evaluate(context: Scope,
                  session: Session) throws -> Evaluable? {
        
        let functionCallExpr = FunctionCallExpr(name: "Array",
                                                arguments: nil)
        
        let instanceVariable = try functionCallExpr.evaluate(context: context,
                                                            session: session) as! Variable
        if itemExpressions.count > 0 {
            guard let instance = instanceVariable.value as? Instance,
                let arrayVariable = instance.scope.getSymbolValue(for: "__array__".hashValue) as? Variable,
                let array = arrayVariable.value as? NSMutableArray else {
                throw ProgramError(errorType: InterpreterError.expressionEvaluationError,
                                   debugInfo: debugInfo)
            }

            var evaluatedVariables = [Variable]()
            for itemExpression in itemExpressions {
                guard let evaluatedVariable = try itemExpression.evaluate(context: context,
                                                                       session: session) as? Variable else {
                    throw ProgramError(errorType: InterpreterError.expressionEvaluationError,
                                       debugInfo: itemExpression.debugInfo)
                }
                evaluatedVariables.append(evaluatedVariable)
            }
            
            array.addObjects(from: evaluatedVariables)
        }
        
        return instanceVariable
    }
    
}
