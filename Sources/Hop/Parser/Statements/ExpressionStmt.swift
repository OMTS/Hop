//
//  ExpressionStmt.swift
//  TestLexer
//
//  Created by poisson florent on 05/06/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

/**
 
 Expression statement
 
 */
struct ExpressionStmt: Evaluable {
    var debugInfo: DebugInfo?
    var expr: Evaluable

    init(expr: Evaluable) {
        self.expr = expr
    }

    var description: String {
        return expr.description
    }
    
    func evaluate(context: Scope, environment: Environment) throws -> Evaluable? {
        _ = try expr.evaluate(context: context,
                              environment: environment)
        return nil  // Statement does not return
    }

}
