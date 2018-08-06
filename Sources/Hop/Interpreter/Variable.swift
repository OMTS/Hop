//
//  Variable.swift
//  TestLexer
//
//  Created by poisson florent on 13/06/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

class Variable: Evaluable {
    var debugInfo: DebugInfo?
    
    
    var type: Type
    var isTypeMutabilityAllowed: Bool = false   // Used by container variables
    var isConstant: Bool
    var value: Any? {
        willSet {
            if let instance = value as? Instance {
                instance.refCount -= 1
                if instance.refCount <= 0 {
                    instance.clearProperties()
                }
            }
        }
        didSet {
            if let instance = value as? Instance {
                instance.refCount += 1
            }
        }
    }
    
    init(type: Type, isConstant: Bool, value: Any?) {
        self.type = type
        self.isConstant = isConstant
        self.value = value
    }
    
    func copy() -> Variable {
        return Variable(type: type,
                        isConstant: true,
                        value: value)
    }

    var description: String {
        return isConstant ? "const " : "" + "variable<\(type.name)>"
    }
    
    func evaluate(context: Scope,
                  session: Session) throws -> Evaluable? {
        return self
    }
    
}
