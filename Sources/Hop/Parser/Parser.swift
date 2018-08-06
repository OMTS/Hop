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
    private let isDebug: Bool

    init(with lexer: Lexer, isDebug: Bool) {
        self.isDebug = isDebug
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
    
    func parseProgram() throws -> Program? {
        try getNextToken()
        var statements = [Evaluable]()
        while currentToken != .eof {
            if let statement = try parseStatement() {
                statements.append(statement)
            }
        }
        if statements.count > 0 {
            return Program(statements: statements)
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
            throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
        }

        try getNextToken() // Consume 'import'
        
        guard currentToken == .identifier,
            let name = lexer.currentTokenValue as? String else {
                throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
        }

        try getNextToken() // Consume identifier
        
        guard currentToken == .lf else {
            throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
        }
        
        try getNextToken() // Consume line feed

        let importStmt = ImportStmt(name: name)
        importStmt.debugInfo = lexer.debugInfo
        return importStmt
    }
    
    /**
     
     "func" <id> "(" <argument>* ")" "=>" <id> "{" <statement>* "}" "\n"
     
    */
    private func parseFunctionStatement() throws -> Evaluable? {
        if currentToken != .funcToken {
            // Function token is awaited
            throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
        }
        
        try getNextToken() // Consume 'func'

        let prototype = try parseFunctionPrototype()
        let block = try parseBlock()
        
        // Expected line feed
        guard currentToken == .lf else {
            throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
        }
        
        try getNextToken() // Consume line feed
        
        let funcDeclarationStmt = FunctionDeclarationStmt(prototype: prototype,
                                       block: block)
        funcDeclarationStmt.debugInfo = lexer.debugInfo
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
                throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
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
                            throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
                        }
                    }
                    
                    return FunctionDeclarationPrototype(name: name,
                                                        arguments: arguments,
                                                        typeExpr: typeExpr)
                } else {
                    throw ProgramError(errorType: ParserError.prototypeError, debugInfo: lexer.debugInfo)
                }
            } else {
                throw ProgramError(errorType: ParserError.prototypeError, debugInfo: lexer.debugInfo)
            }
        } else {
            throw ProgramError(errorType: ParserError.prototypeError, debugInfo: lexer.debugInfo)
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
                    throw ProgramError(errorType: ParserError.prototypeError, debugInfo: lexer.debugInfo)
                }

                return FunctionDeclarationArgument(name: name,
                                                   typeExpr: typeExpr,
                                                   isAnonymous: isAnonymous)
            } else {
                throw ProgramError(errorType: ParserError.prototypeError, debugInfo: lexer.debugInfo)
            }
        } else if currentToken == .rightParenthesis {
            return nil
        } else {
            throw ProgramError(errorType: ParserError.prototypeError, debugInfo: lexer.debugInfo)
        }
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
//            throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
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
//                throw ProgramError(errorType: ParserError.prototypeError, debugInfo: lexer.debugInfo)
//            }
//
//            try getNextToken() // Consume ')'
//        }
//
//        let block = try parseBlock()
//
//        // Expected line feed
//        guard currentToken == .lf else {
//            throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
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
//            throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
//        }
//        
//        try getNextToken() // Consume 'deinit'
//
//        if let block = try parseBlock() {
//            guard currentToken == .lf else {
//                throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
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
            throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
        }
        
        try getNextToken() // Consume '{'
        
        var statements = [Evaluable]()
        var noAnymoreStatement = false
        while true {
            if currentToken == .eof {
                throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
            }
            
            if currentToken == .rightCurlyBrace {
                break
            }

            if noAnymoreStatement {
                throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
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
            throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
        }
        
        try getNextToken() // Consume 'if'

        guard let conditionExpr = try parseExpression() else {
            throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
        }

        var thenBlock: BlockStmt!
        var elseBlock: BlockStmt!
        
        var isThenStmtWithBrakets = false
        
        if currentToken == .leftCurlyBrace {
            
            isThenStmtWithBrakets = true
            
            thenBlock = try parseBlock()

        } else {
            throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
        }

        if currentToken == .elseToken {
            
            try getNextToken() // Consume 'else'
            
            if currentToken == .leftCurlyBrace {
                
                elseBlock = try parseBlock()
                
                // Line feed is expected
                guard currentToken == .lf else {
                    throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
                }
                
                try getNextToken() // Consume line feed
                
            } else if currentToken == .ifToken,
                let ifStatement = try parseIfStatement() {

                elseBlock = BlockStmt(statements: [ifStatement])
                
            } else {
                throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
            }
        } else if isThenStmtWithBrakets {
            // Line feed is expected
            guard currentToken == .lf else {
                throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
            }
            
            try getNextToken() // Consume line feed
        }
        var ifStmt = IfStmt(conditionExpression: conditionExpr, thenBlock: thenBlock, elseBlock: elseBlock)
        ifStmt.debugInfo = lexer.debugInfo
        return ifStmt
    }

    /**
        "for" <id> "in" <expression> "to" <expression> ["step" <expression>] "{" <block> "}" "\n"
    */
    private func parseForStatement() throws -> Evaluable? {
        guard currentToken == .forToken else {
            throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
        }
        
        try getNextToken() // Consume 'for'

        guard currentToken == .identifier,
            let indexName = lexer.currentTokenValue as? String else {
            throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
        }
        
        try getNextToken() // Consume index identifier
        
        guard currentToken == .inToken else {
            throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
        }

        try getNextToken() // Consume 'in'

        guard let startExpression = try parseExpression() else {
            throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
        }

        guard currentToken == .to else {
            throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
        }

        try getNextToken() // Consume 'to'

        guard let endExpression = try parseExpression() else {
            throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
        }
        
        var stepExpression: Evaluable?
        
        if currentToken == .step {
            
            try getNextToken() // Consume 'step'
            
            stepExpression = try parseExpression()
            
            if stepExpression == nil {
                throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
            }
        }

        let block = try parseBlock()

        guard currentToken == .lf else {
            throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
        }

        try getNextToken() // Consume line feed

        var forStmt = ForStmt(indexName: indexName,
                              startExpression: startExpression,
                              endExpression: endExpression,
                              stepExpression: stepExpression,
                              block: block)
        forStmt.debugInfo = lexer.debugInfo
        return forStmt
    }

    /**
        "while" <expression> "{" <block> "}" "\n"
    */
    private func parseWhileStatement() throws -> Evaluable? {
        guard currentToken == .whileToken else {
            throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
        }
        
        try getNextToken() // Consume 'while'
        
        guard let conditionExpression = try parseExpression() else {
            throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
        }
        
        let block = try parseBlock()
        
        guard currentToken == .lf else {
            throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
        }
        
        try getNextToken() // Consume line feed
        
        let whileStmt = WhileStmt(conditionExpression: conditionExpression, block: block)
        whileStmt.debugInfo = lexer.debugInfo
        return whileStmt
    }
    
    /**
     
     "return" <expression optional> "\n"
     
    */
    private func parseReturnStatement() throws -> Evaluable? {
        guard currentToken == .returnToken else {
            throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
        }
        
        try getNextToken() // Consume 'return'
        
        let result = try parseExpression()

        // Expected line feed
        guard currentToken == .lf else {
            throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
        }
        
        try getNextToken() // Consume line feed

        var resultStmt = ReturnStmt(result: result)
        resultStmt.debugInfo = lexer.debugInfo
        return resultStmt
    }
    
    /**
     
     "break" "\n"
     
     */
    private func parseBreakStatement() throws -> Evaluable? {
        guard currentToken == .breakToken else {
            throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
        }
        
        try getNextToken() // Consume 'break'
        
        guard currentToken == .lf else {
            throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
        }
        
        try getNextToken() // Consume line feed

        var breakStmt = BreakStmt()
        breakStmt.debugInfo = lexer.debugInfo
        return breakStmt
    }
    
    /**
     
     "continue" "\n"
     
     */
    private func parseContinueStatement() throws -> Evaluable? {
        guard currentToken == .continueToken else {
            throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
        }
        
        try getNextToken() // Consume 'continue'
        
        guard currentToken == .lf else {
            throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
        }
        
        try getNextToken() // Consume line feed

        var continueStmt = ContinueStmt()
        continueStmt.debugInfo = lexer.debugInfo
        return continueStmt
    }
    
    /**
     
     "const" <id> ":" <id> "=" <expression> "\n"
     
     */
    private func parseConstantDeclarationStatement() throws -> Evaluable? {
        guard currentToken == .constant else {
            throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
        }
        
        try getNextToken() // Consume 'const'
        
        guard currentToken == .identifier,
            let name = lexer.currentTokenValue as? String else {
            throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
        }
        
        try getNextToken() // Consume constant identifier

        // Check if identifier is not a reserved keyword
        if let token = Token(rawValue: name),
            Token.reservedKeywords.contains(token) {
            throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
        }

        // Type declaration is optional for constant declaration
        var typeExpr: Evaluable?
        if currentToken == .colon {
            try getNextToken() // Consume ':'
            
            typeExpr = try parseTypeExpression()
            if typeExpr == nil {
                throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
            }
        }

        // Parse assignment
        guard currentToken == .assignment else {
            throw ProgramError(errorType: InterpreterError.missingConstantInitialization, debugInfo: lexer.debugInfo)
        }

        try getNextToken() // Consume '='

        guard let expression = try parseExpression() else {
            throw ProgramError(errorType: InterpreterError.missingConstantInitialization, debugInfo: lexer.debugInfo)
        }
        
        guard currentToken == .lf else {
            throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
        }

        try getNextToken() // Consume '\n'

        let variableDeclarationStmt = VariableDeclarationStmt(name: name,
                                                              typeExpr: typeExpr,
                                                              isConstant: true,
                                                              isPrivate: false,
                                                              expr: expression)

        variableDeclarationStmt.debugInfo = lexer.debugInfo
        return variableDeclarationStmt
    }

    /**
     
     "var" <id> ":" <id> ["=" <expression>] "\n"
     
    */
    private func parseVariableDeclarationStatement() throws -> Evaluable? {
        guard currentToken == .variable else {
            throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
        }

        try getNextToken() // Consume 'var'


        guard currentToken == .identifier,
            let name = lexer.currentTokenValue as? String else {

                throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
        }
        
        try getNextToken() // Consume constant identifier
        
        // Check if identifier is not a reserved keyword
        if let token = Token(rawValue: name),
            Token.reservedKeywords.contains(token) {
            throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
        }
        
        // Type declaration can be optional for variable declaration
        // if assigned expression is filled.
        var typeExpr: Evaluable?
        if currentToken == .colon {
            try getNextToken() // Consume ':'
            
            typeExpr = try parseTypeExpression()
            if typeExpr == nil {
                throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
            }
        }

        // Parse optinal assignment
        var expression: Evaluable?

        if currentToken == .assignment {
            
            try getNextToken() // Consume '='

            expression = try parseExpression()
            
            if expression == nil {
                throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
            }
        }
        
        guard currentToken == .lf else {
            throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
        }
        
        try getNextToken() // Consume '\n'

        let variableDeclarationStmt = VariableDeclarationStmt(name: name,
                                                              typeExpr: typeExpr,
                                                              isConstant: false,
                                                              isPrivate: false,
                                                              expr: expression);
        variableDeclarationStmt.debugInfo = lexer.debugInfo

        return variableDeclarationStmt
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
        (lhs as! IdentifierExpr).debugInfo = lexer.debugInfo

        
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
            lhs.debugInfo = lexer.debugInfo
        }
    }
    
    private func parseExpressionStatement() throws -> Evaluable? {
        guard let expression = try parseExpression() else {
            return nil
        }
        
        guard currentToken == .lf else {
            // error: consecutive statements on a line are not allowed
            throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
        }

        var exprStmt = ExpressionStmt(expr: expression)
        exprStmt.debugInfo = lexer.debugInfo
        return exprStmt
    }
    
    /**
     "class" <id> "{" <statement>* "}" "\n"
    */
    private func parseClassDeclarationStatement() throws -> Evaluable? {
        guard currentToken == .classToken else {
            throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
        }
        
        try getNextToken() // Consume 'class'
        
        guard currentToken == .identifier,
            let name = lexer.currentTokenValue as? String else {
            throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
        }

        try getNextToken() // Consume class identifier
        
        var superclassExpr: Evaluable?
        if currentToken == .colon {
            try getNextToken() // Consume ':'
            
            superclassExpr = try parseTypeExpression()
            if superclassExpr == nil {
                throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
            }
        }
        
        guard currentToken == .leftCurlyBrace else {
            throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
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
                throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
            }
            
            if currentToken == .lf {
                try getNextToken() // Consume line feed
                continue
            }
            
            if currentToken == .rightCurlyBrace {
                break
            }
            
            if noAnymoreStatement {
                throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
            }
            
            // Instance member declarations
            
            if currentToken == .variable,
                let instanceVariableDeclaration = try parseVariableDeclarationStatement() as? VariableDeclarationStmt {
                instanceVariableDeclaration.debugInfo = lexer.debugInfo
                instancePropertyDeclarations.append(instanceVariableDeclaration)
                continue
            }
            
            if currentToken == .constant,
                let instanceConstantDeclaration = try parseConstantDeclarationStatement() as? VariableDeclarationStmt {
                instanceConstantDeclaration.debugInfo = lexer.debugInfo
                instancePropertyDeclarations.append(instanceConstantDeclaration)
                continue
            }
            
            if currentToken == .funcToken,
                let instanceMethodDeclaration = try parseFunctionStatement() as? FunctionDeclarationStmt {
                instanceMethodDeclaration.debugInfo = lexer.debugInfo
                instanceMethodDeclarations.append(instanceMethodDeclaration)
                continue
            }
            
            // Class member declarations
            
            if currentToken == .staticToken {
                
                try getNextToken() // Consume 'static'
                
                if currentToken == .variable,
                    let classVariableDeclaration = try parseVariableDeclarationStatement() as? VariableDeclarationStmt {
                    classVariableDeclaration.debugInfo = lexer.debugInfo
                    classPropertyDeclarations.append(classVariableDeclaration)
                    continue
                }
                
                if currentToken == .constant,
                    let classConstantDeclaration = try parseConstantDeclarationStatement() as? VariableDeclarationStmt {
                    classConstantDeclaration.debugInfo = lexer.debugInfo
                    classPropertyDeclarations.append(classConstantDeclaration)
                    continue
                }
                
                if currentToken == .funcToken,
                    let classMethodDeclaration = try parseFunctionStatement() as? FunctionDeclarationStmt {
                    classMethodDeclaration.debugInfo = lexer.debugInfo
                    classMethodDeclarations.append(classMethodDeclaration)
                    continue
                }
            }
            
            if currentToken == .classToken,
                let innerClassDeclaration = try parseClassDeclarationStatement() as? ClassDeclarationStmt {
                innerClassDeclaration.debugInfo = lexer.debugInfo
                innerClassDeclarations.append(innerClassDeclaration)
                continue
            }
            
            noAnymoreStatement = true
        }
        
        try getNextToken() // Consume '}'
        
        
        guard currentToken == .lf else {
            throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
        }
        
        try getNextToken() // Consume line feed

        let classDeclarationStmt = ClassDeclarationStmt(name: name,
                                                        superclassExpr: superclassExpr,
                                                        classPropertyDeclarations: classPropertyDeclarations,
                                                        classMethodDeclarations: classMethodDeclarations,
                                                        instancePropertyDeclarations: instancePropertyDeclarations,
                                                        instanceMethodDeclarations: instanceMethodDeclarations,
                                                        innerClassDeclarations: innerClassDeclarations)
        classDeclarationStmt.debugInfo = lexer.debugInfo
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
            throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
        }
        
        try getNextToken() // Consume identifer token
        
        guard currentToken == .leftParenthesis else {
            // Variable parsing
            let identifierExpr = IdentifierExpr(name: name)
            identifierExpr.debugInfo = lexer.debugInfo
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
                                throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
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
                    throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
                }
                
                if currentToken == .rightParenthesis {
                    break
                }
                
                if currentToken == .comma {} else {
                    throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
                }
                
                try getNextToken() // Consume comma
            }
        }
        
        try getNextToken() // Consume right parenthesis: )
        var funcCallExpr = FunctionCallExpr(name: name,
                                            arguments: arguments.count > 0 ? arguments : nil)
        funcCallExpr.debugInfo = lexer.debugInfo
        return funcCallExpr
    }
    
    private func parseFunctionCallArgument() throws -> FunctionCallArgument? {
        if case Token.eof = currentToken! {
            return nil
        }
        
        if currentToken == .identifier {
            
            guard let name = lexer.currentTokenValue as? String else {
                // TODO: good error handling
                throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
            }
            
            try getNextToken() // Consume identifier
            
            if currentToken == .colon {
                try getNextToken() // Consume colon
                
                if let expression = try parseExpression() {
                    // Named argument
                    return FunctionCallArgument(name: name, expr: expression)
                } else {
                    throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
                }
            } else if let expression = try parseBinOpRHS(lhs: IdentifierExpr(name: name), expressionPrecedence: 0) {
                // Anonymous argument
                return FunctionCallArgument(name: nil, expr: expression)
                
            } else {
                throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
            }
        } else if let expression = try parseExpression() {
            // Anonymous argument
            return FunctionCallArgument(name: nil, expr: expression)
            
        } else {
            throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
        }
    }
    
    /**
     
    */
    private func parseIntegerExpression() throws -> IntegerExpr {
        guard let value = lexer.currentTokenValue as? Int else {
            // TODO: good erro handling
            throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
        }
        
        let integerExpression = IntegerExpr(value: value)
        integerExpression.debugInfo = lexer.debugInfo
        try getNextToken() // consume the integer number
        return integerExpression
    }
    
    /**
     
     */
    private func parseRealExpression() throws -> RealExpr {
        guard let value = lexer.currentTokenValue as? Double else {
            // TODO: good erro handling
            throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
        }
        
        let realExpression = RealExpr(value: value)
        realExpression.debugInfo = lexer.debugInfo
        try getNextToken() // consume the real number
        return realExpression
    }
    
    /**
     
     */
    private func parseBooleanExpression() throws -> BooleanExpr {
        guard let value = lexer.currentTokenValue as? Bool else {
            // TODO: good erro handling
            throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
        }
        
        let booleanExpression = BooleanExpr(value: value)
        booleanExpression.debugInfo = lexer.debugInfo
        try getNextToken() // consume the boolean
        return booleanExpression
    }
    
    /**
     
     */
    private func parseStringExpression() throws -> StringExpr {
        guard let value = lexer.currentTokenValue as? String else {
            // TODO: good erro handling
            throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
        }
        
        let stringExpression = StringExpr(value: value)
        stringExpression.debugInfo = lexer.debugInfo
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
            throw ProgramError(errorType: ParserError.expressionError, debugInfo: lexer.debugInfo)
        }
        
        try getNextToken() // Consume right parenthesis: )

        return parsedExpression
    }
    
    /**
     
     */
    private func parseSuperExpression() throws -> Evaluable {
        try getNextToken() // consume 'super'

        var superExpr = SuperExpr()
        superExpr.debugInfo = lexer.debugInfo
        return superExpr
    }
    
    /**
     */
    private func parseNilExpression() throws -> Evaluable {
        try getNextToken() // consume 'nil'

        let nilExpr = NilExpr()
        nilExpr.debugInfo = lexer.debugInfo
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
            var unaryOperatorExpr = UnaryOperatorExpr(unOp: unOp, operand: operand)
            unaryOperatorExpr.debugInfo = lexer.debugInfo

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
            rhs?.debugInfo = lexer.debugInfo
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
