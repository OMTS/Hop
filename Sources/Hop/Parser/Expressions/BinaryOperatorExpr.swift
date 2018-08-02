//
//  BinaryOperatorExpr.swift
//  TestLexer
//
//  Created by poisson florent on 05/06/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

struct BinaryOperatorExpr: Evaluable {
    var debugInfo: DebugInfo?
    
    var binOp: Token
    var lhs: Evaluable
    var rhs: Evaluable

    init(binOp: Token, lhs: Evaluable, rhs: Evaluable) {
        self.binOp = binOp
        self.lhs = lhs
        self.rhs = rhs
    }

    var description: String {
        return "(" + lhs.description + "\(binOp.rawValue)" + rhs.description + ")"
    }
    
    func evaluate(context: Scope,
                  environment: Environment) throws -> Evaluable? {
        
        switch binOp {
        case .dot:
            return try evaluateDot(context: context,
                                   environment: environment)
        case .plus:
            return try evaluateAddition(context: context,
                                        environment: environment)
        case .minus:
            return try evaluateSubstraction(context: context,
                                            environment: environment)
        case .multiplication:
            return try evaluateMultiplication(context: context,
                                              environment: environment)
        case .divide:
            return try evaluateDivision(context: context,
                                        environment: environment)
        case .remainder:
            return try evaluateRemainder(context: context,
                                         environment: environment)
        case .assignment:
            return try evaluateAssignment(context: context,
                                          environment: environment)
        case .equal:
            return try evaluateEquality(context: context,
                                        environment: environment)
        case .notEqual:
            return try evaluateNonEquality(context: context,
                                           environment: environment)
        case .lessThan:
            return try evaluateLessThanComparison(context: context,
                                                  environment: environment)
        case .greaterThan:
            return try evaluateGreaterThanComparison(context: context,
                                                     environment: environment)
        case .greaterThanOrEqualTo:
            return try evaluateGreaterThanOrEqualToComparison(context: context,
                                                              environment: environment)
        case .lessThanOrEqualTo:
            return try evaluateLessThanOrEqualToComparison(context: context,
                                                           environment: environment)
        case .logicalAND:
            return try evaluateLogicalANDComparison(context: context,
                                                    environment: environment)
        case .logicalOR:
            return try evaluateLogicalORComparison(context: context,
                                                   environment: environment)
        default:
            return nil
        }
    }
    
