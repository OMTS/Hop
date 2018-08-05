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
        // TODO: ...
        return self
    }
    
}
