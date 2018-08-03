//
//  IdentifierExpr.swift
//  TestLexer
//
//  Created by poisson florent on 05/06/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

class IdentifierExpr: Evaluable {
    var debugInfo: DebugInfo?


    var name: String
    var hashId: Int
    
    init(name: String) {
        self.name = name
        self.hashId = name.hashValue
    }
    
    var description: String {
        return "Id(\(name))"
    }

    func evaluate(context: Scope,
                  session: Session) throws -> Evaluable? {
        guard let symbol = context.getSymbolValue(for: hashId) else {
            throw ProgramError(errorType: InterpreterError.unresolvedIdentifier, debugInfo: debugInfo)
        }
        
        return symbol
    }

}