    private func evaluateDot(context: Scope,
                             environment: Environment) throws -> Evaluable? {

        //        print("--> evaluateDot: contextId = \(context.uid)")
        let lhsEvaluation = try lhs.evaluate(context: context,
                                             environment: environment)

        // lshEvaluation could be:
            // a module:
                // rshEvaluation could be:
                    // a module <- identifier evaluated as a module
                    // a classe <- identifier evaluated as a class
                    // a variable <- identifier evaluated as a variable
                    // a function call <- function call
        
            // a class:
                // an inner class <- identifier evaluated as a variable
                // a class property <- identifier evaluated as a variable
                // a class method <- function call
        
            // an instance:
                // an instance property <- identifier evaluated as a variable
                // a class property <- identifier evaluated as a variable
                // an instance function call <- function call
                    // lhs is 'super' expression
                        // evaluate with instante.class.superclass
                    // or not
                        // evaluate with instante.class
        
        if let lhsModule = lhsEvaluation as? Module {
            if let rhsIdentifier = rhs as? IdentifierExpr {
                return try rhsIdentifier.evaluate(context: lhsModule.scope,
                                                  environment: environment)!

            } else if let rhsFunctionCall = rhs as? FunctionCallExpr {
                // Search for the method in the module
                return try rhsFunctionCall.evaluateFunction(ofModule: lhsModule,
                                                            context: context,
                                                            environment: environment)
            } else {
                throw ProgramError(errorType: InterpreterError.accessorMemberError, debugInfo: debugInfo)
            }
        } else if let lhsClasse = lhsEvaluation as? Class {
            if let rhsIdentifier = rhs as? IdentifierExpr {
                // Search class member
                guard let evaluatedRhs = lhsClasse.getClassMember(for: rhsIdentifier.hashId),
                    (evaluatedRhs is Variable || evaluatedRhs is Class) else {
                    throw ProgramError(errorType: InterpreterError.unresolvedIdentifier, debugInfo: debugInfo)
                }
                return evaluatedRhs

            } else if let rhsFunctionCall = rhs as? FunctionCallExpr {
                return try rhsFunctionCall.evaluateMethod(ofClass: lhsClasse,
                                                          context: context,
                                                          environment: environment)
            } else {
                throw ProgramError(errorType: InterpreterError.accessorMemberError, debugInfo: debugInfo)
            }
        } else if let lhsVariable = lhsEvaluation as? Variable {
            if let instance = lhsVariable.value as? Instance {
                if let rhsIdentifier = rhs as? IdentifierExpr {
                    // Restrain property access if it is accessed from superclass reference
                    if lhsVariable.type != instance.class.type {
                        guard let superclass = instance.class.getSuperclass(for: lhsVariable.type.hashId) else {
                            throw ProgramError(errorType: InterpreterError.expressionEvaluationError, debugInfo: debugInfo)

                        }
                        if !superclass.hasInstanceProperty(with: rhsIdentifier.hashId),
                            superclass.getClassMember(for: rhsIdentifier.hashId) == nil {
                            throw ProgramError(errorType: InterpreterError.classMemberNotDeclared, debugInfo: debugInfo)
                        }
                    }
                    
                    // Search for property variable in instance symbol table
                    if let propertyVariable = instance.scope.getSymbolValue(for: rhsIdentifier.hashId) as? Variable {
                        return propertyVariable
                        
                    } else if let propertyVariable = instance.class.getClassMember(for: rhsIdentifier.hashId) as? Variable {
                        // Then search for property variable in class scope
                        // Class properties are shared to all instances
                        return propertyVariable
                        
                    } else {
                        throw ProgramError(errorType: InterpreterError.accessorMemberError, debugInfo: debugInfo)
                    }
                } else if let rhsFunctionCall = rhs as? FunctionCallExpr {
                    // Restrain method acces if it is accessed from superclass reference
                    if lhsVariable.type != instance.class.type {
                        guard let superclass = instance.class.getSuperclass(for: lhsVariable.type.hashId) else {
                            throw ProgramError(errorType: InterpreterError.expressionEvaluationError, debugInfo: debugInfo)
                        }
                        var methodArgumentNames = [SelfParameter.name]
                        if let argumentNames = rhsFunctionCall.argumentNames {
                            methodArgumentNames.append(contentsOf: argumentNames)
                        }
                        let methodHashId = Closure.getFunctionSignatureHashId(name: rhsFunctionCall.name,
                                                                              argumentNames: methodArgumentNames)
                        if superclass.getClassMember(for: methodHashId) == nil {
                            throw ProgramError(errorType: InterpreterError.classMemberNotDeclared, debugInfo: debugInfo)
                        }
                    }
                    
                    let inspectedClass = (lhs is SuperExpr ?
                        instance.class.superclass! :
                        instance.class)
                    return try rhsFunctionCall.evaluateMethod(ofInstance: instance,
                                                                  inspectedClass: inspectedClass,
                                                                  context: context,
                                                                  environment: environment)
                } else {
                    throw ProgramError(errorType: InterpreterError.accessorMemberError, debugInfo: debugInfo)
                }
            } else if lhsVariable.value != nil {
                throw ProgramError(errorType: InterpreterError.accessorOwnerError, debugInfo: debugInfo)
            } else {
                throw ProgramError(errorType: InterpreterError.undefinedVariable, debugInfo: debugInfo)
            }
        } else {
            throw ProgramError(errorType: InterpreterError.accessorOwnerError, debugInfo: debugInfo)
        }
    }
    
