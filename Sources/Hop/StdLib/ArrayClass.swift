//
//  ArrayClass.swift
//  Hop iOS
//
//  Created by poisson florent on 06/08/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

struct ArrayClass {

    static let name = "Array"
    static let backendInstanceName = "__array__"
    static let backendInstanceHashId = backendInstanceName.hashValue

    static func importClass(in context: Scope) {
        
        let classScope = Scope(parent: context)
        
        // Instance private property '__array__'
        let privateArrayDeclaration = VariableDeclarationStmt(name: backendInstanceName,
                                                              typeExpr: IdentifierExpr(name: Type.any.name),
                                                              isConstant: false,
                                                              isPrivate: true,  // TODO: implement flag checking at assignment
            expr: nil)
        
        // Instance methods & init/deinit
        // ------------------------------
        
        let selfArgument = Argument(name: SelfParameter.name,
                                    type: Type(name: name),
                                    isAnonymous: false)
        
        // Default initializer: Array()
        computeInitializer(in: classScope,
                           selfArgument: selfArgument)
        
        // method:  func append(#element: Any)
        computeMethodAppendElement(in: classScope,
                                   selfArgument: selfArgument)
        
        // method:  func append(contentOf: Array)
        computeMethodAppendContent(in: classScope,
                                   selfArgument: selfArgument)
        
        // method:  func setElement(#element: Any, at: Int)
        computeMethodSetElementAt(in: classScope,
                                  selfArgument: selfArgument)
        
        // method:  func remove(at: <index>)
        computeMethodRemoveAt(in: classScope,
                              selfArgument: selfArgument)
        
        // method:  func insert(#element: Any, at: Int)
        computeMethodInsertAt(in: classScope,
                              selfArgument: selfArgument)
        
        // method:  func popFirst()
        
        // method:  func popLast()
        
        // method:  func first()
        computeMethodFirst(in: classScope,
                           selfArgument: selfArgument)
        
        // method:  func last()
        computeMethodLast(in: classScope,
                          selfArgument: selfArgument)

        // method:  func element(at: Int)
        computeMethodElementAt(in: classScope,
                               selfArgument: selfArgument)
        
        // method:  func isEmpty()
        computeMethodIsEmpty(in: classScope,
                             selfArgument: selfArgument)
        
        // method:  func count()
        computeMethodCount(in: classScope,
                           selfArgument: selfArgument)
        
        // method:  func shuffled()
        
        // method:  func reversed()
        
        context.symbolTable[name.hashValue] = Class(name: name,
                                                    superclass: nil,
                                                    instancePropertyDeclarations: [privateArrayDeclaration],
                                                    scope: classScope)
    }

    // Default initializer: Array()
    private static func computeInitializer(in classScope: Scope,
                                    selfArgument: Argument) {
        // Array initialization
        // --------------------
        // 'self.__array__ = <Array Variable>
        let arrayExpr = BinaryOperatorExpr(binOp: .dot,
                                           lhs: IdentifierExpr(name: SelfParameter.name),
                                           rhs: IdentifierExpr(name: backendInstanceName))
        
        // Native function call expression for instanstiating swift array
        let nativeArrayExpr = NativeFunctionCallExpr(arguments: nil, evaluation: { (_, _) -> Variable? in
            return Variable(type: .any, isConstant: true, value: NSMutableArray())
        }) {
            return Type.any
        }
        
        let arrayAssignmentExpr = BinaryOperatorExpr(binOp: .assignment,
                                                     lhs: arrayExpr,
                                                     rhs: nativeArrayExpr)
        let arrayAssignmentStmt = ExpressionStmt(expr: arrayAssignmentExpr)
        
        // Fill block statement
        let blockStmt = BlockStmt(statements: [arrayAssignmentStmt])
        
        // Get prototype
        let prototype = Prototype(name: ClassInitializer.name,
                                  arguments: [selfArgument],
                                  type: .void)
        
        // Set closure in class scope
        classScope.symbolTable[prototype.hashId] = Closure(prototype: prototype,
                                                           block: blockStmt,
                                                           declarationScope: classScope)
    }

