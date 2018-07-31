//
//  Parser.swift
//  TestLexer
//
//  Created by poisson florent on 29/05/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

private let binOpPrecedences: [Token : Int] = [
    .assignment: 10,
    .logicalAND: 20,
    .logicalOR: 20,
    .equal: 30,
    .notEqual: 30,
    .lessThan: 40,
    .greaterThan: 40,
    .greaterThanOrEqualTo: 40,
    .lessThanOrEqualTo: 40,
    .plus: 50,
    .minus: 50,
    .multiplication: 60,
    .divide: 60,
    .remainder: 60,
    .dot: 70
]

enum ParserError: ErrorType {
    case expressionError
    case prototypeError

    func getDescription() -> String {
        switch self {
        case .expressionError:
            return "Expression Error"
        case .prototypeError:
            return "Prototype Error"
        }
    }
}

class Parser {

    private let lexer: Lexer
    private var currentToken: Token!
    private var isDebug = false

    init(with lexer: Lexer) {
        self.lexer = lexer
    }
    
    private func getNextToken() throws {
        currentToken = try lexer.getNextToken()
        if let currentToken = currentToken {
            print("------------------------------------")
            print("--> currentToken = \(currentToken)")
            let currentPosition = lexer.getCurrentPosition()
            print("--> charIndex: \(currentPosition)")
        } else {
            print("--> currentToken is empty")
        }
    }
    
    func getCurrentTokenPrecedence() -> Int {
        guard let currentToken = currentToken,
            let precedence = binOpPrecedences[currentToken] else {
                return -1
        }
        
        return precedence
    }
    
    func parseProgram(with environment: Environment) throws -> Program? {
        isDebug = environment.isDebug
        try getNextToken()
        var statements = [Evaluable]()
        while currentToken != .eof {
            if let statement = try parseStatement() {
                statements.append(statement)
            }
        }
        if statements.count > 0 {
            return Program(block: BlockStmt(statements: statements))
        }
        
        return nil
    }
    
    // MARK: - Statements parsing
    
    private func parseStatement() throws -> Evaluable? {
        
        while currentToken == .lf {
            try getNextToken() // Consume isolated line feed
        }
        
        if currentToken == .importToken {
            return try parseImportStatement()
        }
        
        if currentToken == .funcToken {
            return try parseFunctionStatement()
        }
        
        if currentToken == .returnToken {
            return try parseReturnStatement()
        }

        if currentToken == .breakToken {
            return try parseBreakStatement()
        }

        if currentToken == .continueToken {
            return try parseContinueStatement()
        }

        if currentToken == .ifToken {
            return try parseIfStatement()
        }
        
        if currentToken == .forToken {
            return try parseForStatement()
        }
        
        if currentToken == .whileToken {
            return try parseWhileStatement()
        }
        
        if currentToken == .variable {
            return try parseVariableDeclarationStatement()
        }
        
        if currentToken == .constant {
            return try parseConstantDeclarationStatement()
        }
        
        if currentToken == .classToken {
            return try parseClassDeclarationStatement()
        }
        
        return try parseExpressionStatement()
    }
    
    /**
 
     "import" <i> "\n"
     
    */
    private func parseImportStatement() throws -> Evaluable? {
        guard currentToken == .importToken else {
            // Import token is awaited
            throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())

        }
        
        try getNextToken() // Consume 'import'
        