    private func evaluateAddition(context: Scope,
                                  environment: Environment) throws -> Evaluable? {
        
        guard let lhsVariable = try lhs.evaluate(context: context,
                                                 environment: environment) as? Variable,
            let rhsVariable = try rhs.evaluate(context: context,
                                               environment: environment) as? Variable else {
              throw ProgramError(errorType: InterpreterError.expressionEvaluationError, debugInfo: debugInfo)
        }
        
        guard lhsVariable.type == rhsVariable.type else {
            throw ProgramError(errorType: InterpreterError.binaryOperatorTypeMismatch, debugInfo: debugInfo)
        }

        guard let lhsValue = lhsVariable.value else {
            throw ProgramError(errorType: InterpreterError.undefinedVariable, debugInfo: debugInfo)
        }
        
        guard let rhsValue = rhsVariable.value else {
            throw ProgramError(errorType: InterpreterError.undefinedVariable, debugInfo: debugInfo)
        }
        
        if lhsVariable.type == .integer {
            return Variable(type: .integer,
                            isConstant: true,
                            value: (lhsValue as! Int) + (rhsValue as! Int))
            
        } else if lhsVariable.type == .real {
            return Variable(type: .real,
                            isConstant: true,
                            value: (lhsValue as! Double) + (rhsValue as! Double))
            
        }  else if lhsVariable.type == .string {
            return Variable(type: .string,
                            isConstant: true,
                            value: (lhsValue as! String) + (rhsValue as! String))
        } else {
            throw ProgramError(errorType: InterpreterError.expressionEvaluationError, debugInfo: debugInfo)
        }
    }
    
    private func evaluateSubstraction(context: Scope,
                                      environment: Environment) throws -> Evaluable? {
        
        guard let lhsVariable = try lhs.evaluate(context: context,
                                                 environment: environment) as? Variable,
            let rhsVariable = try rhs.evaluate(context: context,
                                               environment: environment) as? Variable else {
                throw ProgramError(errorType: InterpreterError.expressionEvaluationError, debugInfo: debugInfo)
        }
        
        guard lhsVariable.type == rhsVariable.type else {
            throw ProgramError(errorType: InterpreterError.binaryOperatorTypeMismatch, debugInfo: debugInfo)
        }
        
        guard let lhsValue = lhsVariable.value else {
           throw ProgramError(errorType: InterpreterError.undefinedVariable, debugInfo: debugInfo)
        }
        
        guard let rhsValue = rhsVariable.value else {
            throw ProgramError(errorType: InterpreterError.undefinedVariable, debugInfo: debugInfo)
        }
        
        if lhsVariable.type == .integer {
            return Variable(type: .integer,
                            isConstant: true,
                            value: (lhsValue as! Int) - (rhsValue as! Int))
            
        } else if lhsVariable.type == .real {
            return Variable(type: .real,
                            isConstant: true,
                            value: (lhsValue as! Double) - (rhsValue as! Double))
            
        } else {
            throw ProgramError(errorType: InterpreterError.expressionEvaluationError, debugInfo: debugInfo)
        }
    }
    
    private func evaluateMultiplication(context: Scope,
                                        environment: Environment) throws -> Evaluable? {
        
        guard let lhsVariable = try lhs.evaluate(context: context,
                                                 environment: environment) as? Variable,
            let rhsVariable = try rhs.evaluate(context: context,
                                               environment: environment) as? Variable else {
                 throw ProgramError(errorType: InterpreterError.expressionEvaluationError, debugInfo: debugInfo)

        }

        guard lhsVariable.type == rhsVariable.type else {
            throw ProgramError(errorType: InterpreterError.binaryOperatorTypeMismatch, debugInfo: debugInfo)
        }
        
        guard let lhsValue = lhsVariable.value else {
            throw ProgramError(errorType: InterpreterError.undefinedVariable, debugInfo: debugInfo)
        }
        
        guard let rhsValue = rhsVariable.value else {
            throw ProgramError(errorType: InterpreterError.undefinedVariable, debugInfo: debugInfo)
        }
        
        if lhsVariable.type == .integer {
            return Variable(type: .integer,
                            isConstant: true,
                            value: (lhsValue as! Int) * (rhsValue as! Int))
            
        } else if lhsVariable.type == .real {
            return Variable(type: .real,
                            isConstant: true,
                            value: (lhsValue as! Double) * (rhsValue as! Double))
            
        } else {
            throw ProgramError(errorType: InterpreterError.expressionEvaluationError, debugInfo: debugInfo)
        }
    }
    