    // method:  func append(#element: Any)
    private static func computeMethodAppendElement(in classScope: Scope,
                                            selfArgument: Argument) {
        // Prototype
        // ---------
        let elementArgument = Argument(name: "element", type: .any, isAnonymous: true)
        let prototype = Prototype(name: "append",
                                  arguments: [selfArgument, elementArgument],
                                  type: .void)
        
        let closure = getNativeFunctionClosure(prototype: prototype, declarationScope: classScope) {
            (arguments, _) in
            
            // Self argument
            guard let selfInstance = arguments?[0].value as? Instance,
                let elementVariable = arguments?[1] else {
                    throw ProgramError(errorType: InterpreterError.nativeFunctionCallParameterError, debugInfo: nil)
            }
            
            guard let arrayVariable = selfInstance.scope.getSymbolValue(for: backendInstanceHashId) as? Variable,
                let array = arrayVariable.value as? NSMutableArray else {
                    throw ProgramError(errorType: InterpreterError.expressionEvaluationError, debugInfo: nil)
            }
            
            let newElementVariable = elementVariable.copy()
            // Type mutability is allowed to container variable,
            // as container variables are reused by assignment
            // and must accept any types assignment.
            newElementVariable.isTypeMutabilityAllowed = true
            newElementVariable.isConstant = false
            array.add(newElementVariable)
            
            return nil
        }
        
        // Set closure in class scope
        classScope.symbolTable[prototype.hashId] = closure
    }

    // method:  func append(contentOf: Array)
    private static func computeMethodAppendContent(in classScope: Scope,
                                                   selfArgument: Argument) {
        // Prototype
        // ---------
        let contentArgument = Argument(name: "contentOf", type: .any, isAnonymous: false)
        let prototype = Prototype(name: "append",
                                  arguments: [selfArgument, contentArgument],
                                  type: .void)
        
        let closure = getNativeFunctionClosure(prototype: prototype, declarationScope: classScope) {
            (arguments, _) in
            
            // Self argument
            guard let selfInstance = arguments?[0].value as? Instance,
                let contentVariable = arguments?[1].value as? Instance,
                contentVariable.class.type == .array else {
                    throw ProgramError(errorType: InterpreterError.nativeFunctionCallParameterError, debugInfo: nil)
            }
            
            guard let arrayVariable = selfInstance.scope.getSymbolValue(for: backendInstanceHashId) as? Variable,
                let array = arrayVariable.value as? NSMutableArray else {
                    throw ProgramError(errorType: InterpreterError.expressionEvaluationError, debugInfo: nil)
            }

            guard let contentArrayVariable = contentVariable.scope.getSymbolValue(for: backendInstanceHashId) as? Variable,
                let contentArray = contentArrayVariable.value as? NSMutableArray else {
                    throw ProgramError(errorType: InterpreterError.expressionEvaluationError, debugInfo: nil)
            }

            var newElements = [Variable]()
            for element in contentArray {
                let elementVariable = element as! Variable
                let newElementVariable = elementVariable.copy()
                // Type mutability is allowed to container variable,
                // as container variables are reused by assignment
                // and must accept any types assignment.
                newElementVariable.isTypeMutabilityAllowed = true
                newElementVariable.isConstant = false
                newElements.append(newElementVariable)
            }
            
            if !newElements.isEmpty {
                array.addObjects(from: newElements)
            }

            return nil
        }
        
        // Set closure in class scope
        classScope.symbolTable[prototype.hashId] = closure
    }
    
    // method:  func setElement(#element: Any, at: Int)
    private static func computeMethodSetElementAt(in classScope: Scope,
                                           selfArgument: Argument) {
        // Prototype
        // ---------
        let elementArgument = Argument(name: "element", type: .any, isAnonymous: true)
        let indexArgument = Argument(name: "at", type: .any, isAnonymous: false)
        let prototype = Prototype(name: "setElement",
                                  arguments: [
                                    selfArgument,
                                    elementArgument,
                                    indexArgument],
                                  type: .void)
        
        let closure = getNativeFunctionClosure(prototype: prototype, declarationScope: classScope) {
            (arguments, _) in
            
            // Self argument
            guard let selfInstance = arguments?[0].value as? Instance,
                let elementVariable = arguments?[1],
                let index = arguments?[2].value as? Int else {
                    throw ProgramError(errorType: InterpreterError.nativeFunctionCallParameterError, debugInfo: nil)
            }
            
            guard let arrayVariable = selfInstance.scope.getSymbolValue(for: backendInstanceHashId) as? Variable,
                let array = arrayVariable.value as? NSMutableArray else {
                    throw ProgramError(errorType: InterpreterError.expressionEvaluationError, debugInfo: nil)
            }

            guard index >= 0 && index < array.count else {
                throw ProgramError(errorType: InterpreterError.subscriptIndexOutOfRange,
                                   debugInfo: nil)
            }

            let newElementVariable = elementVariable.copy()
            // Type mutability is allowed to container variable,
            // as container variables are reused by assignment
            // and must accept any types assignment.
            newElementVariable.isTypeMutabilityAllowed = true
            newElementVariable.isConstant = false
            
            array.replaceObject(at: index,
                                with: newElementVariable)
            
            return nil
        }
        
        // Set closure in class scope
        classScope.symbolTable[prototype.hashId] = closure
    }

