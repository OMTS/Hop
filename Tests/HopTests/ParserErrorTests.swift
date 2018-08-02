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
        //EXPRESSION ERROR
        let script = "\n\nimport\n\n"
        do {
            try interpreter.runScript(script)
        } catch let error {
            if let printableError = error as? ProgramError {
                guard case ParserError.expressionError = printableError.errorType else {
                    XCTFail("Should Throw a ParserError.expressionError but did Throw a \(printableError.errorType)")
                    return
                }
                XCTAssertNotNil(printableError.debugInfo)
                XCTAssertEqual(printableError.debugInfo!.lineNumber,3)
                XCTAssertEqual(printableError.debugInfo!.position,2)
            } else {
                XCTFail("Error Thrown is not a ProgramPrintableError")
            }
        }

        //MODULE NOT FOUND
        let script2 = "\n\nimport Syst\n\n"
        do {
            try interpreter.runScript(script2)
        } catch let error {
            if let printableError = error as? ProgramError {
                guard case ImporterError.moduleNotFound = printableError.errorType else {
                    XCTFail("Should Throw a ImporterError.ModuleNotFound but did Throw a \(printableError.errorType)")
                    return
                }
                XCTAssertNotNil(printableError.debugInfo)
                XCTAssertEqual(printableError.debugInfo!.lineNumber,3)
                XCTAssertEqual(printableError.debugInfo!.position,9)
            } else {
                XCTFail("Error Thrown is not a ProgramPrintableError")
            }
        }

        //LF NOT FOUND
        let script3 = "\n\nimport Sys const a = 3\n\n"
        do {
            try interpreter.runScript(script3)
        } catch let error {
            if let printableError = error as? ProgramError {
                guard case ParserError.expressionError = printableError.errorType else {
                    XCTFail("Should Throw a ParserError.expressionError but did Throw a \(printableError.errorType)")
                    return
                }
                XCTAssertNotNil(printableError.debugInfo)
                XCTAssertEqual(printableError.debugInfo!.lineNumber,3)
                XCTAssertEqual(printableError.debugInfo!.position,13)
            } else {
                XCTFail("Error Thrown is not a ProgramPrintableError")
            }
        }
    }

    func testFunctionStmtParserError() {
        //PROTOTYPE ERROR
        let script = "\n\nfunc\n\n"
        do {
            try interpreter.runScript(script)
        } catch let error {
            if let printableError = error as? ProgramError {
                guard case ParserError.prototypeError = printableError.errorType else {
                    XCTFail("Should Throw a ParserError.prototypeError but did Throw a \(printableError.errorType)")
                    return
                }
                XCTAssertNotNil(printableError.debugInfo)
                XCTAssertEqual(printableError.debugInfo!.lineNumber,3)
                XCTAssertEqual(printableError.debugInfo!.position,2)
            } else {
                XCTFail("Error Thrown is not a ProgramPrintableError")
            }
        }

        //PROTOTYPE ERROR
        let script2 = "\n\nfunc(\n\n"
        do {
            try interpreter.runScript(script2)
        } catch let error {
            if let printableError = error as? ProgramError {
                guard case ParserError.prototypeError = printableError.errorType else {
                    XCTFail("Should Throw a ParserError.prototypeError but did Throw a \(printableError.errorType)")
                    return
                }
                XCTAssertNotNil(printableError.debugInfo)
                XCTAssertEqual(printableError.debugInfo!.lineNumber,3)
                XCTAssertEqual(printableError.debugInfo!.position,6)
            } else {
                XCTFail("Error Thrown is not a ProgramPrintableError")
            }
        }

        //PROTOTYPE ERROR
        let script3 = "\n\nfunc if(#n: Int)\n\n"
        do {
            try interpreter.runScript(script3)
        } catch let error {
            if let printableError = error as? ProgramError {
                guard case ParserError.prototypeError = printableError.errorType else {
                    XCTFail("Should Throw a ParserError.prototypeError but did Throw a \(printableError.errorType)")
                    return
                }
                XCTAssertNotNil(printableError.debugInfo)
                XCTAssertEqual(printableError.debugInfo!.lineNumber,3)
                XCTAssertEqual(printableError.debugInfo!.position,7)
            } else {
                XCTFail("Error Thrown is not a ProgramPrintableError")
            }
        }

        //PROTOTYPE ERROR
        let script4 = "\n\nfunc test(: Int)\n\n"
        do {
            try interpreter.runScript(script4)
        } catch let error {
            if let printableError = error as? ProgramError {
                /*guard case ParserError.expressionError = printableError.errorType else {
                    XCTFail("Should Throw a ParserError.expressionError but did Throw a \(printableError.errorType)")
                    return
                }*/
                XCTAssertNotNil(printableError.debugInfo)
                XCTAssertEqual(printableError.debugInfo!.lineNumber,3)
                XCTAssertEqual(printableError.debugInfo!.position,12)
            } else {
                XCTFail("Error Thrown is not a ProgramPrintableError")
            }
        }
    }
}