    private func evaluateDivision(context: Scope,
                                  environment: Environment) throws -> Evaluable? {
        
        guard let lhsVariable = try lhs.evaluate(context: context,
                                                 environment: environment) as? Variable,
            let rhsVariable = try rhs.evaluate(context: context,
                                               environment: environment) as? Variable else {
                throw ProgramError(errorType: InterpreterError.expressionEvaluationError, debugInfo: debugInfo)
        }

        guard lhsVariable.type == rhsVariable.type else {
            throw ProgramError(errorType: InterpreterError.binaryOperatorTypeMismatch, debugInfo: debugInfo)
        }
        
        guard let lhsValue = lhsVariable.value else {
            throw ProgramError(errorType: InterpreterError.undefinedVariable, debugInfo: debugInfo)
        }
        
        guard let rhsValue = rhsVariable.value else {
            throw ProgramError(errorType: InterpreterError.undefinedVariable, debugInfo: debugInfo)
        }
        
        if lhsVariable.type == .integer {
            let rhsInteger = rhsValue as! Int
            if rhsInteger == 0 {
                throw ProgramError(errorType: InterpreterError.zeroDivisionAttempt, debugInfo: debugInfo)
            }
            return Variable(type: .integer,
                            isConstant: true,
                            value: (lhsValue as! Int) / rhsInteger)
            
        } else if lhsVariable.type == .real {
            let rhsReal = rhsValue as! Double
            if rhsReal == 0 {
                throw ProgramError(errorType: InterpreterError.zeroDivisionAttempt, debugInfo: debugInfo)
            }
            return Variable(type: .real,
                            isConstant: true,
                            value: (lhsValue as! Double) / rhsReal)
            
        } else {
            throw ProgramError(errorType: InterpreterError.expressionEvaluationError, debugInfo: debugInfo)
        }
    }
    
    private func evaluateRemainder(context: Scope,
                                   environment: Environment) throws -> Evaluable? {
        
        guard let lhsVariable = try lhs.evaluate(context: context,
                                                 environment: environment) as? Variable,
            let rhsVariable = try rhs.evaluate(context: context,
                                               environment: environment) as? Variable else {
                throw ProgramError(errorType: InterpreterError.expressionEvaluationError, debugInfo: debugInfo)
        }

        guard lhsVariable.type == rhsVariable.type else {
            throw ProgramError(errorType: InterpreterError.binaryOperatorTypeMismatch, debugInfo: debugInfo)
        }
        
        guard let lhsValue = lhsVariable.value else {
            throw ProgramError(errorType: InterpreterError.undefinedVariable, debugInfo: debugInfo)
        }
        
        guard let rhsValue = rhsVariable.value else {
            throw ProgramError(errorType: InterpreterError.undefinedVariable, debugInfo: debugInfo)
        }
        
        if lhsVariable.type == .integer {
            return Variable(type: .integer,
                            isConstant: true,
                            value: (lhsValue as! Int) % (rhsValue as! Int))
            
        } else {
            throw ProgramError(errorType: InterpreterError.expressionEvaluationError, debugInfo: debugInfo)
        }
    }
    
    private func evaluateAssignment(context: Scope,
                                    environment: Environment) throws -> Evaluable? {
        
        guard let lhsVariable = try lhs.evaluate(context: context,
                                                 environment: environment) as? Variable,
            let rhsVariable = try rhs.evaluate(context: context,
                                               environment: environment) as? Variable else {
                throw ProgramError(errorType: InterpreterError.expressionEvaluationError, debugInfo: debugInfo)
        }
        
        if lhsVariable.isConstant {
            throw ProgramError(errorType: InterpreterError.forbiddenAssignment, debugInfo: debugInfo)
        }

        // Check for type matching
        if lhsVariable.type != .any {     // `Any` welcome any type
            if lhsVariable.type != rhsVariable.type {
                if let instance = rhsVariable.value as? Instance {
                    if !instance.isInstance(of: lhsVariable.type) {
                        throw ProgramError(errorType: InterpreterError.expressionTypeMismatch, debugInfo: debugInfo)
                    }
                } else if rhsVariable.type != .nil {
                    throw ProgramError(errorType: InterpreterError.expressionTypeMismatch, debugInfo: debugInfo)
                }
            }
        }
        
        lhsVariable.value = rhsVariable.value

        return nil
    }
    
