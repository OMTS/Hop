//
//  Package.swift
//  TestEditor
//
//  Created by poisson florent on 10/07/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation


/**
 
 A package is container for subpackages & modules
 
 */

class Package: Evaluable {
    var debugInfo: DebugInfo?

    let name: String
    let hashId: Int
    let scope: Scope
    
    init(name: String, scope: Scope) {
        self.name = name
        self.hashId = name.hashValue
        self.scope = scope
        self.scope.name = name // Module scope is named
    }
    
    var description: String {
        return "Package(\(name))"
    }
    
    func evaluate(context: Scope,
                  session: Session) throws -> Evaluable? {
        return self
    }
    
}