        guard currentToken == .identifier,
            let name = lexer.currentTokenValue as? String else {
            throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())

        }
        
        try getNextToken() // Consume identifier
        
        guard currentToken == .lf else {
            throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
        }
        
        try getNextToken() // Consume line feed

        let importStmt = ImportStmt(name: name)
        if isDebug {
            importStmt.setDebuggabbleInfo(lineNumber: lexer.getLineNumber(), position: lexer.getCurrentPosition())
        }
        return importStmt
    }
    
    /**
     
     "func" <id> "(" <argument>* ")" "=>" <id> "{" <statement>* "}" "\n"
     
    */
    private func parseFunctionStatement() throws -> Evaluable? {
        if currentToken != .funcToken {
            // Function token is awaited
            throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
        }
        
        try getNextToken() // Consume 'func'

        let prototype = try parseFunctionPrototype()
        let block = try parseBlock()
        
        // Expected line feed
        guard currentToken == .lf else {
            throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
        }
        
        try getNextToken() // Consume line feed
        
        let funcDeclarationStmt = FunctionDeclarationStmt(prototype: prototype,
                                       block: block)
        if isDebug {
            funcDeclarationStmt.setDebuggabbleInfo(lineNumber: lexer.getLineNumber(), position: lexer.getCurrentPosition())
        }
        return funcDeclarationStmt
    }
    
    /**
     
        <id> "(" <argument>* ")" "=>" <id>
     
    */
    private func parseFunctionPrototype() throws -> FunctionDeclarationPrototype {
        if currentToken == .identifier,
            let name = lexer.currentTokenValue as? String {
            
            try getNextToken() // Consume identifier
            
            // Check if identifier is not a reserved keyword
            if let token = Token(rawValue: name),
                Token.reservedKeywords.contains(token) {
                throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
            }
            
            if currentToken == .leftParenthesis {
                
                try getNextToken() // Consume '('
                
                let arguments = try parseFunctionArguments()

                if currentToken == .rightParenthesis {
                    
                    try getNextToken() // Consume ')'

                    var typeExpr: Evaluable?

                    // Process optional returned type
                    if currentToken == .funcReturnToken {
                        
                        try getNextToken() // Consume '->'

                        typeExpr = try parseTypeExpression()
                        if typeExpr == nil {
                            throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
                        }
                    }
                    
                    return FunctionDeclarationPrototype(name: name,
                                                        arguments: arguments,
                                                        typeExpr: typeExpr)
                } else {
                    throw ProgramError(errorType: ParserError.prototypeError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
                }
            } else {
                throw ProgramError(errorType: ParserError.prototypeError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
            }
        } else {
            throw ProgramError(errorType: ParserError.prototypeError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
        }
    }
    
    private func parseFunctionArgument(isAnonymous: Bool = false) throws -> FunctionDeclarationArgument? {
        if currentToken == .hash {
            // Anonymous parameter
            try getNextToken() // Consume #
            
            return try parseFunctionArgument(isAnonymous: true)

        } else if currentToken == .identifier,
            let name = lexer.currentTokenValue as? String {
            
            try getNextToken() // Consume argument name
            
            if currentToken == .colon {
                
                try getNextToken() // Consume colon

                guard let typeExpr = try parseTypeExpression() else {
                    throw ProgramError(errorType: ParserError.prototypeError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
                }

                return FunctionDeclarationArgument(name: name,
                                                   typeExpr: typeExpr,
                                                   isAnonymous: isAnonymous)
            } else {
                throw ProgramError(errorType: ParserError.prototypeError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
            }
        }

        return nil
    }
    
    private func parseFunctionArguments() throws -> [FunctionDeclarationArgument]? {
        var arguments = [FunctionDeclarationArgument]()
        
        while true {
            if let argument = try parseFunctionArgument() {
                arguments.append(argument)
                
                if currentToken == .comma {
                    try getNextToken() // Consume comma separator
                }
            } else {
                // End of arguments
                break
            }
        }
        
        if arguments.count > 0 {
            return arguments
        }

        return nil
    }
    
    /**
     "init" ["(" <parameter>* ")"] "{" <block> "}"
    */
//    private func parseInitializerDeclarationStatement() throws -> Evaluable? {
//        guard currentToken == .initToken else {
//            throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
//        }
//
//        try getNextToken() // Consume 'init'
//
//        var arguments: [Prototype.Argument]!
//
//        if currentToken == .leftParenthesis {
//
//            try getNextToken() // Consume '('
//
//            arguments = try parseFunctionArguments()
//
//            guard currentToken == .rightParenthesis else {
//                throw ProgramError(errorType: ParserError.prototypeError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
//            }
//
//            try getNextToken() // Consume ')'
//        }
//
//        let block = try parseBlock()
//
//        // Expected line feed
//        guard currentToken == .lf else {
//            throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
//        }
//
//        let prototype = Prototype(name: Token.initToken.rawValue,
//                                  arguments: arguments,
//                                  type: .void)
//
//        return FunctionDeclarationStmt(prototype: prototype,
//                                       block: block)
//    }

//    /**
//     "deinit" "{" <block> "}"
//     */
//    private func parseDeinitializerDeclarationStatement() throws -> Evaluable? {
//        guard currentToken == .deinitToken else {
//            throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
//        }
//        
//        try getNextToken() // Consume 'deinit'
//
//        if let block = try parseBlock() {
//            guard currentToken == .lf else {
//                throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
//            }
//            
//            try getNextToken() // Consume line feed
//            
//            let prototype = Prototype(name: Token.deinitToken.rawValue,
//                                      arguments: nil,
//                                      type: .void)
//            
//            return FunctionDeclarationStmt(prototype: prototype,
//                                           block: block)
//        }
//        
//        return nil
//    }
    
    private func parseBlock() throws -> BlockStmt? {
        guard currentToken == .leftCurlyBrace else {
            throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
        }
        
        try getNextToken() // Consume '{'
        
        var statements = [Evaluable]()
        var noAnymoreStatement = false
        while true {
            if currentToken == .eof {
                throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
            }
            
            if currentToken == .rightCurlyBrace {
                break
            }

            if noAnymoreStatement {
                throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
            }
            
            if let statement = try parseStatement() {
                statements.append(statement)
            } else {
                noAnymoreStatement = true
            }
        }
        
        try getNextToken() // Consume '}'
        
        if statements.count > 0 {
            return BlockStmt(statements: statements)
        }
        
        return nil
    }

    
    /**
     "if" <expression> "{" <block> "}" ["else" "{" <block> "}"] "\n"
    */
    private func parseIfStatement() throws -> Evaluable? {
        guard currentToken == .ifToken else {
            throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
        }
        
        try getNextToken() // Consume 'if'

        guard let conditionExpr = try parseExpression() else {
            throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
        }

        var thenBlock: BlockStmt!
        var elseBlock: BlockStmt!
        
        var isThenStmtWithBrakets = false
        
        if currentToken == .leftCurlyBrace {
            
            isThenStmtWithBrakets = true
            
            thenBlock = try parseBlock()

        } else {
            throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
        }

        if currentToken == .elseToken {
            
            try getNextToken() // Consume 'else'
            
            if currentToken == .leftCurlyBrace {
                
                elseBlock = try parseBlock()
                
                // Line feed is expected
                guard currentToken == .lf else {
                    throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
                }
                
                try getNextToken() // Consume line feed
                
            } else if currentToken == .ifToken,
                let ifStatement = try parseIfStatement() {

                elseBlock = BlockStmt(statements: [ifStatement])
                
            } else {
                throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
            }
        } else if isThenStmtWithBrakets {
            // Line feed is expected
            guard currentToken == .lf else {
                throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
            }
            
            try getNextToken() // Consume line feed
        }
        let ifStmt = IfStmt(conditionExpression: conditionExpr, thenBlock: thenBlock, elseBlock: elseBlock)
        if isDebug {
            ifStmt.setDebuggabbleInfo(lineNumber: lexer.getLineNumber(), position: lexer.getCurrentPosition())
        }
        return ifStmt
    }

    /**
        "for" <id> "in" <expression> "to" <expression> ["step" <expression>] "{" <block> "}" "\n"
    */
    private func parseForStatement() throws -> Evaluable? {
        guard currentToken == .forToken else {
            throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
        }
        
        try getNextToken() // Consume 'for'

        guard currentToken == .identifier,
            let indexName = lexer.currentTokenValue as? String else {
            throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
        }
        
        try getNextToken() // Consume index identifier
        
        guard currentToken == .inToken else {
            throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
        }

        try getNextToken() // Consume 'in'

        guard let startExpression = try parseExpression() else {
            throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
        }
        
        guard currentToken == .to else {
            throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
        }

        try getNextToken() // Consume 'to'

        guard let endExpression = try parseExpression() else {
            throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
        }
        
        var stepExpression: Evaluable?
        
        if currentToken == .step {
            
            try getNextToken() // Consume 'step'
            
            stepExpression = try parseExpression()
            
            if stepExpression == nil {
                throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
            }
        }

        let block = try parseBlock()

        guard currentToken == .lf else {
            throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
        }

        try getNextToken() // Consume line feed

        if block != nil {
            let forStmt = ForStmt(indexName: indexName,
                                  startExpression: startExpression,
                                  endExpression: endExpression,
                                  stepExpression: stepExpression,
                                  block: block!)
            if isDebug {
                forStmt.setDebuggabbleInfo(lineNumber: lexer.getLineNumber(), position: lexer.getCurrentPosition())
            }
            return forStmt
        }
        
        // No for loop body
        // => no needed to register a for loop
        return nil
    }

    /**
        "while" <expression> "{" <block> "}" "\n"
    */
    private func parseWhileStatement() throws -> Evaluable? {
        guard currentToken == .whileToken else {
            throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
        }
        
        try getNextToken() // Consume 'while'
        
        guard let conditionExpression = try parseExpression() else {
            throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
        }
        
        let block = try parseBlock()
        
        guard currentToken == .lf else {
            throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
        }
        
        try getNextToken() // Consume line feed
        
        if block != nil {
            return WhileStmt(conditionExpression: conditionExpression, block: block!)
        }
        
        // No while loop body
        // => no needed to register a while loop
        return nil
    }
    
    /**
     
     "return" <expression optional> "\n"
     
    */
    private func parseReturnStatement() throws -> Evaluable? {
        guard currentToken == .returnToken else {
            throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
        }
        
        try getNextToken() // Consume 'return'
        
        let result = try parseExpression()

        // Expected line feed
        guard currentToken == .lf else {
            throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
        }
        
        try getNextToken() // Consume line feed

        let resultStmt = ReturnStmt(result: result)
        if isDebug {
            resultStmt.setDebuggabbleInfo(lineNumber: lexer.getLineNumber(), position: lexer.getCurrentPosition())
        }
        return resultStmt
    }
    
    /**
     
     "break" "\n"
     
     */
    private func parseBreakStatement() throws -> Evaluable? {
        guard currentToken == .breakToken else {
            throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
        }
        
        try getNextToken() // Consume 'break'
        
        guard currentToken == .lf else {
            throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
        }
        
        try getNextToken() // Consume line feed

        let breakStmt = BreakStmt()
        if isDebug {
            breakStmt.setDebuggabbleInfo(lineNumber: lexer.getLineNumber(), position: lexer.getCurrentPosition())
        }
        return breakStmt
    }
    
    /**
     
     "continue" "\n"
     
     */
    private func parseContinueStatement() throws -> Evaluable? {
        guard currentToken == .continueToken else {
            throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
        }
        
        try getNextToken() // Consume 'continue'
        
        guard currentToken == .lf else {
            throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
        }
        
        try getNextToken() // Consume line feed

        let continueStmt = ContinueStmt()
        if isDebug {
            continueStmt.setDebuggabbleInfo(lineNumber: lexer.getLineNumber(), position: lexer.getCurrentPosition())
        }
        return continueStmt
    }
    
    /**
     
     "const" <id> ":" <id> "=" <expression> "\n"
     
     */
    private func parseConstantDeclarationStatement() throws -> Evaluable? {
        guard currentToken == .constant else {
            throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
        }
        
        try getNextToken() // Consume 'const'
        
        guard currentToken == .identifier,
            let name = lexer.currentTokenValue as? String else {
            throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
        }
        
        try getNextToken() // Consume constant identifier

        // Check if identifier is not a reserved keyword
        if let token = Token(rawValue: name),
            Token.reservedKeywords.contains(token) {
            throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
        }

        // Type declaration is optional for constant declaration
        var typeExpr: Evaluable?
        if currentToken == .colon {
            try getNextToken() // Consume ':'
            
            typeExpr = try parseTypeExpression()
            if typeExpr == nil {
                throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
            }
        }

        // Parse assignment
        guard currentToken == .assignment else {
            throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
        }

        try getNextToken() // Consume '='

        guard let expression = try parseExpression() else {
            throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
        }
        
        guard currentToken == .lf else {
            throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
        }

        try getNextToken() // Consume '\n'

        return VariableDeclarationStmt(name: name,
                                       typeExpr: typeExpr,
                                       isConstant: true,
                                       isPrivate: false,
                                       expr: expression)
    }

    /**
     
     "var" <id> ":" <id> ["=" <expression>] "\n"
     
    */
    private func parseVariableDeclarationStatement() throws -> Evaluable? {
        guard currentToken == .variable else {
            throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
        }

        try getNextToken() // Consume 'var'
        
        guard currentToken == .identifier,
            let name = lexer.currentTokenValue as? String else {
                throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
        }
        
        try getNextToken() // Consume constant identifier
        
        // Check if identifier is not a reserved keyword
        if let token = Token(rawValue: name),
            Token.reservedKeywords.contains(token) {
            throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
        }
        
        // Type declaration can be optional for variable declaration
        // if assigned expression is filled.
        var typeExpr: Evaluable?
        if currentToken == .colon {
            try getNextToken() // Consume ':'
            
            typeExpr = try parseTypeExpression()
            if typeExpr == nil {
                throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
            }
        }

        // Parse optinal assignment
        var expression: Evaluable?

        if currentToken == .assignment {
            
            try getNextToken() // Consume '='

            expression = try parseExpression()
            
            if expression == nil {
                throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
            }
        }
        
        guard currentToken == .lf else {
            throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
        }
        
        try getNextToken() // Consume '\n'
        
        return VariableDeclarationStmt(name: name,
                                       typeExpr: typeExpr,
                                       isConstant: false,
                                       isPrivate: false,
                                       expr: expression)
    }
    
    /**
     <identifier>.(...)
     */
    private func parseTypeExpression() throws -> Evaluable? {
        guard currentToken == .identifier,
            let name = lexer.currentTokenValue as? String else {
                return nil
        }
        
        try getNextToken() // Consume lhs identifier
        
        var lhs: Evaluable = IdentifierExpr(name: name)
        if isDebug {
            (lhs as! IdentifierExpr).setDebuggabbleInfo(lineNumber: lexer.getLineNumber(), position: lexer.getCurrentPosition())
        }
        
        while true {
            if currentToken != .dot {
                return lhs
            }
            
            // Okay, we know this is a dot binop.
            try getNextToken() // eat binop
            
            // Parse next identifier
            guard currentToken == .identifier,
                let name = lexer.currentTokenValue as? String else {
                    return nil
            }
            
            try getNextToken() // Consume rhs identifier
            
            // Merge LHS/RHS.
            lhs = BinaryOperatorExpr(binOp: .dot, lhs: lhs, rhs: IdentifierExpr(name: name))
            if isDebug {
                (lhs as! BinaryOperatorExpr).setDebuggabbleInfo(lineNumber: lexer.getLineNumber(), position: lexer.getCurrentPosition())
            }
        }
    }
    
    private func parseExpressionStatement() throws -> Evaluable? {
        guard let expression = try parseExpression() else {
            return nil
        }
        
        guard currentToken == .lf else {
            // error: consecutive statements on a line are not allowed
            throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
        }

        let exprStmt = ExpressionStmt(expr: expression)
        if isDebug {
            exprStmt.setDebuggabbleInfo(lineNumber: lexer.getLineNumber(), position: lexer.getCurrentPosition())
        }
        return exprStmt
    }
    
    /**
     "class" <id> "{" <statement>* "}" "\n"
    */
    private func parseClassDeclarationStatement() throws -> Evaluable? {
        guard currentToken == .classToken else {
            throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
        }
        
        try getNextToken() // Consume 'class'
        
        guard currentToken == .identifier,
            let name = lexer.currentTokenValue as? String else {
            throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
        }

        try getNextToken() // Consume class identifier
        
        var superclassExpr: Evaluable?
        if currentToken == .colon {
            try getNextToken() // Consume ':'
            
            superclassExpr = try parseTypeExpression()
            if superclassExpr == nil {
                throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
            }
        }
        
        guard currentToken == .leftCurlyBrace else {
            throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
        }

        try getNextToken() // Consume '{'

        var instancePropertyDeclarations = [VariableDeclarationStmt]()
        var instanceMethodDeclarations = [FunctionDeclarationStmt]()
        var classPropertyDeclarations = [VariableDeclarationStmt]()
        var classMethodDeclarations = [FunctionDeclarationStmt]()
        var innerClassDeclarations = [ClassDeclarationStmt]()

        var noAnymoreStatement = false
        while true {
            if currentToken == .eof {
                throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
            }
            
            if currentToken == .lf {
                try getNextToken() // Consume line feed
                continue
            }
            
            if currentToken == .rightCurlyBrace {
                break
            }
            
            if noAnymoreStatement {
                throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
            }
            
            // Instance member declarations
            
            if currentToken == .variable,
                let instanceVariableDeclaration = try parseVariableDeclarationStatement() as? VariableDeclarationStmt {
                if isDebug {
                    instanceVariableDeclaration.setDebuggabbleInfo(lineNumber: lexer.getLineNumber(), position: lexer.getCurrentPosition())
                }
                instancePropertyDeclarations.append(instanceVariableDeclaration)
                continue
            }
            
            if currentToken == .constant,
                let instanceConstantDeclaration = try parseConstantDeclarationStatement() as? VariableDeclarationStmt {
                if isDebug {
                    instanceConstantDeclaration.setDebuggabbleInfo(lineNumber: lexer.getLineNumber(), position: lexer.getCurrentPosition())
                }
                instancePropertyDeclarations.append(instanceConstantDeclaration)
                continue
            }
            
            if currentToken == .funcToken,
                let instanceMethodDeclaration = try parseFunctionStatement() as? FunctionDeclarationStmt {
                if isDebug {
                    instanceMethodDeclaration.setDebuggabbleInfo(lineNumber: lexer.getLineNumber(), position: lexer.getCurrentPosition())
                }
                instanceMethodDeclarations.append(instanceMethodDeclaration)
                continue
            }
            
            // Class member declarations
            
            if currentToken == .staticToken {
                
                try getNextToken() // Consume 'static'
                
                if currentToken == .variable,
                    let classVariableDeclaration = try parseVariableDeclarationStatement() as? VariableDeclarationStmt {
                    if isDebug {
                        classVariableDeclaration.setDebuggabbleInfo(lineNumber: lexer.getLineNumber(), position: lexer.getCurrentPosition())
                    }
                    classPropertyDeclarations.append(classVariableDeclaration)
                    continue
                }
                
                if currentToken == .constant,
                    let classConstantDeclaration = try parseConstantDeclarationStatement() as? VariableDeclarationStmt {
                    if isDebug {
                        classConstantDeclaration.setDebuggabbleInfo(lineNumber: lexer.getLineNumber(), position: lexer.getCurrentPosition())
                    }
                    classPropertyDeclarations.append(classConstantDeclaration)
                    continue
                }
                
                if currentToken == .funcToken,
                    let classMethodDeclaration = try parseFunctionStatement() as? FunctionDeclarationStmt {
                    if isDebug {
                        classMethodDeclaration.setDebuggabbleInfo(lineNumber: lexer.getLineNumber(), position: lexer.getCurrentPosition())
                    }
                    classMethodDeclarations.append(classMethodDeclaration)
                    continue
                }
            }
            
            if currentToken == .classToken,
                let innerClassDeclaration = try parseClassDeclarationStatement() as? ClassDeclarationStmt {
                if isDebug {
                    innerClassDeclaration.setDebuggabbleInfo(lineNumber: lexer.getLineNumber(), position: lexer.getCurrentPosition())
                }
                innerClassDeclarations.append(innerClassDeclaration)
                continue
            }
            
            noAnymoreStatement = true
        }
        
        try getNextToken() // Consume '}'
        
        
        guard currentToken == .lf else {
            throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
        }
        
        try getNextToken() // Consume line feed

        let classDeclarationStmt = ClassDeclarationStmt(name: name,
                                                        superclassExpr: superclassExpr,
                                                        classPropertyDeclarations: classPropertyDeclarations,
                                                        classMethodDeclarations: classMethodDeclarations,
                                                        instancePropertyDeclarations: instancePropertyDeclarations,
                                                        instanceMethodDeclarations: instanceMethodDeclarations,
                                                        innerClassDeclarations: innerClassDeclarations)
        if isDebug {
            classDeclarationStmt.setDebuggabbleInfo(lineNumber: lexer.getLineNumber(), position: lexer.getCurrentPosition())
        }
        return classDeclarationStmt
    }
    
    // MARK: - Expressions parsing
    
    /**
     
     Primary expressions parsing
     
     primary
        ::= identifierexpr
        ::= integerExpr
        ::= realExpr
        ::= booleanExpr
        ::= stringExpr
        ::= parenExpr
     
    */
    private func parsePrimaryExpression() throws -> Evaluable? {
        switch currentToken! {
        case .identifier:
            return try parseIdentifierExpression()
            
        case .integer:
            return try parseIntegerExpression()
            
        case .real:
            return try parseRealExpression()
            
        case .boolean:
            return try parseBooleanExpression()
            
        case .string:
            return try parseStringExpression()
            
        case .leftParenthesis:
            return try parseParenthesisExpression()
            
        case .superToken:
            return try parseSuperExpression()
            
        case .nilToken:
            return try parseNilExpression()
            
        default:
            return nil
        }
    }
    
    /// identifierexpr
    ///   ::= identifier
    ///   ::= identifier '(' expression* ')'
    private func parseIdentifierExpression() throws -> Evaluable? {
        guard let name = lexer.currentTokenValue as? String else {
            throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
        }
        
        try getNextToken() // Consume identifer token
        
        guard currentToken == .leftParenthesis else {
            // Variable parsing
            let identifierExpr = IdentifierExpr(name: name)
            if isDebug {
                identifierExpr.setDebuggabbleInfo(lineNumber: lexer.getLineNumber(), position: lexer.getCurrentPosition())
            }
            return identifierExpr
        }
        
        // Function call parsing
        try getNextToken() // consume left parenthesis: (
        
        var arguments = [FunctionCallArgument]()
        
        if currentToken! != .rightParenthesis {
            while true {
                if let expression = try parseExpression() {
                    if let identifierExpr = expression as? IdentifierExpr {
                        if currentToken == .colon {
                            try getNextToken() // Consume ':'
                            
                            if let expression = try parseExpression() {
                                // Named argument
                                arguments.append(FunctionCallArgument(name: identifierExpr.name, expr: expression))
                                
                            } else {
                                throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
                            }
                        } else {
                            // Anonymous argument
                            arguments.append(FunctionCallArgument(name: nil, expr: identifierExpr))
                        }
                    } else {
                        // Anonymous argument
                        arguments.append(FunctionCallArgument(name: nil, expr: expression))
                    }
                } else {
                    throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
                }
                
                if currentToken == .rightParenthesis {
                    break
                }
                
                if currentToken == .comma {} else {
                    throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
                }
                
                try getNextToken() // Consume comma
            }
        }
        
        try getNextToken() // Consume right parenthesis: )
        let funcCallExpr = FunctionCallExpr(name: name,
                                            arguments: arguments.count > 0 ? arguments : nil)
        if isDebug {
            funcCallExpr.setDebuggabbleInfo(lineNumber: lexer.getLineNumber(), position: lexer.getCurrentPosition())
        }
        return funcCallExpr
    }
    
    private func parseFunctionCallArgument() throws -> FunctionCallArgument? {
        if case Token.eof = currentToken! {
            return nil
        }
        
        if currentToken == .identifier {
            
            guard let name = lexer.currentTokenValue as? String else {
                // TODO: good error handling
                throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
            }
            
            try getNextToken() // Consume identifier
            
            if currentToken == .colon {
                try getNextToken() // Consume colon
                
                if let expression = try parseExpression() {
                    // Named argument
                    return FunctionCallArgument(name: name, expr: expression)
                } else {
                    throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
                }
            } else if let expression = try parseBinOpRHS(lhs: IdentifierExpr(name: name), expressionPrecedence: 0) {
                // Anonymous argument
                return FunctionCallArgument(name: nil, expr: expression)
                
            } else {
                throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
            }
        } else if let expression = try parseExpression() {
            // Anonymous argument
            return FunctionCallArgument(name: nil, expr: expression)
            
        } else {
            throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
        }
    }
    
    /**
     
    */
    private func parseIntegerExpression() throws -> IntegerExpr {
        guard let value = lexer.currentTokenValue as? Int else {
            // TODO: good erro handling
            throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
        }
        
        let integerExpression = IntegerExpr(value: value)
        try getNextToken() // consume the integer number
        return integerExpression
    }
    
    /**
     
     */
    private func parseRealExpression() throws -> RealExpr {
        guard let value = lexer.currentTokenValue as? Double else {
            // TODO: good erro handling
            throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
        }
        
        let realExpression = RealExpr(value: value)
        try getNextToken() // consume the real number
        return realExpression
    }
    
    /**
     
     */
    private func parseBooleanExpression() throws -> BooleanExpr {
        guard let value = lexer.currentTokenValue as? Bool else {
            // TODO: good erro handling
            throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
        }
        
        let booleanExpression = BooleanExpr(value: value)
        try getNextToken() // consume the boolean
        return booleanExpression
    }
    
    /**
     
     */
    private func parseStringExpression() throws -> StringExpr {
        guard let value = lexer.currentTokenValue as? String else {
            // TODO: good erro handling
            throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
        }
        
        let stringExpression = StringExpr(value: value)
        try getNextToken() // consume the string
        return stringExpression
    }
    
    /// parenexpr ::= '(' expression ')'
    private func parseParenthesisExpression() throws -> Evaluable? {
        try getNextToken() // consume left parenthesis: (
        let parsedExpression = try parseExpression()
        if parsedExpression == nil {
            return nil
        }
        
        guard case Token.rightParenthesis = currentToken! else {
            throw ProgramError(errorType: ParserError.expressionError, lineNumber: lexer.getLineNumber(), postion: lexer.getCurrentPosition())
        }
        
        try getNextToken() // Consume right parenthesis: )
        
        return parsedExpression
    }
    
    /**
     
     */
    private func parseSuperExpression() throws -> Evaluable {
        try getNextToken() // consume 'super'

        let superExpr = SuperExpr()
        if isDebug {
            superExpr.setDebuggabbleInfo(lineNumber: lexer.getLineNumber(), position: lexer.getCurrentPosition())
        }
        return superExpr
    }
    
    /**
     */
    private func parseNilExpression() throws -> Evaluable {
        try getNextToken() // consume 'nil'

        let nilExpr = NilExpr()
        if isDebug {
            nilExpr.setDebuggabbleInfo(lineNumber: lexer.getLineNumber(), position: lexer.getCurrentPosition())
        }
        return nilExpr
    }
    
    /// unary
    ///   ::= primary
    ///   ::= '!' unary
    private func parseUnaryExpression() throws -> Evaluable? {
        // If the current token is not an operator, it must be a primary expr.
        if !Token.unaryOperatorTokens.contains(currentToken) ||
            currentToken == .leftParenthesis {
            return try parsePrimaryExpression()
        }
    
        // If this is a unary operator, read it.
        let unOp = currentToken!

        try getNextToken() // consume unary operator

        if let operand = try parseUnaryExpression() {
            let unaryOperatorExpr = UnaryOperatorExpr(unOp: unOp, operand: operand)
            if isDebug {
                unaryOperatorExpr.setDebuggabbleInfo(lineNumber: lexer.getLineNumber(), position: lexer.getCurrentPosition())
            }
            return unaryOperatorExpr
        }
        
        return nil
    }
    
    /// binoprhs
    ///   ::= ('+' primary)*
    private func parseBinOpRHS(lhs: Evaluable, expressionPrecedence: Int) throws -> Evaluable? {
        var lhs = lhs
        
        // If this is a binary operator, find its precedence.
        while true {
            let tokenPrecedence = getCurrentTokenPrecedence()
            
            // If this is a binary operator that binds at least as tightly
            // as the current binary operator, consume it, otherwise we are done.
            if tokenPrecedence < expressionPrecedence {
                return lhs
            }
            
            // Okay, we know this is a binop.
            let binOp = currentToken
            try getNextToken() // eat binop
            
            // Parse the primary expression after the binary operator.
            var rhs = try parseUnaryExpression()
            if rhs == nil {
                return nil
            }
            
            // If BinOp binds less tightly with RHS than the operator after RHS, let
            // the pending operator take RHS as its LHS.
            let nextPrecedence = getCurrentTokenPrecedence()
            if tokenPrecedence < nextPrecedence {
                rhs = try parseBinOpRHS(lhs: rhs!, expressionPrecedence: tokenPrecedence + 1)
                if rhs == nil {
                    return nil
                }
            }
            
            // Merge LHS/RHS.
            lhs = BinaryOperatorExpr(binOp: binOp!, lhs: lhs, rhs: rhs!)
        }
    }
    
    /// expression
    ///   ::= primary binoprhs
    ///
    private func parseExpression() throws -> Evaluable? {
        guard let lhs = try parseUnaryExpression() else {
            return nil
        }
        
        return try parseBinOpRHS(lhs: lhs, expressionPrecedence: 0)
    }
    
}
