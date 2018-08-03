//
//  LexerTests.swift
//  Hop iOS
//
//  Created by Iman Zarrabian on 25/07/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import XCTest
@testable import Hop

class LexerTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testCreationFromScript() {
        let script = "const a = 3\n"
        let lexer = Lexer(script: script, isDebug: true)

        XCTAssertNotNil(lexer.getChar(at: 0))
        XCTAssertNotNil(lexer.getChar(at: 10))
        XCTAssertNil(lexer.getChar(at: 12))
        XCTAssertEqual(lexer.getChar(at: 0)!, "c")
        XCTAssertEqual(lexer.getChar(at: 11)!, "\n")
    }

    func testGetNextTokenForLineFeeds() {
        let scriptWithLF = "import Sys\nSys.print(\"42\")\n"
        let scriptWithCRLF = "import Sys\r\nSys.print(\"42\")\r\n"


        var tokensWithLF = [Token]()
        var tokensWithCRLF = [Token]()

        do {
            var lexer = Lexer(script: scriptWithLF, isDebug: true)
            for _ in 0...10 {
                tokensWithLF.append(try lexer.getNextToken())
            }

            lexer = Lexer(script: scriptWithCRLF, isDebug: true)
            for _ in 0...10 {
                tokensWithCRLF.append(try lexer.getNextToken())
            }
        } catch (_) {
            XCTAssert(false)
        }

        XCTAssertEqual(tokensWithLF.count, tokensWithCRLF.count)
        XCTAssertEqual(tokensWithLF[2], Token.lf)
        XCTAssertEqual(tokensWithLF[9], Token.lf)
        XCTAssertEqual(tokensWithLF[2], tokensWithCRLF[2])
        XCTAssertEqual(tokensWithLF[9], tokensWithCRLF[9])
        XCTAssertEqual(tokensWithLF[10], Token.eof)
        XCTAssertEqual(tokensWithLF[10], tokensWithCRLF[10])
    }
}
