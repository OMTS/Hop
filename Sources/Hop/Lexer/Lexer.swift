//
//  Lexer.swift
//  TestLexer
//
//  Created by poisson florent on 26/05/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

public enum LexerError: ErrorType {
    case unknownError
    case illegalContent

    public func getDescription() -> String {
        switch self {
        case .unknownError:
            return "Unknown Lexing Error"
        case .illegalContent:
            return "Illegal Content"
        }
    }
}

public class Lexer {

    private var chars: [Character]!
    public private(set) var nextCharIndex: Int = 0
    private var lineIndex: Int = 0
    private var currentChar: Character! {
        if nextCharIndex < chars.count {
            return chars[nextCharIndex]
        }
        return nil
    }
    fileprivate var lastTokenPosition: Int?
    fileprivate let isDebug: Bool
    public var currentTokenValue: Any?
    
    public init(script: String, isDebug: Bool) {
        self.isDebug = isDebug
        chars = Array(script)
    }
    
    public func getCurrentPosition() -> Int {
        return nextCharIndex
    }

    public func getLineNumber() -> Int {
        return lineIndex - 1 
    }

    public func getNextChar() {
        nextCharIndex += 1
    }

    public func getChar(at index: Int) -> Character? {
        if index < 0 { return nil }
        if index > chars.count - 1 { return nil }
        return chars[index]
    }
    
