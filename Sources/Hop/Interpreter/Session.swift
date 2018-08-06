//
//  Session.swift
//  Hop iOS
//
//  Created by poisson florent on 27/07/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

public class Session {

    // External environment properties
    // -------------------------------

    // Debug mode activation
    public let isDebug: Bool

    // Messenger used to propagate interpreter message outside
    let messenger: Messenger?

    public typealias ScriptModuleHandler = (_ name: String) -> String?

    // Handler providing external module scripts
    let getScriptForModule: ScriptModuleHandler?

    // Internal environment properties
    // -------------------------------

    // Global scope used to:
    // - store global class like Array, Dictionary, ...
    // - store imported modules
    let globalScope: Scope = getInitializedGlobalScope()

    public init(isDebug: Bool,
                messenger: Messenger?,
                getScriptForModule: ScriptModuleHandler?) {

        self.isDebug = isDebug
        self.messenger = messenger
        self.getScriptForModule = getScriptForModule
    }

    // MARK: - State management

    private static func getInitializedGlobalScope() -> Scope {
        let globalScope = Scope(parent: nil)

        // Inject array class
        importArrayClass(in: globalScope)

        // Inject dictionary class
        // ...

        return globalScope
    }

    public func run(script: String) throws {
        let lexer = Lexer(script: script, isDebug: self.isDebug)
        let parser = Parser(with: lexer, isDebug: self.isDebug)
        if let program = try parser.parseProgram() {
            print(program.description)
            try program.perform(with: self)
        }
    }


}
