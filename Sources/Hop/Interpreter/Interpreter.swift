//
//  Interpreter.swift
//  TestLexer
//
//  Created by poisson florent on 01/06/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation


public class Interpreter {
    
    private var environment: Environment
    
    public init(environment: Environment) {
        self.environment = environment
    }
    
    public func runScript(_ script: String) throws {
        let lexer = Lexer(script: script)
        let parser = Parser(with: lexer)
        if let program = try parser.parseProgram() {
            try program.perform(with: environment)
        }
    }
    
}