    public func getNextToken() throws -> Token {
        if currentTokenValue != nil {
            currentTokenValue = nil
        }
        
        if currentChar == nil {
            return Token.eof
        }
        
        // Consume white space
        // (i.e. space, horizontal tab (TAB), vertical tab (VT), feed (FF), carriage return (CR))
        while isWhiteSpace(currentChar) {
            getNextChar()
            if currentChar == nil {
                return Token.eof
            }
        }
        
        // Consume line feeds
        while currentChar == "\n" || currentChar == "\r\n" {
            getNextChar()   // Consume '\n' or \r\n
            lineIndex += 1
            if currentChar != "\n" && currentChar != "\r\n" {
                return Token.lf
            }
        }

        // Consume divide
        if currentChar == "/" {
            // Consume character
            getNextChar()
            
            if currentChar != nil {
                if currentChar == "/" {
                    getNextChar()
                    // Consume // comment up to the end of line
                    while currentChar != nil && (currentChar != "\n" || currentChar == "\r\n") {
                        getNextChar()
                    }
                    return try getNextToken()
                } else if currentChar == "*" {
                    getNextChar()
                    // Consume /* */ comment
                    while true {
                        if currentChar == nil {
                            return Token.eof
                        }
                        
                        if currentChar == "\n" || currentChar == "\r\n" {
                            lineIndex += 1
                        }
                        
                        if currentChar == "*" {
                            getNextChar()
                            if currentChar != nil && currentChar == "/" {
                                getNextChar()
                                return try getNextToken()
                            }
                        } else {
                            getNextChar()
                        }
                    }
                }
            }
            setLastTokenPositionForDebug(forToken: .divide)
            return Token.divide
        }
        
        // Consume hash
        if currentChar == "#" {
            getNextChar()
            setLastTokenPositionForDebug(forToken: .hash)
            return .hash
        }
        
        // Consume colon
        if currentChar == ":" {
            getNextChar()
            setLastTokenPositionForDebug(forToken: .colon)
            return .colon
        }
        
        // Consume comma
        if currentChar == "," {
            getNextChar()
            setLastTokenPositionForDebug(forToken: .comma)
            return .comma
        }

        // Consume dot
        if currentChar == "." {
            getNextChar()
            setLastTokenPositionForDebug(forToken: .dot)
            return .dot
        }

        // Consume left curly brace
        if currentChar == "{" {
            getNextChar()
            setLastTokenPositionForDebug(forToken: .leftCurlyBrace)
            return .leftCurlyBrace
        }
        
        // Consume right curly brace
        if currentChar == "}" {
            getNextChar()
            setLastTokenPositionForDebug(forToken: .rightCurlyBrace)
            return .rightCurlyBrace
        }
        
        // Consume left parenthesis
        if currentChar == "(" {
            getNextChar()
            setLastTokenPositionForDebug(forToken: .leftParenthesis)
            return .leftParenthesis
        }
        
        // Consume right parenthesis
        if currentChar == ")" {
            getNextChar()
            setLastTokenPositionForDebug(forToken: .rightParenthesis)
            return .rightParenthesis
        }

        // Consume left square bracket
        if currentChar == "[" {
            getNextChar()
            setLastTokenPositionForDebug(forToken: .leftSquareBracket)
            return .leftSquareBracket
        }
        
        // Consume right square bracket
        if currentChar == "]" {
            getNextChar()
            setLastTokenPositionForDebug(forToken: .rightSquareBracket)
            return .rightSquareBracket
        }
        
        // Consume ones' complement
        if currentChar == "~" {
            getNextChar()
            setLastTokenPositionForDebug(forToken: .onesComplement)
            return .onesComplement
        }
        
        // Consume logical negation
        if currentChar == "!" {
            getNextChar()
            
            // Consume not equal
            if currentChar != nil && currentChar == "=" {
                getNextChar()
                setLastTokenPositionForDebug(forToken: .notEqual)
                return .notEqual
            }
            setLastTokenPositionForDebug(forToken: .logicalNegation)
            return .logicalNegation
        }
        
        // Consume plus
        if currentChar == "+" {
            getNextChar()
            setLastTokenPositionForDebug(forToken: .plus)
            return .plus
        }
        
        // Consume minus
        if currentChar == "-" {
            getNextChar()
            
            if currentChar != nil && currentChar == ">" {
                getNextChar()  // Consume function return token '->'
                setLastTokenPositionForDebug(forToken: .funcReturnToken)
                return .funcReturnToken
            }
            setLastTokenPositionForDebug(forToken: .minus)
            return .minus
        }
        
        // Consume multiplication
        if currentChar == "*" {
            getNextChar()
            setLastTokenPositionForDebug(forToken: .multiplication)
            return .multiplication
        }
        
        // Consume remainder
        if currentChar == "%" {
            getNextChar()
            setLastTokenPositionForDebug(forToken: .remainder)
            return .remainder
        }

        // Consume assignment
        if currentChar == "=" {
            getNextChar()
            
            if currentChar != nil && currentChar == "=" {
                getNextChar() // Consume equal '=='
                setLastTokenPositionForDebug(forToken: .equal)
                return .equal
            }
            setLastTokenPositionForDebug(forToken: .assignment)
            return .assignment
        }
        
        // Consume less than
        if currentChar == "<" {
            getNextChar()
            
            // Consume less than or equal to
            if currentChar != nil && currentChar == "=" {
                getNextChar()
                setLastTokenPositionForDebug(forToken: .lessThanOrEqualTo)
                return .lessThanOrEqualTo
            }
            setLastTokenPositionForDebug(forToken: .lessThan)
            return .lessThan
        }
        
        // Consume greater than
        if currentChar == ">" {
            getNextChar()
            
            // Consume greater than or equalTo
            if currentChar != nil && currentChar == "=" {
                getNextChar()
                setLastTokenPositionForDebug(forToken: .greaterThanOrEqualTo)
                return .greaterThanOrEqualTo
            }
            setLastTokenPositionForDebug(forToken: .greaterThan)
            return .greaterThan
        }
        
        // Consume logical AND
        if currentChar == "&" {
            getNextChar()
            
            // Consume logical AND
            if currentChar != nil && currentChar == "&" {
                getNextChar()
                setLastTokenPositionForDebug(forToken: .logicalAND)
                return .logicalAND
            }
            
            throw ProgramError(errorType: LexerError.illegalContent, debugInfo: debugInfo)
        }
        
        // Consume logical OR
        if currentChar == "|" {
            getNextChar()
            
            // Consume logical OR
            if currentChar != nil && currentChar == "|" {
                getNextChar()
                setLastTokenPositionForDebug(forToken: .logicalOR)
                return .logicalOR
            }
            
            throw ProgramError(errorType: LexerError.illegalContent, debugInfo: debugInfo)
        }
        
        // Consume identifier
        if isAlpha(currentChar) {
            var buffer = String(currentChar)
            getNextChar()
            
            while currentChar != nil && isAlphanumeric(currentChar) {
                buffer.append(currentChar)
                getNextChar()
            }
            
            // Reserved keywords
            if let token = Token(rawValue: buffer),
                Token.reservedKeywords.contains(token) {
                setLastTokenPositionForDebug(forToken: token)
                return token
            }
            
            // Values or identifier
            switch buffer {
            case "true":
                currentTokenValue = true
                setLastTokenPositionForDebug(forToken: .boolean, witValue: currentTokenValue)
                return .boolean
            case "false":
                currentTokenValue = false
                setLastTokenPositionForDebug(forToken: .boolean, witValue: currentTokenValue)
                return .boolean
            default:
                currentTokenValue = buffer
                setLastTokenPositionForDebug(forToken: .identifier, witValue: currentTokenValue)
                return Token.identifier
            }
        }
        
        if isNumeric(currentChar) {
            var buffer = String(currentChar)
            var hasDecimal = false
            getNextChar()
            
            while currentChar != nil && (isNumeric(currentChar) || (!hasDecimal && currentChar == ".")) {
                buffer.append(currentChar)
                if currentChar == "." {
                    hasDecimal = true
                }
                getNextChar()
            }
            
            if hasDecimal {
                currentTokenValue = Double(buffer)!
                setLastTokenPositionForDebug(forToken: .real, witValue: currentTokenValue)
                return .real
            }
            
            currentTokenValue = Int(buffer)!
            setLastTokenPositionForDebug(forToken: .integer, witValue: currentTokenValue)
            return .integer
        }
        
        // Consume string literal
        if currentChar == "\"" {
            getNextChar() // Consume first "

            var buffer = ""
            while currentChar != nil {
                if currentChar == "\\" {
                    buffer.append(currentChar)
                    getNextChar()
                    
                    if currentChar != nil {
                        // Consume escaped character
                        buffer.append(currentChar)
                        getNextChar()
                    }
                } else if currentChar == "\"" {
                    getNextChar() // Consume last "
                    break
                } else {
                    buffer.append(currentChar)
                    getNextChar()
                }
            }
            
            currentTokenValue = buffer
            setLastTokenPositionForDebug(forToken: .string, witValue: currentTokenValue)
            return .string
        }
        
        throw ProgramError(errorType: LexerError.unknownError, debugInfo: debugInfo)
    }
    