    private func evaluateEquality(context: Scope,
                                  environment: Environment) throws -> Evaluable? {
        
        guard let lhsVariable = try lhs.evaluate(context: context,
                                                 environment: environment) as? Variable,
            let rhsVariable = try rhs.evaluate(context: context,
                                               environment: environment) as? Variable else {
                throw ProgramError(errorType: InterpreterError.expressionEvaluationError, debugInfo: debugInfo)
        }

        if lhsVariable.type != rhsVariable.type {
            if lhsVariable.type == .nil {
                return Variable(type: .boolean, isConstant: true, value: rhsVariable.value == nil)
            }
            
            if rhsVariable.type == .nil {
                return Variable(type: .boolean, isConstant: true, value: lhsVariable.value == nil)
            }

            throw ProgramError(errorType: InterpreterError.expressionTypeMismatch, debugInfo: debugInfo)
        }
        
        if lhsVariable.type == .integer {
            let value = (lhsVariable.value as! Int?) == (rhsVariable.value as! Int?)
            return Variable(type: .boolean, isConstant: true, value: value)
            
        } else if lhsVariable.type == .real {
            let value = (lhsVariable.value as! Double?) == (rhsVariable.value as! Double?)
            return Variable(type: .boolean, isConstant: true, value: value)
            
        } else if lhsVariable.type == .boolean {
            let value = (lhsVariable.value as! Bool?) == (rhsVariable.value as! Bool?)
            return Variable(type: .boolean, isConstant: true, value: value)

        } else if lhsVariable.type == .string {
            let value = (lhsVariable.value as! String?) == (rhsVariable.value as! String?)
            return Variable(type: .boolean, isConstant: true, value: value)

        } else {
            throw ProgramError(errorType: InterpreterError.expressionEvaluationError, debugInfo: debugInfo)
        }
    }
    
    private func evaluateNonEquality(context: Scope,
                                     environment: Environment) throws -> Evaluable? {
        
        guard let lhsVariable = try lhs.evaluate(context: context,
                                                 environment: environment) as? Variable,
            let rhsVariable = try rhs.evaluate(context: context,
                                               environment: environment) as? Variable else {
                throw ProgramError(errorType: InterpreterError.expressionEvaluationError, debugInfo: debugInfo)
        }
        
        if lhsVariable.type != rhsVariable.type {
            if lhsVariable.type == .nil {
                return Variable(type: .boolean, isConstant: true, value: rhsVariable.value != nil)
            }
            
            if rhsVariable.type == .nil {
                return Variable(type: .boolean, isConstant: true, value: lhsVariable.value != nil)
            }
            
            throw ProgramError(errorType: InterpreterError.expressionTypeMismatch, debugInfo: debugInfo)
        }
        
        if lhsVariable.type == .integer {
            let value = (lhsVariable.value as! Int?) != (rhsVariable.value as! Int?)
            return Variable(type: .boolean, isConstant: true, value: value)
            
        } else if lhsVariable.type == .real {
            let value = (lhsVariable.value as! Double?) != (rhsVariable.value as! Double?)
            return Variable(type: .boolean, isConstant: true, value: value)
            
        } else if lhsVariable.type == .boolean {
            let value = (lhsVariable.value as! Bool?) != (rhsVariable.value as! Bool?)
            return Variable(type: .boolean, isConstant: true, value: value)
            
        } else if lhsVariable.type == .string {
            let value = (lhsVariable.value as! String?) != (rhsVariable.value as! String?)
            return Variable(type: .boolean, isConstant: true, value: value)
            
        } else {
            throw ProgramError(errorType: InterpreterError.expressionEvaluationError, debugInfo: debugInfo)
        }
    }
    
