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
    
    var expr: Evaluable
    
    var description: String {
        return expr.description
    }
    
    func evaluate(context: Scope,
                  session: Session) throws -> Evaluable? {
        _ = try expr.evaluate(context: context,
                              session: session)
        return nil  // Statement does not return
    }

}
