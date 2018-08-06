//
//  ArrayLiteralExpr.swift
//  Hop iOS
//
//  Created by poisson florent on 05/08/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

class ArrayLiteralExpr: Evaluable {

    let elementExpressions: [Evaluable]
    var debugInfo: DebugInfo?
    
    init(elementExpressions: [Evaluable]) {
        self.elementExpressions = elementExpressions
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
        if elementExpressions.count > 0 {
            guard let instance = instanceVariable.value as? Instance,
                let arrayVariable = instance.scope.getSymbolValue(for: "__array__".hashValue) as? Variable,
                let array = arrayVariable.value as? NSMutableArray else {
                throw ProgramError(errorType: InterpreterError.expressionEvaluationError,
                                   debugInfo: debugInfo)
            }

            var elementVariables = [Variable]()
            for elementExpression in elementExpressions {
                guard let elementVariable = try elementExpression.evaluate(context: context,
                                                                           session: session) as? Variable else {
                    throw ProgramError(errorType: InterpreterError.expressionEvaluationError,
                                       debugInfo: elementExpression.debugInfo)
                }
                let newElementVariable = elementVariable.copy()
                // Type mutability is allowed to container variable,
                // as container variables are reused by assignment
                // and must accept any types assignment.
                newElementVariable.isConstant = false
                newElementVariable.isTypeMutabilityAllowed = true
                elementVariables.append(newElementVariable)
            }
            
            array.addObjects(from: elementVariables)
        }
        
        return instanceVariable
    }
    
}