    // method:  func remove(at: <index>)
    private static func computeMethodRemoveAt(in classScope: Scope,
                                       selfArgument: Argument) {
        // Prototype
        // ---------
        let indexArgument = Argument(name: "at", type: .any, isAnonymous: false)
        let prototype = Prototype(name: "remove",
                                  arguments: [
                                    selfArgument,
                                    indexArgument],
                                  type: .void)
        
        let closure = getNativeFunctionClosure(prototype: prototype, declarationScope: classScope) {
            (arguments, _) in
            
            // Self argument
            guard let selfInstance = arguments?[0].value as? Instance,
                let index = arguments?[1].value as? Int else {
                    throw ProgramError(errorType: InterpreterError.nativeFunctionCallParameterError, debugInfo: nil)
            }
            
            guard let arrayVariable = selfInstance.scope.getSymbolValue(for: backendInstanceHashId) as? Variable,
                let array = arrayVariable.value as? NSMutableArray else {
                    throw ProgramError(errorType: InterpreterError.expressionEvaluationError, debugInfo: nil)
            }
            
            guard index >= 0 && index < array.count else {
                throw ProgramError(errorType: InterpreterError.subscriptIndexOutOfRange,
                                   debugInfo: nil)
            }
            
            array.removeObject(at: index)
            
            return nil
        }
        
        // Set closure in class scope
        classScope.symbolTable[prototype.hashId] = closure
    }

    // method:  func insert(#element: Any, at: Int)
    private static func computeMethodInsertAt(in classScope: Scope,
                                       selfArgument: Argument) {
        // Prototype
        // ---------
        let elementArgument = Argument(name: "element", type: .any, isAnonymous: true)
        let indexArgument = Argument(name: "at", type: .any, isAnonymous: false)
        let prototype = Prototype(name: "insert",
                                  arguments: [
                                    selfArgument,
                                    elementArgument,
                                    indexArgument],
                                  type: .void)
        
        let closure = getNativeFunctionClosure(prototype: prototype, declarationScope: classScope) {
            (arguments, _) in
            
            // Self argument
            guard let selfInstance = arguments?[0].value as? Instance,
                let elementVariable = arguments?[1],
                let index = arguments?[2].value as? Int else {
                    throw ProgramError(errorType: InterpreterError.nativeFunctionCallParameterError, debugInfo: nil)
            }
            
            guard let arrayVariable = selfInstance.scope.getSymbolValue(for: backendInstanceHashId) as? Variable,
                let array = arrayVariable.value as? NSMutableArray else {
                    throw ProgramError(errorType: InterpreterError.expressionEvaluationError, debugInfo: nil)
            }
            
            guard index >= 0 && index < array.count + 1 else {
                throw ProgramError(errorType: InterpreterError.subscriptIndexOutOfRange,
                                   debugInfo: nil)
            }
            
            let newElementVariable = elementVariable.copy()
            // Type mutability is allowed to container variable,
            // as container variables are reused by assignment
            // and must accept any types assignment.
            newElementVariable.isTypeMutabilityAllowed = true
            newElementVariable.isConstant = false
            
            array.insert(newElementVariable, at: index)
            
            return nil
        }
        
        // Set closure in class scope
        classScope.symbolTable[prototype.hashId] = closure
    }

    // method:  func popFirst()
    private static func computeMethodPopFirst(in classScope: Scope,
                                       selfArgument: Argument) {
        
    }

    // method:  func popLast()
    private static func computeMethodPopLast(in classScope: Scope,
                                      selfArgument: Argument) {
        
    }

    // method:  func first()
    private static func computeMethodFirst(in classScope: Scope,
                                           selfArgument: Argument) {
        // Prototype
        // ---------
        let prototype = Prototype(name: "first",
                                  arguments: [selfArgument],
                                  type: .any)
        
        let closure = getNativeFunctionClosure(prototype: prototype, declarationScope: classScope) {
            (arguments, _) in
            
            // Self argument
            guard let selfInstance = arguments?[0].value as? Instance else {
                throw ProgramError(errorType: InterpreterError.nativeFunctionCallParameterError, debugInfo: nil)
            }
            
            guard let arrayVariable = selfInstance.scope.getSymbolValue(for: backendInstanceHashId) as? Variable,
                let array = arrayVariable.value as? NSMutableArray else {
                    throw ProgramError(errorType: InterpreterError.expressionEvaluationError, debugInfo: nil)
            }

            if let firstElementVariable = array.firstObject as? Variable {
                return firstElementVariable.copy()
            }
            
            return NilExpr.nilVariable
        }
        
        // Set closure in class scope
        classScope.symbolTable[prototype.hashId] = closure
    }

