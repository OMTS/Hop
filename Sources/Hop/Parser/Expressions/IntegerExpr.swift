//
//  IntegerExpr.swift
//  TestLexer
//
//  Created by poisson florent on 05/06/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

class IntegerExpr: Evaluable {
    var debugInfo: DebugInfo?

    let value: Int
    
    init(value: Int) {
        self.value = value
    }
    
    var description: String {
        return "Integer(\(value))"
    }
    
    func evaluate(context: Scope,
                  session: Session) throws -> Evaluable? {
        return Variable(type: .integer,
                        isConstant: true,
                        value: value)
    }
    
}
