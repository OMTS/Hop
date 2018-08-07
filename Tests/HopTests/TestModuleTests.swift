//
//  TestModuleTests.swift
//  Hop
//
//  Created by poisson florent on 07/08/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import XCTest
@testable import Hop

class TestModuleTests: XCTestCase {
    
    static let allTests = [
        ("test_importModule", test_importModule),
        ("test_FunctionExportVariable", test_FunctionExportVariable),
        ("test_FunctionExportVariable_NilVariableParameter", test_FunctionExportVariable_NilVariableParameter),
        ("test_FunctionExportVariable_NilLabelParameter", test_FunctionExportVariable_NilLabelParameter)
        
    ]
    
    var session: Session!
    var symbolTable = [String: Any]()
    
    override func setUp() {
        super.setUp()
        
        // Setup export output callback
        let messenger = Messenger()
        messenger.subscribe(to: .export) {
            [weak self] (message) in
            self?.symbolTable[message.identifier!] = message.data
        }
        
        // Setup runtime session
        session = Session(isDebug: true,
                          messenger: messenger,
                          getScriptForModule: nil)
        
    }
    
    override func tearDown() {
        symbolTable.removeAll()
        session = nil
        super.tearDown()
    }
    
    private func run(script: String) {
        do {
            try session.run(script: script)
        } catch let error {
            if let printableError = error as? ProgramError {
                XCTFail("Error: \(printableError.errorType)")
            } else {
                XCTFail("Error Thrown is not a ProgramPrintableError")
            }
        }
    }
    
    // Test import of Test module
    func test_importModule() {
        // given
        
        let script = """
        import Test

        """
        
        // when
        run(script: script)
        
        // then
        let module = session.globalScope.getSymbolValue(for: "Test".hashValue) as? Module
        XCTAssertNotNil(module, "Error: Test module not found in session global scope!")
    }
    
    // Test function func export(#variable: Any, label: String)
    func test_FunctionExportVariable() {
        symbolTable.removeAll()
        
        // given
        
        let script = """
        import Test

        var varInteger = 999
        var varReal = 999.999
        var varBool = true
        var varString = "Hello world!"
        var varArray = []

        const constInteger = 999
        const constReal = 999.999
        const constBool = true
        const constString = "Hello world!"
        const constArray = []

        Test.export(varInteger, label: "varInteger")
        Test.export(varReal, label: "varReal")
        Test.export(varBool, label: "varBool")
        Test.export(varString, label: "varString")
        Test.export(varArray, label: "varArray")
        
        Test.export(constInteger, label: "constInteger")
        Test.export(constReal, label: "constReal")
        Test.export(constBool, label: "constBool")
        Test.export(constString, label: "constString")
        Test.export(constArray, label: "constArray")

        """
        
        // when
        run(script: script)
        
        // then
        let varInteger = symbolTable["varInteger"] as? Int
        XCTAssertNotNil(varInteger, "Error: integer value not exported!")
        
        let varReal = symbolTable["varReal"] as? Double
        XCTAssertNotNil(varReal, "Error: double value not exported!")

        let varBool = symbolTable["varBool"] as? Bool
        XCTAssertNotNil(varBool, "Error: boolean value not exported!")

        let varString = symbolTable["varString"] as? String
        XCTAssertNotNil(varString, "Error: string value not exported!")

        let varArray = symbolTable["varArray"] as? Instance
        XCTAssertNotNil(varArray, "Error: instance not exported!")

        let constInteger = symbolTable["constInteger"] as? Int
        XCTAssertNotNil(constInteger, "Error: integer value not exported!")

        let constReal = symbolTable["constReal"] as? Double
        XCTAssertNotNil(constReal, "Error: double value not exported!")

        let constBool = symbolTable["constBool"] as? Bool
        XCTAssertNotNil(constBool, "Error: boolean value not exported!")

        let constString = symbolTable["constString"] as? String
        XCTAssertNotNil(constString, "Error: string value not exported!")

        let constArray = symbolTable["constArray"] as? Instance
        XCTAssertNotNil(constArray, "Error: instance not exported!")
    }
    
    /**
     Test function func export(#variable: Any, label: String)
     
        - with nil variable parameter
     
     */
    func test_FunctionExportVariable_NilVariableParameter() {
        symbolTable.removeAll()
        
        let script = """
        import Test

        var variable: Int = nil

        Test.export(variable, label: "variable")

        """
        
        XCTAssertThrowsError(try session.run(script: script)) {
            (error) in
            XCTAssertEqual((error as? ProgramError)?.errorType as? InterpreterError,
                           InterpreterError.nativeFunctionCallParameterError)
        }
        
        // Test added as long as nil management won't be unit tested
        let script2 = """
        import Test

        Test.export(nil, label: "")

        """
        
        XCTAssertThrowsError(try session.run(script: script2)) {
            (error) in
            XCTAssertEqual((error as? ProgramError)?.errorType as? InterpreterError,
                           InterpreterError.nativeFunctionCallParameterError)
        }

        // Test added as long as nil management won't be unit tested
        let script3 = """
        import Test

        var variable: Any = nil

        Test.export(variable, label: "variable")

        """
        
        XCTAssertThrowsError(try session.run(script: script3)) {
            (error) in
            XCTAssertEqual((error as? ProgramError)?.errorType as? InterpreterError,
                           InterpreterError.nativeFunctionCallParameterError)
        }
    }
    
    /**
     Test function func export(#variable: Any, label: String)
     
     - with nil label parameter
     
     */
    func test_FunctionExportVariable_NilLabelParameter() {
        symbolTable.removeAll()
        
        let script = """
        import Test

        var variable = "a value to watch..."
        var label: String = nil

        Test.export(variable, label: label)

        """
        
        XCTAssertThrowsError(try session.run(script: script)) {
            (error) in
            XCTAssertEqual((error as? ProgramError)?.errorType as? InterpreterError,
                           InterpreterError.nativeFunctionCallParameterError)
        }
        
        // Test added as long as nil management won't be unit tested
        let script2 = """
        import Test

        var variable = "a value to watch..."

        Test.export(variable, label: nil)

        """
        
        XCTAssertThrowsError(try session.run(script: script2)) {
            (error) in
            XCTAssertEqual((error as? ProgramError)?.errorType as? InterpreterError,
                           InterpreterError.nativeFunctionCallParameterError)
        }
    }
    
}
