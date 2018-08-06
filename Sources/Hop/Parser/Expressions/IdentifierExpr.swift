//
//  IdentifierExpr.swift
//  TestLexer
//
//  Created by poisson florent on 05/06/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

class IdentifierExpr: Evaluable {
    
    var name: String
    var hashId: Int
    var debugInfo: DebugInfo?

    init(name: String) {
        self.name = name
        self.hashId = name.hashValue
    }
    
    var description: String {
        return "Id(\(name))"
    }

    func evaluate(context: Scope,
                  session: Session) throws -> Evaluable? {
        // First, search in current scope
        if let symbol = context.getSymbolValue(for: hashId) {
            return symbol
        }
        
        // Then, search in global scope
        if let symbol = session.globalScope.getSymbolValue(for: hashId) {
            return symbol
        }
        
        throw ProgramError(errorType: InterpreterError.unresolvedIdentifier,
                           debugInfo: debugInfo)
    }

}
