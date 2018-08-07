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
        ("test_ArrayElementAccess_Subscript_OutOfRange", test_ArrayElementAccess_Subscript_OutOfRange),
        ("test_ArrayElementAssignment_Subscript", test_ArrayElementAssignment_Subscript),
        ("test_MethodAppendElement_NonNilElement", test_MethodAppendElement_NonNilElement),
        ("test_MethodAppendElement_NilElement", test_MethodAppendElement_NilElement),
        ("test_MethodAppendContent_NonNilArray", test_MethodAppendContent_NonNilArray),
        ("test_MethodAppendContent_NilArray", test_MethodAppendContent_NilArray),
        ("test_MethodSetElementAt_NonNilElement", test_MethodSetElementAt_NonNilElement),
        ("test_MethodSetElementAt_NilElement", test_MethodSetElementAt_NilElement),
        ("test_MethodSetElementAt_IndexOutOfRange", test_MethodSetElementAt_IndexOutOfRange),
        ("test_MethodRemoveAt", test_MethodRemoveAt),
        ("test_MethodRemoveAt_IndexOutOfRange", test_MethodRemoveAt_IndexOutOfRange),
        ("test_MethodRemoveAll", test_MethodRemoveAll),
        ("test_MethodInsertAt", test_MethodInsertAt),
        ("test_MethodInsertAt_TheEnd", test_MethodInsertAt_TheEnd),
        ("test_MethodInsertAt_IndexOutOfRange", test_MethodInsertAt_IndexOutOfRange),
        ("test_MethodPopFirst_NonEmptyArray", test_MethodPopFirst_NonEmptyArray),
        ("test_MethodPopFirst_EmptyArray", test_MethodPopFirst_EmptyArray),
        ("test_MethodPopLast_NonEmptyArray", test_MethodPopLast_NonEmptyArray),
        ("test_MethodPopLast_EmptyArray", test_MethodPopLast_EmptyArray),
        ("test_MethodFirst_NonEmptyArray", test_MethodFirst_NonEmptyArray),
        ("test_MethodFirst_EmptyArray", test_MethodFirst_EmptyArray),
        ("test_MethodLast_NonEmptyArray", test_MethodLast_NonEmptyArray),
        ("test_MethodLast_EmptyArray", test_MethodLast_EmptyArray),
        ("testMethodElementAt", testMethodElementAt),
        ("testMethodElementAt_IndexOutOfRange", testMethodElementAt_IndexOutOfRange),
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
        symbolTable.removeAll()
        
        // given
        
        let script = """
        import Test

        const array = Array()

        Test.export(a, label: "array")

        """
        
        // when
        run(script: script)
        
        // then
        if let arrayObject = symbolTable["array"] {
            if let arrayInstance = arrayObject as? Instance {
                if arrayInstance.class.type == .array {
                    if let arrayBackendVariable = arrayInstance.scope.getSymbolValue(for: ArrayClass.backendInstanceHashId) as? Variable {
                        if let array = arrayBackendVariable.value as? NSMutableArray {
                            
                        } else {
                            
                        }
                    } else {
                        
                    }
                } else {
                    
                }
            } else {
                
            }
        } else {
            
        }
    }
    
    // Array initialization with array literal expression with no elements
    func test_ArrayInitialization_ArrayLiteral_NoElements() {
        symbolTable.removeAll()
        
        // given
        // ...
        
        // when
        // ...
        
        // then
        // ...
    }

    // Array initialization with array literal expression with elements
    func test_ArrayInitialization_ArrayLiteral_NElements() {
        symbolTable.removeAll()
        
        // given
        // ...
        
        // when
        // ...
        
        // then
        // ...
    }

    // Array initialization with array literal expression with sub array literals
    func test_ArrayInitialization_ArrayLiteral_SubArrayLiteral() {
        symbolTable.removeAll()
        
        // given
        // ...
        
        // when
        // ...
        
        // then
        // ...
    }

    // Array element access with subscript
    func test_ArrayElementAccess_Subscript() {
        symbolTable.removeAll()
        
        // given
        // ...
        
        // when
        // ...
        
        // then
        // ...
    }

    // Array element access with subscript out of range
    func test_ArrayElementAccess_Subscript_OutOfRange() {
        symbolTable.removeAll()
        
        // given
        // ...
        
        // when
        // ...
        
        // then
        // ...
    }

    // Array element assignment with subscript
    func test_ArrayElementAssignment_Subscript() {
        symbolTable.removeAll()
        
        // given
        // ...
        
        // when
        // ...
        
        // then
        // ...
    }

    /**
     Test method func append(#element: Any)
     
     - append non nil element
     
     */
    func test_MethodAppendElement_NonNilElement() {
        symbolTable.removeAll()

        // given
        // ...
        
        // when
        // ...
        
        // then
        // ...
    }

    /**
     Test method func append(#element: Any)
     
     - append nil element
     
     */
    func test_MethodAppendElement_NilElement() {
        symbolTable.removeAll()

        // given
        // ...
        
        // when
        // ...
        
        // then
        // ...
    }

    /**
     func append(contentOf: Array)
     
     - append non nil array
     
     */
    func test_MethodAppendContent_NonNilArray() {
        symbolTable.removeAll()

        // given
        // ...
        
        // when
        // ...
        
        // then
        // ...
    }

    /**
     func append(contentOf: Array)
     
     - append nil array
     
     */
    func test_MethodAppendContent_NilArray() {
        symbolTable.removeAll()

        // given
        // ...
        
        // when
        // ...
        
        // then
        // ...
    }

    /**
     func setElement(#element: Any, at: Int)
     
    - replace with non nil element
     
     */
    func test_MethodSetElementAt_NonNilElement() {
        symbolTable.removeAll()

        // given
        // ...
        
        // when
        // ...
        
        // then
        // ...
    }

    /**
     func setElement(#element: Any, at: Int)
     
     - replace with nil element
     
     */
    func test_MethodSetElementAt_NilElement() {
        symbolTable.removeAll()

        // given
        // ...
        
        // when
        // ...
        
        // then
        // ...
    }

    /**
     func setElement(#element: Any, at: Int)
     
     - replace with non nil element at index out of range
     
     */
    func test_MethodSetElementAt_IndexOutOfRange() {
        symbolTable.removeAll()

        // given
        // ...
        
        // when
        // ...
        
        // then
        // ...
    }

    /**
     func remove(at: <index>)
     */
    func test_MethodRemoveAt() {
        symbolTable.removeAll()

        // given
        // ...
        
        // when
        // ...
        
        // then
        // ...
    }

    /**
     func remove(at: <index>)

     - remove at index out of range
     
     */
    func test_MethodRemoveAt_IndexOutOfRange() {
        symbolTable.removeAll()

        // given
        // ...
        
        // when
        // ...
        
        // then
        // ...
    }
    
    // func removeAll()
    func test_MethodRemoveAll() {
        symbolTable.removeAll()

        // given
        // ...
        
        // when
        // ...
        
        // then
        // ...
    }

    /**
     func insert(#element: Any, at: Int)
     
     - insert at index < (array size - 1)
     
     */
    func test_MethodInsertAt() {
        symbolTable.removeAll()

        // given
        // ...
        
        // when
        // ...
        
        // then
        // ...
    }

    /**
     func insert(#element: Any, at: Int)
     
     - insert at index == array size
     
     */
    func test_MethodInsertAt_TheEnd() {
        symbolTable.removeAll()

        // given
        // ...
        
        // when
        // ...
        
        // then
        // ...
    }

    /**
     func insert(#element: Any, at: Int)
     
     - insert at index out of range (i.e. index < 0 || index > size array)
     
     */
    func test_MethodInsertAt_IndexOutOfRange() {
        symbolTable.removeAll()

        // given
        // ...
        
        // when
        // ...
        
        // then
        // ...
    }

    /**
     func popFirst() -> Any
     
     - pop first element of non empty array
     
     */
    func test_MethodPopFirst_NonEmptyArray() {
        symbolTable.removeAll()

        // given
        // ...
        
        // when
        // ...
        
        // then
        // ...
    }

    /**
     func popFirst() -> Any
     
     - pop first element of empty array
     
     */
    func test_MethodPopFirst_EmptyArray() {
        symbolTable.removeAll()

        // given
        // ...
        
        // when
        // ...
        
        // then
        // ...
    }

    /**
     func popLast() -> Any
     
     - pop last element of non empty array
     
     */
    func test_MethodPopLast_NonEmptyArray() {
        symbolTable.removeAll()

        // given
        // ...
        
        // when
        // ...
        
        // then
        // ...
    }

    /**
     func popLast() -> Any
     
     - pop last element of empty array
     
     */
    func test_MethodPopLast_EmptyArray() {
        symbolTable.removeAll()

        // given
        // ...
        
        // when
        // ...
        
        // then
        // ...
    }

    /**
     func first() -> Any
     
     - get first element of non empty array
     
     */
    func test_MethodFirst_NonEmptyArray() {
        symbolTable.removeAll()

        // given
        // ...
        
        // when
        // ...
        
        // then
        // ...
    }

    /**
     func first() -> Any

     - get first element of empty array

     */
    func test_MethodFirst_EmptyArray() {
        symbolTable.removeAll()

        // given
        // ...
        
        // when
        // ...
        
        // then
        // ...
    }

    /**
     func last() -> Any
     
     - get last element of non empty array
     
     */
    func test_MethodLast_NonEmptyArray() {
        symbolTable.removeAll()

        // given
        // ...
        
        // when
        // ...
        
        // then
        // ...
    }

    /**
     func last() -> Any
     
     - get last element of empty array
     
     */
    func test_MethodLast_EmptyArray() {
        symbolTable.removeAll()

        // given
        // ...
        
        // when
        // ...
        
        // then
        // ...
    }

    // func element(at: Int) -> Any
    func testMethodElementAt() {
        symbolTable.removeAll()

        // given
        // ...
        
        // when
        // ...
        
        // then
        // ...
    }

    /**
     func element(at: Int) -> Any
     
     - get element at index out of range
     
     */
    func testMethodElementAt_IndexOutOfRange() {
        symbolTable.removeAll()

        // given
        // ...
        
        // when
        // ...
        
        // then
        // ...
    }

    /**
     func isEmpty() -> Bool
     
     - check emptyness of non empty array
     
     */
    func testMethodIsEmpty_NonEmptyArray() {
        symbolTable.removeAll()

        // given
        // ...
        
        // when
        // ...
        
        // then
        // ...
    }

    /**
     func isEmpty() -> Bool
     
     - check emptyness of empty array

     */
    func testMethodIsEmpty_EmptyArray() {
        symbolTable.removeAll()

        // given
        // ...
        
        // when
        // ...
        
        // then
        // ...
    }

    /**
     func count() -> Int
     
     - get element count of non empty array
     
     */
    func testMethodCount_NonEmptyArray() {
        symbolTable.removeAll()

        // given
        // ...
        
        // when
        // ...
        
        // then
        // ...
    }

    /**
     func count() -> Int
     
     - get element count of empty array
     
     */
    func testMethodCount_EmptyArray() {
        symbolTable.removeAll()

        // given
        // ...
        
        // when
        // ...
        
        // then
        // ...
    }

    /**
     func shuffled() -> Array
     
     - get shuffled copy of non empty array
     
     */
    func testMethodShuffled_NonEmptyArray() {
        symbolTable.removeAll()

        // given
        // ...
        
        // when
        // ...
        
        // then
        // ...
    }

    /**
     func shuffled() -> Array
     
     - get shuffled copy of empty array
     
     */
    func testMethodShuffled_EmptyArray() {
        symbolTable.removeAll()

        // given
        // ...
        
        // when
        // ...
        
        // then
        // ...
    }

    /**
     func shuffled() -> Array
     
     - check variables copying of shuffled copy
     
     */
    func testMethodShuffled_VariablesCopying() {
        symbolTable.removeAll()

        // given
        // ...
        
        // when
        // ...
        
        // then
        // ...
    }

    /**
     func reversed() -> Array
     
     - get reversed copy of non empty array
     
     */
    func testMethodReversed_NonEmptyArray() {
        symbolTable.removeAll()

        // given
        // ...
        
        // when
        // ...
        
        // then
        // ...
    }

    /**
     func reversed() -> Array
     
     - get reversed copy of empty array
     
     */
    func testMethodReversed_EmptyArray() {
        symbolTable.removeAll()

        // given
        // ...
        
        // when
        // ...
        
        // then
        // ...
    }

    /**
     func reversed() -> Array
     
     - check variables copying of reversed copy
     
     */
    func testMethodReversed_VariablesCopying() {
        symbolTable.removeAll()

        // given
        // ...
        
        // when
        // ...
        
        // then
        // ...
    }

}
