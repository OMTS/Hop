//
//  Program.swift
//  TestLexer
//
//  Created by poisson florent on 01/06/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

struct Program: Loggable {
    
    var statements: [Evaluable]

    var description: String {
        var description = ""
        for statement in statements {
            description += statement.description + "\n"
        }
        return description
    }
    
    @discardableResult func perform(with session: Session) throws -> Scope {
        
        let context = Scope(parent: nil)
        
        for statement in statements {
            _ = try statement.evaluate(context: context,
                                       session: session)
            
            if context.returnedEvaluable != nil {
                break
            }
            
            if context.isBreakRequested {
                break
            }
            
            if context.isContinueRequested {
                break
            }
        }
        
        return context
    }

}
