//
//  ArrayClassTests.swift
//  Hop
//
//  Created by poisson florent on 07/08/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import XCTest
@testable import Hop

class ArrayClassTests: XCTestCase {
    
    static let allTests = [
        ("test_ArrayInitialization_DefaultInitializer", test_ArrayInitialization_DefaultInitializer),
        ("test_ArrayInitialization_ArrayLiteral_NoElements", test_ArrayInitialization_ArrayLiteral_NoElements),
        ("test_ArrayInitialization_ArrayLiteral_NElements", test_ArrayInitialization_ArrayLiteral_NElements),
        ("test_ArrayInitialization_ArrayLiteral_SubArrayLiteral", test_ArrayInitialization_ArrayLiteral_SubArrayLiteral),
        ("test_ArrayElementAccess_Subscript", test_ArrayElementAccess_Subscript),
        ("test_ArrayElementAccess_Subscript_OutOfRange_Bottom", test_ArrayElementAccess_Subscript_OutOfRange_Bottom),
        ("test_ArrayElementAccess_Subscript_OutOfRange_Upper", test_ArrayElementAccess_Subscript_OutOfRange_Upper),
        ("test_ArrayElementAssignment_Subscript", test_ArrayElementAssignment_Subscript),
        ("test_MethodAppendElement_NonNilElement", test_MethodAppendElement_NonNilElement),
        ("test_MethodAppendElement_NilElement", test_MethodAppendElement_NilElement),
        ("test_MethodAppendContent_NonNilArray", test_MethodAppendContent_NonNilArray),
        ("test_MethodAppendContent_NilArray", test_MethodAppendContent_NilArray),
        ("test_MethodSetElementAt_NonNilElement", test_MethodSetElementAt_NonNilElement),
        ("test_MethodSetElementAt_NilElement", test_MethodSetElementAt_NilElement),
        ("test_MethodSetElementAt_IndexOutOfRange_Bottom", test_MethodSetElementAt_IndexOutOfRange_Bottom),
        ("test_MethodSetElementAt_IndexOutOfRange_Upper", test_MethodSetElementAt_IndexOutOfRange_Upper),
        ("test_MethodRemoveAt", test_MethodRemoveAt),
        ("test_MethodRemoveAt_IndexOutOfRange_Bottom", test_MethodRemoveAt_IndexOutOfRange_Bottom),
        ("test_MethodRemoveAt_IndexOutOfRange_Upper", test_MethodRemoveAt_IndexOutOfRange_Upper),
        ("test_MethodRemoveAll", test_MethodRemoveAll),
        ("test_MethodInsertAt", test_MethodInsertAt),
        ("test_MethodInsertAt_TheEnd", test_MethodInsertAt_TheEnd),
        ("test_MethodInsertAt_IndexOutOfRange_Bottom", test_MethodInsertAt_IndexOutOfRange_Bottom),
        ("test_MethodInsertAt_IndexOutOfRange_Upper", test_MethodInsertAt_IndexOutOfRange_Upper),
        ("test_MethodPopFirst_NonEmptyArray", test_MethodPopFirst_NonEmptyArray),
        ("test_MethodPopFirst_EmptyArray", test_MethodPopFirst_EmptyArray),
        ("test_MethodPopLast_NonEmptyArray", test_MethodPopLast_NonEmptyArray),
        ("test_MethodPopLast_EmptyArray", test_MethodPopLast_EmptyArray),
        ("test_MethodFirst_NonEmptyArray", test_MethodFirst_NonEmptyArray),
        ("test_MethodFirst_EmptyArray", test_MethodFirst_EmptyArray),
        ("test_MethodLast_NonEmptyArray", test_MethodLast_NonEmptyArray),
        ("test_MethodLast_EmptyArray", test_MethodLast_EmptyArray),
        ("testMethodElementAt", testMethodElementAt),
        ("testMethodElementAt_IndexOutOfRange_Bottom", testMethodElementAt_IndexOutOfRange_Bottom),
        ("testMethodElementAt_IndexOutOfRange_Upper", testMethodElementAt_IndexOutOfRange_Upper),
        ("testMethodIsEmpty_NonEmptyArray", testMethodIsEmpty_NonEmptyArray),
        ("testMethodIsEmpty_EmptyArray", testMethodIsEmpty_EmptyArray),
        ("testMethodCount_NonEmptyArray", testMethodCount_NonEmptyArray),
        ("testMethodCount_EmptyArray", testMethodCount_EmptyArray),
        ("testMethodShuffled_NonEmptyArray", testMethodShuffled_NonEmptyArray),
        ("testMethodShuffled_EmptyArray", testMethodShuffled_EmptyArray),
        ("testMethodShuffled_VariablesCopying", testMethodShuffled_VariablesCopying),
        ("testMethodReversed_NonEmptyArray", testMethodReversed_NonEmptyArray),
        ("testMethodReversed_EmptyArray", testMethodReversed_EmptyArray),
        ("testMethodReversed_VariablesCopying", testMethodReversed_VariablesCopying)
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

    /**
     
     Note: Hop Array is implemented & encapsulated in a Hop Class.
     
     Array class instance properties:
     
        var __array__: Any // Backend for NSMutableArray instance
     
     Array class methodes:
     
        init() // Default initializer
        func append(#element: Any)
        func append(contentOf: Array)
        func setElement(#element: Any, at: Int)
        func remove(at: <index>)
        func removeAll()
        func insert(#element: Any, at: Int)
        func popFirst() -> Any
        func popLast() -> Any
        func first() -> Any
        func last() -> Any
        func element(at: Int) -> Any
        func isEmpty() -> Bool
        func count() -> Int
        func shuffled() -> Array
        func reversed() -> Array
     
     */
    
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
    
    // Array initialization with default initializer
    func test_ArrayInitialization_DefaultInitializer() {
        // given
        let script = """
        import Test

        const array = Array()

        Test.export(array, label: "array")

        """
        
        // when
        run(script: script)
        
        // then
        let arrayObject = symbolTable["array"]
        
        XCTAssertNotNil(arrayObject, "Error: array variable should not be nil!")
        
        let arrayInstance = arrayObject as? Instance
        
        XCTAssertNotNil(arrayObject, "Error: array instance error!")

        XCTAssertEqual(arrayInstance!.class.type, Type.array, "Error: array type error!")

        let arrayBackendVariable = arrayInstance!.scope.getSymbolValue(for: ArrayClass.backendInstanceHashId) as? Variable
        
        XCTAssertNotNil(arrayBackendVariable, "Error: array backend variable not found!")

        let array = arrayBackendVariable!.value as? NSMutableArray
        
        XCTAssertNotNil(array, "Error: array backend type error!")
    }
    
    // Array initialization with array literal expression with no elements
    func test_ArrayInitialization_ArrayLiteral_NoElements() {
        // given
        let script = """
        import Test

        const array = []

        Test.export(array, label: "array")

        """
        
        // when
        run(script: script)
        
        // then
        let arrayObject = symbolTable["array"]
        
        XCTAssertNotNil(arrayObject, "Error: array variable should not be nil!")
        
        let arrayInstance = arrayObject as? Instance
        
        XCTAssertNotNil(arrayObject, "Error: array instance error!")
        
        XCTAssertEqual(arrayInstance!.class.type, Type.array, "Error: array type error!")
        
        let arrayBackendVariable = arrayInstance!.scope.getSymbolValue(for: ArrayClass.backendInstanceHashId) as? Variable
        
        XCTAssertNotNil(arrayBackendVariable, "Error: array backend variable not found!")
        
        let array = arrayBackendVariable!.value as? NSMutableArray
        
        XCTAssertNotNil(array, "Error: array backend type error!")
    }

    // Array initialization with array literal expression with elements
    func test_ArrayInitialization_ArrayLiteral_NElements() {
        // given
        let script = """
        import Test

        const array = [1, 2.0, true, "Hello world!", Array()]

        Test.export(array, label: "array")

        """
        
        // when
        run(script: script)
        
        // then
        let arrayObject = symbolTable["array"]
        
        XCTAssertNotNil(arrayObject, "Error: array variable should not be nil!")
        
        let arrayInstance = arrayObject as? Instance
        
        XCTAssertNotNil(arrayObject, "Error: array instance error!")
        
        XCTAssertEqual(arrayInstance!.class.type, Type.array, "Error: array type error!")
        
        let arrayBackendVariable = arrayInstance!.scope.getSymbolValue(for: ArrayClass.backendInstanceHashId) as? Variable
        
        XCTAssertNotNil(arrayBackendVariable, "Error: array backend variable not found!")
        
        let array = arrayBackendVariable!.value as? NSMutableArray
        
        XCTAssertNotNil(array, "Error: array backend type error!")
        
        XCTAssertEqual(array!.count, 5, "Error: array size error!")
        
        guard let value0Variable = array![0] as? Variable,
            let value0 = value0Variable.value as? Int,
            value0 == 1 else {
                XCTFail("Error: array content error!")
                return
        }
        
        guard let value1Variable = array![1] as? Variable,
            let value1 = value1Variable.value as? Double,
            value1 == 2.0 else {
                XCTFail("Error: array content error!")
                return
        }
        
        guard let value2Variable = array![2] as? Variable,
            let value2 = value2Variable.value as? Bool,
            value2 == true else {
                XCTFail("Error: array content error!")
                return
        }
        
        guard let value3Variable = array![3] as? Variable,
            let value3 = value3Variable.value as? String,
            value3 == "Hello world!" else {
                XCTFail("Error: array content error!")
                return
        }
        
        guard let value4Variable = array![4] as? Variable,
            let value4 = value4Variable.value as? Instance,
            value4.class.type == .array else {
                XCTFail("Error: array content error!")
                return
        }
    }

    // Array initialization with array literal expression with sub array literals
    func test_ArrayInitialization_ArrayLiteral_SubArrayLiteral() {
        // given
        let script = """
        import Test

        const array = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]

        Test.export(array, label: "array")

        """
        
        // when
        run(script: script)
        
        // then
        let arrayObject = symbolTable["array"]
        
        XCTAssertNotNil(arrayObject, "Error: array variable should not be nil!")
        
        let arrayInstance = arrayObject as? Instance
        
        XCTAssertNotNil(arrayObject, "Error: array instance error!")
        
        XCTAssertEqual(arrayInstance!.class.type, Type.array, "Error: array type error!")
        
        let arrayBackendVariable = arrayInstance!.scope.getSymbolValue(for: ArrayClass.backendInstanceHashId) as? Variable
        
        XCTAssertNotNil(arrayBackendVariable, "Error: array backend variable not found!")
        
        let array = arrayBackendVariable!.value as? NSMutableArray
        
        XCTAssertNotNil(array, "Error: array backend type error!")
        
        XCTAssertEqual(array!.count, 3, "Error: array size error!")
        
        for index in 0..<3 {
            guard let valueVariable = array![index] as? Variable,
                let value = valueVariable.value as? Instance,
                value.class.type == .array,
                let backendArrayVariable = value.scope.getSymbolValue(for: ArrayClass.backendInstanceHashId) as? Variable,
                let array = backendArrayVariable.value as? NSMutableArray,
                array.count == 3 else {
                    XCTFail("Error: array content error at index: \(index)!")
                    return
            }
        }
    }

    // Array element access with subscript
    func test_ArrayElementAccess_Subscript() {
        // given
        let script = """
        import Test

        const array = [1, 2, 3]

        const valueAtIndex0 = array[0]
        const valueAtIndex1 = array[1]
        const valueAtIndex2 = array[2]

        Test.export(valueAtIndex0, label: "valueAtIndex0")
        Test.export(valueAtIndex1, label: "valueAtIndex1")
        Test.export(valueAtIndex2, label: "valueAtIndex2")

        """

        // when
        run(script: script)
        
        // then
        guard let valueAtIndex0 = symbolTable["valueAtIndex0"] as? Int,
            valueAtIndex0 == 1 else {
                XCTFail("Error: array content error!")
                return
        }

        guard let valueAtIndex1 = symbolTable["valueAtIndex1"] as? Int,
            valueAtIndex1 == 2 else {
                XCTFail("Error: array content error!")
                return
        }

        guard let valueAtIndex2 = symbolTable["valueAtIndex2"] as? Int,
            valueAtIndex2 == 3 else {
                XCTFail("Error: array content error!")
                return
        }
    }

    /**
     Array element access with subscript out of range
     
     - index < 0
     
     */
    func test_ArrayElementAccess_Subscript_OutOfRange_Bottom() {
        // given
        let script = """
        import Test

        const array = [1, 2, 3]

        const value = array[-1]

        """
        
        // when & then
        XCTAssertThrowsError(try session.run(script: script)) {
            (error) in
            XCTAssertEqual((error as? ProgramError)?.errorType as? InterpreterError,
                           InterpreterError.subscriptIndexOutOfRange)
        }
    }
    
    /**
     Array element access with subscript out of range
     
     - index >= size
     
    */
    func test_ArrayElementAccess_Subscript_OutOfRange_Upper() {
        // given
        let script = """
        import Test

        const array = [1, 2, 3]

        const value = array[3]

        """
        
        // when & then
        XCTAssertThrowsError(try session.run(script: script)) {
            (error) in
            XCTAssertEqual((error as? ProgramError)?.errorType as? InterpreterError,
                           InterpreterError.subscriptIndexOutOfRange)
        }
    }

    // Array element assignment with subscript
    func test_ArrayElementAssignment_Subscript() {
        // given
        let script = """
        import Test

        const array = [1, 2, 3]

        array[0] = 4
        array[1] = 5
        array[2] = 6

        Test.export(array, label: "array")

        """
        
        // when
        run(script: script)
        
        // then
        // ...
    }

    /**
     Test method func append(#element: Any)
     
     - append non nil element
     
     */
    func test_MethodAppendElement_NonNilElement() {
        // given
        let script = """
        import Test

        const array = [1, 2, 3]

        array.append(4)

        Test.export(array, label: "array")

        """
        
        // when
        run(script: script)

        // then
        // ...
    }

    /**
     Test method func append(#element: Any)
     
     - append nil element
     
     */
    func test_MethodAppendElement_NilElement() {
        // given
        let script = """
        import Test

        const array = [1, 2, 3]
        const value: Int = nil

        array.append(value)

        """
        
        // when
        run(script: script)
        
        // then
        // ...
    }

    /**
     func append(contentOf: Array)
     
     - append non nil array
     
     */
    func test_MethodAppendContent_NonNilArray() {
        // given
        let script = """
        import Test

        const array1 = [1, 2, 3]
        const array2 = [4, 5, 6]

        array1.append(contentOf: array2)

        Test.export(array1, label: "array1")

        """
        
        // when
        run(script: script)
        
        // then
        // ...
    }

    /**
     func append(contentOf: Array)
     
     - append nil array
     
     */
    func test_MethodAppendContent_NilArray() {
        // given
        let script = """
        import Test

        const array1 = [1, 2, 3]
        const array2: Array = nil

        array1.append(contentOf: array2)

        """
        
        // when
        run(script: script)
        
        // then
        // ...
    }

    /**
     func setElement(#element: Any, at: Int)
     
    - replace with non nil element
     
     */
    func test_MethodSetElementAt_NonNilElement() {
        // given
        let script = """
        import Test

        const array = [1, 2, 3]

        array.setElement(4, at: 0)
        array.setElement(5, at: 1)
        array.setElement(6, at: 2)

        Test.export(array, label: "array")

        """
        
        // when
        run(script: script)
        
        // then
        // ...
    }

    /**
     func setElement(#element: Any, at: Int)
     
     - replace with nil element
     
     */
    func test_MethodSetElementAt_NilElement() {
        // given
        let script = """
        import Test

        const array = [1, 2, 3]
        const value: Int = nil

        array.setElement(value, at: 0)

        """
        
        // when
        run(script: script)
        
        // then
        // ...
    }

    /**
     func setElement(#element: Any, at: Int)
     
     - replace with non nil element at index out of range
     
        - index < 0
     
     */
    func test_MethodSetElementAt_IndexOutOfRange_Bottom() {
        // given
        let script = """
        import Test

        const array = [1, 2, 3]

        array.setElement(4, at: -1)

        """
        
        // when & then
        XCTAssertThrowsError(try session.run(script: script)) {
            (error) in
            XCTAssertEqual((error as? ProgramError)?.errorType as? InterpreterError,
                           InterpreterError.subscriptIndexOutOfRange)
        }
    }

    /**
     func setElement(#element: Any, at: Int)
     
     - replace with non nil element at index out of range
     
        - index >= size
     
     */
    func test_MethodSetElementAt_IndexOutOfRange_Upper() {
        // given
        let script = """
        import Test

        const array = [1, 2, 3]

        array.setElement(4, at: 3)

        """
        
        // when & then
        XCTAssertThrowsError(try session.run(script: script)) {
            (error) in
            XCTAssertEqual((error as? ProgramError)?.errorType as? InterpreterError,
                           InterpreterError.subscriptIndexOutOfRange)
        }
    }

    /**
     func remove(at: <index>)
     */
    func test_MethodRemoveAt() {
        // given
        let script = """
        import Test

        const array = [1, 2, 3, 4, 5]

        array.remove(at: 2) // Remove in the middle
        array.remove(at: 3) // remove at the end
        array.remove(at: 0) // remove at the begining

        Test.export(array, label: "array")

        """
        
        // when
        run(script: script)
        
        // then
        // ...
    }

    /**
     func remove(at: <index>)

     - remove at index out of range
     
        - index < 0
     
     */
    func test_MethodRemoveAt_IndexOutOfRange_Bottom() {
        // given
        let script = """
        import Test

        const array = [1, 2, 3]

        array.remove(at: -1)

        """
        
        // when & then
        XCTAssertThrowsError(try session.run(script: script)) {
            (error) in
            XCTAssertEqual((error as? ProgramError)?.errorType as? InterpreterError,
                           InterpreterError.subscriptIndexOutOfRange)
        }
    }
    
    /**
     func remove(at: <index>)
     
     - remove at index out of range
     
     - index >= size
     
     */
    func test_MethodRemoveAt_IndexOutOfRange_Upper() {
        // given
        let script = """
        import Test

        const array = [1, 2, 3]

        array.remove(at: 3)

        """
        
        // when & then
        XCTAssertThrowsError(try session.run(script: script)) {
            (error) in
            XCTAssertEqual((error as? ProgramError)?.errorType as? InterpreterError,
                           InterpreterError.subscriptIndexOutOfRange)
        }
    }
    
    // func removeAll()
    func test_MethodRemoveAll() {
        // given
        let script = """
        import Test

        const array = [1, 2, 3]

        array.removeAll()

        Test.export(array, label: "array")

        """
        
        // when
        run(script: script)
        
        // then
        // ...
    }

    /**
     func insert(#element: Any, at: Int)
     
     - insert at index < (array size - 1)
     
     */
    func test_MethodInsertAt() {
        // given
        let script = """
        import Test

        const array = [1, 3]

        array.insert(2, at: 1)

        Test.export(array, label: "array")

        """
        
        // when
        run(script: script)
        
        // then
        // ...
    }

    /**
     func insert(#element: Any, at: Int)
     
     - insert at index == array size
     
     */
    func test_MethodInsertAt_TheEnd() {
        // given
        let script = """
        import Test

        const array = [1, 2]

        array.insert(3, at: 2)

        Test.export(array, label: "array")

        """
        
        // when
        run(script: script)
        
        // then
        // ...
    }

    /**
     func insert(#element: Any, at: Int)
     
     - insert at index out of range
     
        - index < 0
     
     */
    func test_MethodInsertAt_IndexOutOfRange_Bottom() {
        // given
        let script = """
        import Test

        const array = [1, 2]

        array.insert(3, at: -1)

        """
        
        // when & then
        XCTAssertThrowsError(try session.run(script: script)) {
            (error) in
            XCTAssertEqual((error as? ProgramError)?.errorType as? InterpreterError,
                           InterpreterError.subscriptIndexOutOfRange)
        }
    }
    
    /**
     func insert(#element: Any, at: Int)
     
     - insert at index out of range
     
        - index > size
     
     */
    func test_MethodInsertAt_IndexOutOfRange_Upper() {
        // given
        let script = """
        import Test

        const array = [1, 2]

        array.insert(3, at: 3)

        """

        // when & then
        XCTAssertThrowsError(try session.run(script: script)) {
            (error) in
            XCTAssertEqual((error as? ProgramError)?.errorType as? InterpreterError,
                           InterpreterError.subscriptIndexOutOfRange)
        }
    }

    /**
     func popFirst() -> Any
     
     - pop first element of non empty array
     
     */
    func test_MethodPopFirst_NonEmptyArray() {
        // given
        let script = """
        import Test

        const array = [1, 2]

        const firstValue = array.popFirst()

        Test.export(array, label: "array")
        Test.export(firstValue, label: "firstValue")

        """
        
        // when
        run(script: script)
        
        // then
        // ...
    }

    /**
     func popFirst() -> Any
     
     - pop first element of empty array
     
     */
    func test_MethodPopFirst_EmptyArray() {
        // given
        let script = """
        import Test

        const array = []

        const firstValue = array.popFirst()

        Test.export(array, label: "array")
        Test.export(firstValue, label: "firstValue")

        """
        
        // when
        run(script: script)
        
        // then
        // ...
    }

    /**
     func popLast() -> Any
     
     - pop last element of non empty array
     
     */
    func test_MethodPopLast_NonEmptyArray() {
        // given
        let script = """
        import Test

        const array = [1, 2]

        const lastValue = array.popLast()

        Test.export(array, label: "array")
        Test.export(lastValue, label: "lastValue")

        """
        
        // when
        run(script: script)
        
        // then
        // ...
    }

    /**
     func popLast() -> Any
     
     - pop last element of empty array
     
     */
    func test_MethodPopLast_EmptyArray() {
        // given
        let script = """
        import Test

        const array = []

        const lastValue = array.popLast()

        Test.export(array, label: "array")
        Test.export(lastValue, label: "lastValue")

        """
        
        // when
        run(script: script)
        
        // then
        // ...
    }

    /**
     func first() -> Any
     
     - get first element of non empty array
     
     */
    func test_MethodFirst_NonEmptyArray() {
        // given
        let script = """
        import Test

        const array = [1, 2]

        const firstValue = array.first()

        Test.export(array, label: "array")
        Test.export(firstValue, label: "firstValue")

        """

        // when
        run(script: script)
        
        // then
        // ...
    }

    /**
     func first() -> Any

     - get first element of empty array

     */
    func test_MethodFirst_EmptyArray() {
        // given
        let script = """
        import Test

        const array = []

        const firstValue = array.first()

        Test.export(array, label: "array")
        Test.export(firstValue, label: "firstValue")

        """
        
        // when
        run(script: script)
        
        // then
        // ...
    }

    /**
     func last() -> Any
     
     - get last element of non empty array
     
     */
    func test_MethodLast_NonEmptyArray() {
        // given
        let script = """
        import Test

        const array = [1, 2]

        const lastValue = array.last()

        Test.export(array, label: "array")
        Test.export(lastValue, label: "lastValue")

        """

        // when
        run(script: script)
        
        // then
        // ...
    }

    /**
     func last() -> Any
     
     - get last element of empty array
     
     */
    func test_MethodLast_EmptyArray() {
        // given
        let script = """
        import Test

        const array = []

        const lastValue = array.last()

        Test.export(array, label: "array")
        Test.export(lastValue, label: "lastValue")

        """
        
        // when
        run(script: script)
        
        // then
        // ...
    }

    // func element(at: Int) -> Any
    func testMethodElementAt() {
        // given
        let script = """
        import Test

        const array = [1, 2, 3]

        const valueAtIndex0 = array.element(at: 0)
        const valueAtIndex1 = array.element(at: 1)
        const valueAtIndex2 = array.element(at: 2)

        Test.export(valueAtIndex0, label: "valueAtIndex0")
        Test.export(valueAtIndex1, label: "valueAtIndex1")
        Test.export(valueAtIndex2, label: "valueAtIndex2")

        """
        
        // when
        run(script: script)
        
        // then
        // ...
    }

    /**
     func element(at: Int) -> Any
     
     - get element at index out of range
     
        - index < 0
     
     */
    func testMethodElementAt_IndexOutOfRange_Bottom() {
        // given
        let script = """
        import Test

        const array = [1, 2, 3]

        const value = array.element(at: -1)

        """
        
        // when & then
        XCTAssertThrowsError(try session.run(script: script)) {
            (error) in
            XCTAssertEqual((error as? ProgramError)?.errorType as? InterpreterError,
                           InterpreterError.subscriptIndexOutOfRange)
        }
    }

    /**
     func element(at: Int) -> Any
     
     - get element at index out of range
     
        - index >= size
     
     */
    func testMethodElementAt_IndexOutOfRange_Upper() {
        // given
        let script = """
        import Test

        const array = [1, 2, 3]

        const value = array.element(at: 3)

        """
        
        // when & then
        XCTAssertThrowsError(try session.run(script: script)) {
            (error) in
            XCTAssertEqual((error as? ProgramError)?.errorType as? InterpreterError,
                           InterpreterError.subscriptIndexOutOfRange)
        }
    }

    /**
     func isEmpty() -> Bool
     
     - check emptyness of non empty array
     
     */
    func testMethodIsEmpty_NonEmptyArray() {
        // given
        let script = """
        import Test

        const array = [1, 2, 3]

        Test.export(array.isEmpty(), label: "isEmpty")

        """
        
        // when
        run(script: script)
        
        // then
        guard let isEmpty = symbolTable["isEmpty"] as? Bool,
            isEmpty == false else {
                XCTFail("Error: array should not be considered as empty!")
                return
        }
    }

    /**
     func isEmpty() -> Bool
     
     - check emptyness of empty array

     */
    func testMethodIsEmpty_EmptyArray() {
        // given
        let script = """
        import Test

        const array = []

        Test.export(array.isEmpty(), label: "isEmpty")

        """
        
        // when
        run(script: script)
        
        // then
        guard let isEmpty = symbolTable["isEmpty"] as? Bool,
            isEmpty == true else {
                XCTFail("Error: array should be considered as empty!")
                return
        }
    }

    /**
     func count() -> Int
     
     - get element count of non empty array
     
     */
    func testMethodCount_NonEmptyArray() {
        // given
        let script = """
        import Test

        const array = [1, 2, 3]

        Test.export(array.count(), label: "count")

        """
        
        // when
        run(script: script)
        
        // then
        guard let count = symbolTable["count"] as? Int,
            count == 3 else {
                XCTFail("Error: filled array count error!")
                return
        }
    }

    /**
     func count() -> Int
     
     - get element count of empty array
     
     */
    func testMethodCount_EmptyArray() {
        // given
        let script = """
        import Test

        const array = []

        Test.export(array.count(), label: "count")

        """
        
        // when
        run(script: script)
        
        // then
        guard let count = symbolTable["count"] as? Int,
            count == 0 else {
                XCTFail("Error: empty array count error!")
                return
        }
    }

    /**
     func shuffled() -> Array
     
     - get shuffled copy of non empty array
     
     */
    func testMethodShuffled_NonEmptyArray() {
        // given
        let script = """
        import Test

        const array = [1, 2, 3]
        const shuffledArray = array.shuffled()

        Test.export(shuffledArray, label: "shuffledArray")

        """

        /*
         != 1 2 3
         1 3 2
         2 1 3
         2 3 1
         3 1 2
         3 2 1
        */
        
        // when
        run(script: script)
        
        // then
        // ...
    }

    /**
     func shuffled() -> Array
     
     - get shuffled copy of empty array
     
     */
    func testMethodShuffled_EmptyArray() {
        // given
        let script = """
        import Test

        const array = []
        const shuffledArray = array.shuffled()

        Test.export(shuffledArray, label: "shuffledArray")

        """
        
        // when
        run(script: script)
        
        // then
        // ...
    }

    /**
     func shuffled() -> Array
     
     - check variables copying of shuffled copy
     
     */
    func testMethodShuffled_VariablesCopying() {
        // given
        let script = """
        import Test

        const array = [1, 2, 3]
        const shuffledArray = array.shuffled()
        
        // Set new values in array
        array[0] = 4
        array[1] = 5
        array[2] = 6

        // Shuffled array values should still the same!

        Test.export(shuffledArray, label: "shuffledArray")

        """

        // when
        run(script: script)
        
        // then
        // ...
    }

    /**
     func reversed() -> Array
     
     - get reversed copy of non empty array
     
     */
    func testMethodReversed_NonEmptyArray() {
        // given
        let script = """
        import Test

        const array = [1, 2, 3]
        const reversedArray = array.reversed()

        Test.export(reversedArray, label: "reversedArray")

        """
        
        // when
        run(script: script)
        
        // then
        // ...
    }

    /**
     func reversed() -> Array
     
     - get reversed copy of empty array
     
     */
    func testMethodReversed_EmptyArray() {
        // given
        let script = """
        import Test

        const array = []
        const reversedArray = array.reversed()

        Test.export(reversedArray, label: "reversedArray")

        """
        
        // when
        run(script: script)
        
        // then
        // ...
    }

    /**
     func reversed() -> Array
     
     - check variables copying of reversed copy
     
     */
    func testMethodReversed_VariablesCopying() {
        // given
        let script = """
        import Test

        const array = [1, 2, 3]
        const reversedArray = array.reversed()

        // Set new values in array
        array[0] = 4
        array[1] = 5
        array[2] = 6

        // Shuffled array values should still the same!

        Test.export(reversedArray, label: "reversedArray")

        """
        
        // when
        run(script: script)
        
        // then
        // ...
    }

}