    private func evaluateLessThanComparison(context: Scope,
                                            environment: Environment) throws -> Evaluable? {
        
        guard let lhsVariable = try lhs.evaluate(context: context,
                                                 environment: environment) as? Variable,
            let rhsVariable = try rhs.evaluate(context: context,
                                               environment: environment) as? Variable else {
                throw ProgramError(errorType: InterpreterError.expressionEvaluationError, debugInfo: debugInfo)
        }

        guard lhsVariable.type == rhsVariable.type else {
            throw ProgramError(errorType: InterpreterError.binaryOperatorTypeMismatch, debugInfo: debugInfo)
        }
        
        guard let lhsValue = lhsVariable.value else {
            throw ProgramError(errorType: InterpreterError.undefinedVariable, debugInfo: debugInfo)
        }
        
        guard let rhsValue = rhsVariable.value else {
            throw ProgramError(errorType: InterpreterError.undefinedVariable, debugInfo: debugInfo)
        }
        
        if lhsVariable.type == .integer {
            let value = (lhsValue as! Int) < (rhsValue as! Int)
            return Variable(type: .boolean, isConstant: true, value: value)
            
        } else if lhsVariable.type == .real {
            let value = (lhsValue as! Double) < (rhsValue as! Double)
            return Variable(type: .boolean, isConstant: true, value: value)
            
        } else if lhsVariable.type == .string {
            let value = (lhsValue as! String) < (rhsValue as! String)
            return Variable(type: .boolean, isConstant: true, value: value)
            
        } else {
            throw ProgramError(errorType: InterpreterError.expressionEvaluationError, debugInfo: debugInfo)
        }
    }
    
    private func evaluateGreaterThanComparison(context: Scope,
                                               environment: Environment) throws -> Evaluable? {
        
        guard let lhsVariable = try lhs.evaluate(context: context,
                                                 environment: environment) as? Variable,
            let rhsVariable = try rhs.evaluate(context: context,
                                               environment: environment) as? Variable else {
                throw ProgramError(errorType: InterpreterError.expressionEvaluationError, debugInfo: debugInfo)
        }

        guard lhsVariable.type == rhsVariable.type else {
            throw ProgramError(errorType: InterpreterError.binaryOperatorTypeMismatch, debugInfo: debugInfo)
        }
        
        guard let lhsValue = lhsVariable.value else {
            throw ProgramError(errorType: InterpreterError.undefinedVariable, debugInfo: debugInfo)
        }
        
        guard let rhsValue = rhsVariable.value else {
            throw ProgramError(errorType: InterpreterError.undefinedVariable, debugInfo: debugInfo)
        }
        
        if lhsVariable.type == .integer {
            let value = (lhsValue as! Int) > (rhsValue as! Int)
            return Variable(type: .boolean, isConstant: true, value: value)
            
        } else if lhsVariable.type == .real {
            let value = (lhsValue as! Double) > (rhsValue as! Double)
            return Variable(type: .boolean, isConstant: true, value: value)
            
        } else if lhsVariable.type == .string {
            let value = (lhsValue as! String) > (rhsValue as! String)
            return Variable(type: .boolean, isConstant: true, value: value)
            
        } else {
            throw ProgramError(errorType: InterpreterError.expressionEvaluationError, debugInfo: debugInfo)
        }
    }
    
    private func evaluateGreaterThanOrEqualToComparison(context: Scope,
                                                        environment: Environment) throws -> Evaluable? {
        
        guard let lhsVariable = try lhs.evaluate(context: context,
                                                 environment: environment) as? Variable,
            let rhsVariable = try rhs.evaluate(context: context,
                                               environment: environment) as? Variable else {
                throw ProgramError(errorType: InterpreterError.expressionEvaluationError, debugInfo: debugInfo)
        }

        guard lhsVariable.type == rhsVariable.type else {
            throw ProgramError(errorType: InterpreterError.binaryOperatorTypeMismatch, debugInfo: debugInfo)
        }
        
        guard let lhsValue = lhsVariable.value else {
            throw ProgramError(errorType: InterpreterError.undefinedVariable, debugInfo: debugInfo)
        }
        
        guard let rhsValue = rhsVariable.value else {
            throw ProgramError(errorType: InterpreterError.undefinedVariable, debugInfo: debugInfo)
        }
        
        if lhsVariable.type == .integer {
            let value = (lhsValue as! Int) >= (rhsValue as! Int)
            return Variable(type: .boolean, isConstant: true, value: value)
            
        } else if lhsVariable.type == .real {
            let value = (lhsValue as! Double) >= (rhsValue as! Double)
            return Variable(type: .boolean, isConstant: true, value: value)
            
        } else if lhsVariable.type == .string {
            let value = (lhsValue as! String) >= (rhsValue as! String)
            return Variable(type: .boolean, isConstant: true, value: value)
            
        } else {
            throw ProgramError(errorType: InterpreterError.expressionEvaluationError, debugInfo: debugInfo)
        }
    }
    
