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

    static let allTests = [("testCreationFromScript", testCreationFromScript),
                           ("testGetNextTokenForLineFeeds", testGetNextTokenForLineFeeds),
                           ("testGetDebugInfo", testGetDebugInfo),
                           ("testGetLineIndexForPosition",testGetLineIndexForPosition)]

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
        } catch _ {
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

    func testGetDebugInfo() {
        let lexer = Lexer(script: "import Sys\n const a = 42\n", isDebug: true)
        do {
            _ = try lexer.getNextToken() //Consume import

            var debugInfo = lexer.debugInfo //get forst debug Info
            XCTAssertNotNil(debugInfo)
            XCTAssertEqual(debugInfo!.lineNumber, 1)
            XCTAssertEqual(debugInfo!.position,0)

            _ = try lexer.getNextToken() //Consume Sys
            _ = try lexer.getNextToken() //Consume \n
            _ = try lexer.getNextToken() //Consume const


            debugInfo = lexer.debugInfo //get last debug Info
            XCTAssertNotNil(debugInfo)
            XCTAssertEqual(debugInfo!.lineNumber, 2)
            XCTAssertEqual(debugInfo!.position,12)

        } catch _{
            XCTFail("Should not fail")
        }
    }

    func testGetLineIndexForPosition() {
        let lexer = Lexer(script: "\n\nimport\n Sys\n const\n a = 42\n", isDebug: true)
        let lineNumber = lexer.getLineIndex(forCursorPosition: 15) //const position
        XCTAssertEqual(lineNumber, 4)

        let lineNumber2 = lexer.getLineIndex(forCursorPosition: 100) // out of range position
        XCTAssertEqual(lineNumber2, 6) //points to the last line
    }

}