    // MARK: Helpers
    
    private func loadProgram(from url: URL) -> String? {
        do {
            return try String(contentsOf: url, encoding: .utf8)
        } catch let error {
            print("Error: program file loading failed with error: \(error)")
        }
        return nil
    }

    static private let whiteSpaces = [" ", "\t", "\r"]
    static private let alphas = "abcdefghijklmnopqrstuvwxyz"
    static private let numerics = Array("0123456789")
    static private let lowercasedAlphas = Array(alphas)
    static private let uppercasedAlphas = Array(alphas.uppercased())
    
    private func isWhiteSpace(_ character: Character) -> Bool {
        return Lexer.whiteSpaces.contains(String(currentChar))
    }
    
    private func isAlpha(_ character: Character) -> Bool {
        return Lexer.lowercasedAlphas.contains(character) ||
            Lexer.uppercasedAlphas.contains(character)
    }
    
    private func isNumeric(_ character: Character) -> Bool {
        return Lexer.numerics.contains(character)
    }
    
    private func isAlphanumeric(_ character: Character) -> Bool {
        return isAlpha(character) || isNumeric(character)
    }

}

//Debug API
extension Lexer {

    //Debug API Herlper
    var debugInfo: DebugInfo? {
        let debugPosition = getLastTokenPositionForDebug()
        let debugLine = getLineIndexForDebug(forCursorPosition: debugPosition)
        return DebugInfo(lineNumber: debugLine, position: debugPosition)
    }

    fileprivate func getLastTokenPositionForDebug() -> Int? {
        return lastTokenPosition
    }

    fileprivate func getLineIndexForDebug(forCursorPosition cursorPosition: Int?) -> Int?  {
        guard let cursorPosition = cursorPosition else {
            return nil
        }
        return getLineIndex(forCursorPosition:cursorPosition) + 1
    }

    fileprivate func setLastTokenPositionForDebug(forToken token: Token, witValue value: Any? = nil) {
        if isDebug {
            if let value = value {
                if let name = value as? String {
                    lastTokenPosition = nextCharIndex - name.count
                } else if let name = value as? Int  {
                    lastTokenPosition = nextCharIndex - String(name).count
                } else if let name = value as? Double  {
                    lastTokenPosition = nextCharIndex - String(name).count
                } else if let name = value as? Bool  {
                    lastTokenPosition = nextCharIndex - String(name).count
                }
            } else {
                lastTokenPosition = nextCharIndex - token.rawValue.count
            }
        }
    }
}

//Utilities
extension Lexer {
    private func computeLines(in characters: Array<Character>) -> [NSRange] {
        var lines = [NSRange]()

        var lineLocation = 0
        var lineLength = 0

        for character in characters {
            lineLength += 1
            if character == "\n" {
                // Add line feed
                lines.append(NSRange(location: lineLocation, length: lineLength))
                lineLocation += lineLength
                lineLength = 0
            }
        }

        // Add last line
        lines.append(NSRange(location: lineLocation, length: lineLength))

        //        print("lines = \(lines)")
        return lines
    }

    public func getLineIndex(forCursorPosition cursorPosition: Int) -> Int {

        let lines: [NSRange] = computeLines(in: chars)
        if cursorPosition >= chars.count {
            return lines.count - 1
        }

        for (index, line) in lines.enumerated() {
            if cursorPosition >= line.location
                && cursorPosition < NSMaxRange(line) {
                return index
            }
        }
        return 0
    }
}