    private func evaluateLessThanOrEqualToComparison(context: Scope,
                                                     environment: Environment) throws -> Evaluable? {
        
        guard let lhsVariable = try lhs.evaluate(context: context,
                                                 environment: environment) as? Variable,
            let rhsVariable = try rhs.evaluate(context: context,
                                               environment: environment) as? Variable else {
                throw ProgramError(errorType: InterpreterError.expressionEvaluationError, debugInfo: debugInfo)
        }

        guard lhsVariable.type == rhsVariable.type else {
            throw ProgramError(errorType: InterpreterError.binaryOperatorTypeMismatch, debugInfo: debugInfo)
        }
        
        guard let lhsValue = lhsVariable.value else {
            throw ProgramError(errorType: InterpreterError.undefinedVariable, debugInfo: debugInfo)
        }
        
        guard let rhsValue = rhsVariable.value else {
            throw ProgramError(errorType: InterpreterError.undefinedVariable, debugInfo: debugInfo)
        }
        
        if lhsVariable.type == .integer {
            let value = (lhsValue as! Int) <= (rhsValue as! Int)
            return Variable(type: .boolean, isConstant: true, value: value)
            
        } else if lhsVariable.type == .real {
            let value = (lhsValue as! Double) <= (rhsValue as! Double)
            return Variable(type: .boolean, isConstant: true, value: value)
            
        } else if lhsVariable.type == .string {
            let value = (lhsValue as! String) <= (rhsValue as! String)
            return Variable(type: .boolean, isConstant: true, value: value)
            
        } else {
            throw ProgramError(errorType: InterpreterError.expressionEvaluationError, debugInfo: debugInfo)
        }
    }
    
    private func evaluateLogicalANDComparison(context: Scope,
                                              environment: Environment) throws -> Evaluable? {
        
        guard let lhsVariable = try lhs.evaluate(context: context,
                                                 environment: environment) as? Variable,
            let rhsVariable = try rhs.evaluate(context: context,
                                               environment: environment) as? Variable else {
                throw ProgramError(errorType: InterpreterError.expressionEvaluationError, debugInfo: debugInfo)
        }
        
        guard lhsVariable.type == rhsVariable.type else {
            throw ProgramError(errorType: InterpreterError.binaryOperatorTypeMismatch, debugInfo: debugInfo)
        }
        
        guard let lhsValue = lhsVariable.value else {
            throw ProgramError(errorType: InterpreterError.undefinedVariable, debugInfo: debugInfo)
        }
        
        guard let rhsValue = rhsVariable.value else {
            throw ProgramError(errorType: InterpreterError.undefinedVariable, debugInfo: debugInfo)
        }

        if lhsVariable.type == .boolean {
            let value = (lhsValue as! Bool) && (rhsValue as! Bool)
            return Variable(type: .boolean, isConstant: true, value: value)
            
        } else {
            throw ProgramError(errorType: InterpreterError.expressionEvaluationError, debugInfo: debugInfo)
        }
    }
    
    private func evaluateLogicalORComparison(context: Scope,
                                             environment: Environment) throws -> Evaluable? {
        
        guard let lhsVariable = try lhs.evaluate(context: context,
                                                 environment: environment) as? Variable,
            let rhsVariable = try rhs.evaluate(context: context,
                                               environment: environment) as? Variable else {
                throw ProgramError(errorType: InterpreterError.expressionEvaluationError, debugInfo: debugInfo)
        }

        guard lhsVariable.type == rhsVariable.type else {
            throw ProgramError(errorType: InterpreterError.binaryOperatorTypeMismatch, debugInfo: debugInfo)
        }
        
        guard let lhsValue = lhsVariable.value else {
            throw ProgramError(errorType: InterpreterError.undefinedVariable, debugInfo: debugInfo)
        }
        
        guard let rhsValue = rhsVariable.value else {
            throw ProgramError(errorType: InterpreterError.undefinedVariable, debugInfo: debugInfo)
        }
        
        if lhsVariable.type == .boolean {
            let value = (lhsValue as! Bool) || (rhsValue as! Bool)
            return Variable(type: .boolean, isConstant: true, value: value)
            
        } else {
            throw ProgramError(errorType: InterpreterError.expressionEvaluationError, debugInfo: debugInfo)
        }
    }

}
