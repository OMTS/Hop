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
    static let allTests = [("testImportStmtParserError", testImportStmtParserError),
                           ("testFunctionStmtParserError", testFunctionStmtParserError),
                           ("testReturnStmtParserError", testReturnStmtParserError),
                           ("testBreakStmtParserError", testBreakStmtParserError),
                           ("testContinueStmtParserError", testContinueStmtParserError),
                           ("testIfStmtParserError", testIfStmtParserError),
                           ("testConstantDeclarationStmtParserError", testConstantDeclarationStmtParserError)]

    var session: Session!
    override func setUp() {
        super.setUp()
        // Setup runtime session
        session = Session(isDebug: true,
                          messenger: nil,
                          getScriptForModule: nil)

    }

    override func tearDown() {
        super.tearDown()
        session = nil
    }

    func testImportStmtParserError() {
        //EXPRESSION ERROR
        let script = "\n\nimport\n\n"
        do {
            try session.run(script: script)
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
                XCTFail("Error Thrown is not a ProgramError")
            }
        }

        //MODULE NOT FOUND
        let script2 = "\n\nimport Syst\n\n"
        do {
            try session.run(script: script2)
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
                XCTFail("Error Thrown is not a ProgramError")
            }
        }

        //LF NOT FOUND
        let script3 = "\n\nimport Sys const a = 3\n\n"
        do {
            try session.run(script: script3)
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
                XCTFail("Error Thrown is not a ProgramError")
            }
        }
    }

    func testFunctionStmtParserError() {
        //PROTOTYPE ERROR
        let script = "\n\nfunc\n\n"
        do {
            try session.run(script: script)
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
                XCTFail("Error Thrown is not a ProgramError")
            }
        }

        //PROTOTYPE ERROR
        let script2 = "\n\nfunc(\n\n"
        do {
            try session.run(script: script2)
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
                XCTFail("Error Thrown is not a ProgramError")
            }
        }

        //PROTOTYPE ERROR
        let script3 = "\n\nfunc if(#n: Int)\n\n"
        do {
            try session.run(script: script3)
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
                XCTFail("Error Thrown is not a ProgramError")
            }
        }

        //PROTOTYPE ERROR
        let script4 = "\n\nfunc test(: Int)\n\n"
        do {
            try session.run(script: script4)
        } catch let error {
            if let printableError = error as? ProgramError {
                guard case ParserError.prototypeError = printableError.errorType else {
                    XCTFail("Should Throw a ParserError.prototypeError but did Throw a \(printableError.errorType)")
                    return
                }
                XCTAssertNotNil(printableError.debugInfo)
                XCTAssertEqual(printableError.debugInfo!.lineNumber,3)
                XCTAssertEqual(printableError.debugInfo!.position,12)
            } else {
                XCTFail("Error Thrown is not a ProgramError")
            }
        }

        //PROTOTYPE ERROR
        let script5 = "\n\nfunc test(n: Int, Int)\n\n"
        do {
            try session.run(script: script5)
        } catch let error {
            if let printableError = error as? ProgramError {
                guard case ParserError.prototypeError = printableError.errorType else {
                    XCTFail("Should Throw a ParserError.prototypeError but did Throw a \(printableError.errorType)")
                    return
                }
                XCTAssertNotNil(printableError.debugInfo)
                XCTAssertEqual(printableError.debugInfo!.lineNumber,3)
                XCTAssertEqual(printableError.debugInfo!.position,23)
            } else {
                XCTFail("Error Thrown is not a ProgramError")
            }
        }

        //PROTOTYPE ERROR
        let script6 = "\n\nfunc test(n: Int\n\n"
        do {
            try session.run(script: script6)
        } catch let error {
            if let printableError = error as? ProgramError {
                guard case ParserError.prototypeError = printableError.errorType else {
                    XCTFail("Should Throw a ParserError.prototypeError but did Throw a \(printableError.errorType)")
                    return
                }
                XCTAssertNotNil(printableError.debugInfo)
                XCTAssertEqual(printableError.debugInfo!.lineNumber,3)
                XCTAssertEqual(printableError.debugInfo!.position,15)
            } else {
                XCTFail("Error Thrown is not a ProgramError")
            }
        }

        //PROTOTYPE ERROR
        let script7 = "\n\nfunc test(n: Int)}\n\n"
        do {
            try session.run(script: script7)
        } catch let error {
            if let printableError = error as? ProgramError {
                guard case ParserError.expressionError = printableError.errorType else {
                    XCTFail("Should Throw a ParserError.expressionError  but did Throw a \(printableError.errorType)")
                    return
                }
                XCTAssertNotNil(printableError.debugInfo)
                XCTAssertEqual(printableError.debugInfo!.lineNumber,3)
                XCTAssertEqual(printableError.debugInfo!.position,19)
            } else {
                XCTFail("Error Thrown is not a ProgramError")
            }
        }
    }

    func testReturnStmtParserError() {
        //EXPRESSION ERROR = WRONG RETURN TYPE
        let script = "\n\nfunc test(s: String) -> String { return 3 }\n\n"
        do {
            try session.run(script: script)
        } catch let error {
            if let printableError = error as? ProgramError {
                guard case ParserError.expressionError = printableError.errorType else {
                    XCTFail("Should Throw a ParserError.expressionError but did Throw a \(printableError.errorType)")
                    return
                }
                XCTAssertNotNil(printableError.debugInfo)
                XCTAssertEqual(printableError.debugInfo!.lineNumber,3)
                XCTAssertEqual(printableError.debugInfo!.position,44)
            } else {
                XCTFail("Error Thrown is not a ProgramError")
            }
        }

        //EXPRESSION ERROR = NO RETURN STMT
        let script2 = "\n\n\n\nimport Sys\nfunc test(s: String) -> String { Sys.print(\"3\")}\n\n"
        do {
            try session.run(script: script2)
        } catch let error {
            if let printableError = error as? ProgramError {
                guard case ParserError.expressionError = printableError.errorType else {
                    XCTFail("Should Throw a ParserError.expressionError but did Throw a \(printableError.errorType)")
                    return
                }
                XCTAssertNotNil(printableError.debugInfo)
                XCTAssertEqual(printableError.debugInfo!.lineNumber,6)
                XCTAssertEqual(printableError.debugInfo!.position,62)
            } else {
                XCTFail("Error Thrown is not a ProgramError")
            }
        }

        //LF NOT FOUND
        let script3 = "\nfunc test(s: String) { \n\n\treturn 2 }\n\n"
        do {
            try session.run(script: script3)
        } catch let error {
            if let printableError = error as? ProgramError {
                guard case ParserError.expressionError = printableError.errorType else {
                    XCTFail("Should Throw a ParserError.expressionError but did Throw a \(printableError.errorType)")
                    return
                }
                XCTAssertNotNil(printableError.debugInfo)
                XCTAssertEqual(printableError.debugInfo!.lineNumber,4)
                XCTAssertEqual(printableError.debugInfo!.position,36)
            } else {
                XCTFail("Error Thrown is not a ProgramError")
            }
        }
    }

    //"break \n"
    func testBreakStmtParserError() {
        let script = "break const a = 3"
        do {
            try session.run(script: script)
        } catch let error {
            if let printableError = error as? ProgramError {
                guard case ParserError.expressionError = printableError.errorType else {
                    XCTFail("Should Throw a ParserError.expressionError but did Throw a \(printableError.errorType)")
                    return
                }
                XCTAssertNotNil(printableError.debugInfo)
                XCTAssertEqual(printableError.debugInfo!.lineNumber,1)
                XCTAssertEqual(printableError.debugInfo!.position,6)
            } else {
                XCTFail("Error Thrown is not a ProgramError")
            }
        }
    }

    //"continue \n"
    func testContinueStmtParserError() {
        let script = "\n\ncontinue const a = 3"
        do {
            try session.run(script: script)
        } catch let error {
            if let printableError = error as? ProgramError {
                guard case ParserError.expressionError = printableError.errorType else {
                    XCTFail("Should Throw a ParserError.expressionError but did Throw a \(printableError.errorType)")
                    return
                }
                XCTAssertNotNil(printableError.debugInfo)
                XCTAssertEqual(printableError.debugInfo!.lineNumber,3)
                XCTAssertEqual(printableError.debugInfo!.position,11)
            } else {
                XCTFail("Error Thrown is not a ProgramError")
            }
        }
    }
    //"if" <expression> "{" <block> "}" ["else" "{" <block> "}"] "\n"

    func testIfStmtParserError() {
        let script = "\nif const a = 3 {\n}\n"
        do {
            try session.run(script: script)
        } catch let error {
            if let printableError = error as? ProgramError {
                guard case ParserError.expressionError = printableError.errorType else {
                    XCTFail("Should Throw a ParserError.expressionError but did Throw a \(printableError.errorType)")
                    return
                }
                XCTAssertNotNil(printableError.debugInfo)
                XCTAssertEqual(printableError.debugInfo!.lineNumber,2)
                XCTAssertEqual(printableError.debugInfo!.position,4)
            } else {
                XCTFail("Error Thrown is not a ProgramError")
            }
        }

        let script2 = "\nif 1 == 3 {\n else {}\n"
        do {
            try session.run(script: script2)
        } catch let error {
            if let printableError = error as? ProgramError {
                guard case ParserError.expressionError = printableError.errorType else {
                    XCTFail("Should Throw a ParserError.expressionError but did Throw a \(printableError.errorType)")
                    return
                }
                XCTAssertNotNil(printableError.debugInfo)
                XCTAssertEqual(printableError.debugInfo!.lineNumber,3)
                XCTAssertEqual(printableError.debugInfo!.position,14)
            } else {
                XCTFail("Error Thrown is not a ProgramError")
            }
        }
    }


    //"const" <id> ":" <id> "=" <expression> "\n"
    func testConstantDeclarationStmtParserError() {
        let script = "\nconst a: String = 3\n"
        do {
            try session.run(script: script)
        } catch let error {
            if let printableError = error as? ProgramError {
                guard case InterpreterError.expressionTypeMismatch = printableError.errorType else {
                    XCTFail("Should Throw a InterpreterError.expressionTypeMismatch but did Throw a \(printableError.errorType)")
                    return
                }
                XCTAssertNotNil(printableError.debugInfo)
                XCTAssertEqual(printableError.debugInfo!.lineNumber,2)
                XCTAssertEqual(printableError.debugInfo!.position,19)
            } else {
                XCTFail("Error Thrown is not a ProgramError")
            }
        }

        let script2 = "\nconst a: String = \n"
        do {
            try session.run(script: script2)
        } catch let error {
            if let printableError = error as? ProgramError {
                guard case InterpreterError.missingConstantInitialization = printableError.errorType else {
                    XCTFail("Should Throw a InterpreterError.missingConstantInitialization but did Throw a \(printableError.errorType)")
                    return
                }
                XCTAssertNotNil(printableError.debugInfo)
                XCTAssertEqual(printableError.debugInfo!.lineNumber,2)
                XCTAssertEqual(printableError.debugInfo!.position,17)
            } else {
                XCTFail("Error Thrown is not a ProgramError")
            }
        }

        let script3 = "\nconst a: String\n"
        do {
            try session.run(script: script3)
        } catch let error {
            if let printableError = error as? ProgramError {
                guard case InterpreterError.missingConstantInitialization = printableError.errorType else {
                    XCTFail("Should Throw a InterpreterError.missingConstantInitialization but did Throw a \(printableError.errorType)")
                    return
                }
                XCTAssertNotNil(printableError.debugInfo)
                XCTAssertEqual(printableError.debugInfo!.lineNumber,2)
                XCTAssertEqual(printableError.debugInfo!.position,10)
            } else {
                XCTFail("Error Thrown is not a ProgramError")
            }
        }

        let script4 = "\nconst a\n"
        do {
            try session.run(script: script4)
        } catch let error {
            if let printableError = error as? ProgramError {
                guard case InterpreterError.missingConstantInitialization = printableError.errorType else {
                    XCTFail("Should Throw a InterpreterError.missingConstantInitialization but did Throw a \(printableError.errorType)")
                    return
                }
                XCTAssertNotNil(printableError.debugInfo)
                XCTAssertEqual(printableError.debugInfo!.lineNumber,2)
                XCTAssertEqual(printableError.debugInfo!.position,7)
            } else {
                XCTFail("Error Thrown is not a ProgramError")
            }
        }
    }

    //"for" <id> "in" <expression> "to" <expression> ["step" <expression>] "{" <block> "}" "\n"
    func testForStmtParserError() {
        let script = "\nfor i: Int in 0 to 10 step 1 {\n}\n"
        do {
            try session.run(script: script)
        } catch let error {
            if let printableError = error as? ProgramError {
                guard case ParserError.expressionError = printableError.errorType else {
                    XCTFail("Should Throw a ParserError.expressionError but did Throw a \(printableError.errorType)")
                    return
                }
                XCTAssertNotNil(printableError.debugInfo)
                XCTAssertEqual(printableError.debugInfo!.lineNumber,2)
                XCTAssertEqual(printableError.debugInfo!.position,6)

            } else {
                XCTFail("Error Thrown is not a ProgramError")
            }
        }

        let script2 = "for i in 5 to \"dummy\" {\n}\n"
        do {
            try session.run(script: script2)
        } catch let error {
            if let printableError = error as? ProgramError {
                guard case InterpreterError.expressionTypeMismatch = printableError.errorType else {
                    XCTFail("Should Throw a InterpreterError.expressionTypeMismatch but did Throw a \(printableError.errorType)")
                    return
                }
                XCTAssertNotNil(printableError.debugInfo)
                XCTAssertEqual(printableError.debugInfo!.lineNumber,1)
                XCTAssertEqual(printableError.debugInfo!.position,16)

            } else {
                XCTFail("Error Thrown is not a ProgramError")
            }
        }
    }
}


