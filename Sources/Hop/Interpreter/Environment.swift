//
//  Environment.swift
//  Hop iOS
//
//  Created by poisson florent on 27/07/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

public class Environment {

    // External environment properties
    // -------------------------------
    
    var sessionId: String?
    
    // Debug mode activation
    var isDebug = false
    
    // Messenger used to propagate interpreter message outside
    var messenger: Messenger?
    
    typealias ScriptModuleHandler = (_ name: String) -> String?
    
    // Handler provided for getting external module scripts
    var getScriptForModule: ScriptModuleHandler?

    // Internal environment properties
    // -------------------------------
    
    // Global scope used to store loaded modules
    let modulesScope = Scope(parent: nil)

    init(sessionId: String?,
         isDebug: Bool?,
         messenger: Messenger?,
         getScriptForModule: ScriptModuleHandler?) {
        
        self.sessionId = sessionId
        if let isDebug = isDebug {
            self.isDebug = isDebug
        }
        self.messenger = messenger
        self.getScriptForModule = getScriptForModule
    }
    
}
