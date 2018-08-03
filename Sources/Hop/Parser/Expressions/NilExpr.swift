//
//  NilExpr.swift
//  TestEditor
//
//  Created by poisson florent on 22/07/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

class NilExpr: Evaluable {
    var debugInfo: DebugInfo?

    static private let nilVariable = Variable(type: .nil, isConstant: true, value: nil)
    
    var description: String {
        return "nil"
    }
    
    func evaluate(context: Scope,
                  session: Session) throws -> Evaluable? {
        return NilExpr.nilVariable
    }
    
}