    // method:  func last()
    private static func computeMethodLast(in classScope: Scope,
                                          selfArgument: Argument) {
        // Prototype
        // ---------
        let prototype = Prototype(name: "last",
                                  arguments: [selfArgument],
                                  type: .any)
        
        let closure = getNativeFunctionClosure(prototype: prototype, declarationScope: classScope) {
            (arguments, _) in
            
            // Self argument
            guard let selfInstance = arguments?[0].value as? Instance else {
                throw ProgramError(errorType: InterpreterError.nativeFunctionCallParameterError, debugInfo: nil)
            }
            
            guard let arrayVariable = selfInstance.scope.getSymbolValue(for: backendInstanceHashId) as? Variable,
                let array = arrayVariable.value as? NSMutableArray else {
                    throw ProgramError(errorType: InterpreterError.expressionEvaluationError, debugInfo: nil)
            }
            
            if let lastElementVariable = array.lastObject as? Variable {
                return lastElementVariable.copy()
            }
            
            return NilExpr.nilVariable
        }
        
        // Set closure in class scope
        classScope.symbolTable[prototype.hashId] = closure
    }

    // method:  func element(at: Int)
    private static func computeMethodElementAt(in classScope: Scope,
                                        selfArgument: Argument) {
        // Prototype
        // ---------
        let atArgument = Argument(name: "at", type: .integer, isAnonymous: false)
        let prototype = Prototype(name: "element",
                                  arguments: [selfArgument, atArgument],
                                  type: .any)
        
        let closure = getNativeFunctionClosure(prototype: prototype, declarationScope: classScope) {
            (arguments, _) in
            
            // Self argument
            guard let selfInstance = arguments?[0].value as? Instance,
                let index = arguments?[1].value as? Int else {
                    throw ProgramError(errorType: InterpreterError.nativeFunctionCallParameterError, debugInfo: nil)
            }
            
            guard let arrayVariable = selfInstance.scope.getSymbolValue(for: backendInstanceHashId) as? Variable,
                let array = arrayVariable.value as? NSMutableArray else {
                    throw ProgramError(errorType: InterpreterError.expressionEvaluationError, debugInfo: nil)
            }
            
            guard index >= 0 || index < array.count - 1 else {
                throw ProgramError(errorType: InterpreterError.expressionEvaluationError, debugInfo: nil)
            }
            
            let elementVariable = array.object(at: index) as! Variable
            
            return elementVariable
        }
        
        // Set closure in class scope
        classScope.symbolTable[prototype.hashId] = closure
    }

    // method: func isEmpty()
    private static func computeMethodIsEmpty(in classScope: Scope,
                                      selfArgument: Argument) {
        // Prototype
        // ---------
        let prototype = Prototype(name: "isEmpty",
                                  arguments: [selfArgument],
                                  type: .boolean)
        
        let closure = getNativeFunctionClosure(prototype: prototype, declarationScope: classScope) {
            (arguments, _) in
            
            // Self argument
            guard let selfInstance = arguments?.first?.value as? Instance else {
                throw ProgramError(errorType: InterpreterError.nativeFunctionCallParameterError, debugInfo: nil)
            }
            
            guard let arrayVariable = selfInstance.scope.getSymbolValue(for: backendInstanceHashId) as? Variable,
                let array = arrayVariable.value as? NSMutableArray else {
                    throw ProgramError(errorType: InterpreterError.expressionEvaluationError, debugInfo: nil)
            }
            
            return Variable(type: .boolean,
                            isConstant: true,
                            value: (array.count == 0))
        }
        
        // Set closure in class scope
        classScope.symbolTable[prototype.hashId] = closure
    }

    // method:  func count()
    private static func computeMethodCount(in classScope: Scope,
                                    selfArgument: Argument) {
        // Prototype
        // ---------
        let prototype = Prototype(name: "count",
                                  arguments: [selfArgument],
                                  type: .integer)
        
        let closure = getNativeFunctionClosure(prototype: prototype, declarationScope: classScope) {
            (arguments, _) in
            
            // Self argument
            guard let selfInstance = arguments?.first?.value as? Instance else {
                throw ProgramError(errorType: InterpreterError.nativeFunctionCallParameterError, debugInfo: nil)
            }
            
            guard let arrayVariable = selfInstance.scope.getSymbolValue(for: backendInstanceHashId) as? Variable,
                let array = arrayVariable.value as? NSMutableArray else {
                    throw ProgramError(errorType: InterpreterError.expressionEvaluationError, debugInfo: nil)
            }
            
            return Variable(type: .integer,
                            isConstant: true,
                            value: array.count)
        }
        
        // Set closure in class scope
        classScope.symbolTable[prototype.hashId] = closure
    }

    // method:  func shuffled()

    // method:  func reversed()
}

