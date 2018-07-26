//
//  Interpreter.swift
//  TestLexer
//
//  Created by poisson florent on 01/06/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation


public class Interpreter {

    public struct Configuration {
        var messenger: Messenger?
        var isDebug: Bool?
    }
    
    private var messenger: Messenger?
    private var isDebug: Bool = false
    
    public init() {}
    
    public init(config: Configuration) {
        self.messenger = config.messenger
        if let isDebug = config.isDebug {
            self.isDebug = isDebug
        }
    }
    
    public func runScript(_ script: String) throws {
        let lexer = Lexer(script: script)
        let parser = Parser(with: lexer)
        if let program = try parser.parseProgram() {
            try program.perform()
        }
    }
    
}



