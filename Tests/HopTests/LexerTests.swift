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
        let lexer = Lexer(script: script)

        XCTAssertNotNil(lexer.getChar(at: 0))
        XCTAssertNotNil(lexer.getChar(at: 10))
        XCTAssertNil(lexer.getChar(at: 12))
        XCTAssertEqual(lexer.getChar(at: 0)!, "c")
        XCTAssertEqual(lexer.getChar(at: 11)!, "\n")
    }

    func testGetNextTokenForLineFeeds() {
        let scriptWithN = "import Sys\nSys.print(\"42\")\n"
        let scriptWithRN = "import Sys\r\nSys.print(\"42\")\r\n"


        var tokensWithN = [Token]()
        var tokensWithRN = [Token]()

        do {
            var lexer = Lexer(script: scriptWithN)
            for _ in 0...10 {
                tokensWithN.append(try lexer.getNextToken())
            }

            lexer = Lexer(script: scriptWithRN)
            for _ in 0...10 {
                tokensWithRN.append(try lexer.getNextToken())
            }
        } catch (_) {
            XCTAssert(false)
        }

        XCTAssertEqual(tokensWithN.count, tokensWithRN.count)
        XCTAssertEqual(tokensWithN[2], Token.lf)
        XCTAssertEqual(tokensWithN[9], Token.lf)
        XCTAssertEqual(tokensWithN[2], tokensWithRN[2])
        XCTAssertEqual(tokensWithN[9], tokensWithRN[9])
        XCTAssertEqual(tokensWithN[10], Token.eof)
        XCTAssertEqual(tokensWithN[10], tokensWithRN[10])
    }
}
