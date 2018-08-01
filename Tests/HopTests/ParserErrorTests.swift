//
//  ParserErrorTests.swift
//  Hop
//
//  Created by Iman Zarrabian on 01/08/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import XCTest
@testable import Hop

class ParserErrorTests: XCTestCase {
    var environment: Environment!
    var interpreter: Interpreter!
    override func setUp() {
        super.setUp()
        environment = Environment(isDebug: true,
                                      messenger: nil,
                                      getScriptForModule: nil)
        interpreter = Interpreter(environment: environment)

    }

    override func tearDown() {
        super.tearDown()
        environment = nil
        interpreter = nil
    }

    func testImportStmtParserError() {
        let script = "\n\nimport\n\nSys"
        do {
            try interpreter.runScript(script)
        } catch let error {
            if let printableError = error as? ProgramPrintableError {
                guard case ParserError.expressionError = printableError.errorType else {
                    XCTFail("Should Throw a ParserError.expressionError but did Throw a \(printableError.errorType)")
                    return
                }
                XCTAssertNotNil(printableError.lineNumber)
                XCTAssertNotNil(printableError.postion)
                XCTAssertEqual(printableError.lineNumber!,3)
                XCTAssertEqual(printableError.postion!,2)
            } else {
                XCTFail("Error Thrown is not a ProgramPrintableError")
            }
        }
    }
}
