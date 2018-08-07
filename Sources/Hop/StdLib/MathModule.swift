//
//  MathModule.swift
//  Hop iOS
//
//  Created by poisson florent on 07/08/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

// Math module functions
var mathFunctionsDeclarations: [FunctionClosure] = [
    getAcosDeclaration,
    getAsinDeclaration,
    getAtanDeclaration,
    getAtan2Declaration,
    getCosDeclaration,
    getSinDeclaration,
    getTanDeclaration,
    getAcoshDeclaration,
    getAsinhDeclaration,
    getAtanhDeclaration,
    getCoshDeclaration,
    getSinhDeclaration,
    getTanhDeclaration,
    getExpDeclaration,
    getLogDeclaration,
    getLog10Declaration,
    getFabsDeclaration,
    getHypotDeclaration,
    getPowDeclaration,
    getSqrtDeclaration,
    getCeilDeclaration,
    getFloorDeclaration,
    getRoundDeclaration
]

// MARK: - Math functions

/// Native binding for acos(Double) -> Double
private func getAcosDeclaration(declarationScope: Scope) -> Closure {
    // Prototype
    // ---------
    let argument = Argument(name: "value", type: .real, isAnonymous: true)
    let prototype = Prototype(name: "acos", arguments: [argument], type: .real)
    
    return getNativeFunctionClosure(prototype: prototype, declarationScope: declarationScope) {
        (expressions, _) in
        
        guard let value = expressions?.first?.value as? Double else {
            throw ProgramError(errorType: InterpreterError.nativeFunctionCallParameterError, debugInfo: nil)
        }
        return Variable(type: .real, isConstant: true, value: acos(value))
    }
}

/// Native binding for asin(Double) -> Double
private func getAsinDeclaration(declarationScope: Scope) -> Closure {
    // Prototype
    // ---------
    let argument = Argument(name: "value", type: .real, isAnonymous: true)
    let prototype = Prototype(name: "asin", arguments: [argument], type: .real)
    
    return getNativeFunctionClosure(prototype: prototype, declarationScope: declarationScope) {
        (expressions, _) in
        
        guard let value = expressions?.first?.value as? Double else {
            throw ProgramError(errorType: InterpreterError.nativeFunctionCallParameterError, debugInfo: nil)
        }
        return Variable(type: .real, isConstant: true, value: asin(value))
    }
}

/// Native binding for atan(Double) -> Double
private func getAtanDeclaration(declarationScope: Scope) -> Closure {
    // Prototype
    // ---------
    let argument = Argument(name: "value", type: .real, isAnonymous: true)
    let prototype = Prototype(name: "atan", arguments: [argument], type: .real)
    
    return getNativeFunctionClosure(prototype: prototype, declarationScope: declarationScope) {
        (expressions, _) in
        
        guard let value = expressions?.first?.value as? Double else {
            throw ProgramError(errorType: InterpreterError.nativeFunctionCallParameterError, debugInfo: nil)
        }
        return Variable(type: .real, isConstant: true, value: atan(value))
    }
}

/// Native binding for atan2(Double, Double) -> Double
private func getAtan2Declaration(declarationScope: Scope) -> Closure {
    // Prototype
    // ---------
    let xArgument = Argument(name: "x", type: .real, isAnonymous: true)
    let yArgument = Argument(name: "y", type: .real, isAnonymous: true)
    let prototype = Prototype(name: "atan2", arguments: [xArgument, yArgument], type: .real)
    
    return getNativeFunctionClosure(prototype: prototype, declarationScope: declarationScope) {
        (expressions, _) in
        
        guard let expressions = expressions,
            expressions.count == 2,
            let x = expressions[0].value as? Double,
            let y = expressions[1].value as? Double else {
                throw ProgramError(errorType: InterpreterError.nativeFunctionCallParameterError, debugInfo: nil)
        }
        return Variable(type: .real, isConstant: true, value: atan2(x, y))
    }
}

/// Native binding for cos(Double) -> Double
private func getCosDeclaration(declarationScope: Scope) -> Closure {
    // Prototype
    // ---------
    let argument = Argument(name: "value", type: .real, isAnonymous: true)
    let prototype = Prototype(name: "cos", arguments: [argument], type: .real)
    
    return getNativeFunctionClosure(prototype: prototype, declarationScope: declarationScope) {
        (expressions, _) in
        
        guard let value = expressions?.first?.value as? Double else {
            throw ProgramError(errorType: InterpreterError.nativeFunctionCallParameterError, debugInfo: nil)
        }
        return Variable(type: .real, isConstant: true, value: cos(value))
    }
}

/// Native binding for sin(Double) -> Double
private func getSinDeclaration(declarationScope: Scope) -> Closure {
    // Prototype
    // ---------
    let argument = Argument(name: "angle", type: .real, isAnonymous: true)
    let prototype = Prototype(name: "sin", arguments: [argument], type: .real)
    
    return getNativeFunctionClosure(prototype: prototype, declarationScope: declarationScope) {
        (expressions, _) in
        
        guard let value = expressions?.first?.value as? Double else {
            throw ProgramError(errorType: InterpreterError.nativeFunctionCallParameterError, debugInfo: nil)
        }
        return Variable(type: .real, isConstant: true, value: sin(value))
    }
}

/// Native binding for tan(Double) -> Double
private func getTanDeclaration(declarationScope: Scope) -> Closure {
    // Prototype
    // ---------
    let argument = Argument(name: "value", type: .real, isAnonymous: true)
    let prototype = Prototype(name: "tan", arguments: [argument], type: .real)
    
    return getNativeFunctionClosure(prototype: prototype, declarationScope: declarationScope) {
        (expressions, _) in
        
        guard let value = expressions?.first?.value as? Double else {
            throw ProgramError(errorType: InterpreterError.nativeFunctionCallParameterError, debugInfo: nil)
        }
        return Variable(type: .real, isConstant: true, value: tan(value))
    }
}

/// Native binding for acosh(Double) -> Double
private func getAcoshDeclaration(declarationScope: Scope) -> Closure {
    // Prototype
    // ---------
    let argument = Argument(name: "value", type: .real, isAnonymous: true)
    let prototype = Prototype(name: "acosh", arguments: [argument], type: .real)
    
    return getNativeFunctionClosure(prototype: prototype, declarationScope: declarationScope) {
        (expressions, _) in
        
        guard let value = expressions?.first?.value as? Double else {
            throw ProgramError(errorType: InterpreterError.nativeFunctionCallParameterError, debugInfo: nil)
        }
        return Variable(type: .real, isConstant: true, value: acosh(value))
    }
}

/// Native binding for asinh(Double) -> Double
private func getAsinhDeclaration(declarationScope: Scope) -> Closure {
    // Prototype
    // ---------
    let argument = Argument(name: "value", type: .real, isAnonymous: true)
    let prototype = Prototype(name: "asinh", arguments: [argument], type: .real)
    
    return getNativeFunctionClosure(prototype: prototype, declarationScope: declarationScope) {
        (expressions, _) in
        
        guard let value = expressions?.first?.value as? Double else {
            throw ProgramError(errorType: InterpreterError.nativeFunctionCallParameterError, debugInfo: nil)
        }
        return Variable(type: .real, isConstant: true, value: asinh(value))
    }
}

/// Native binding for atanh(Double) -> Double
private func getAtanhDeclaration(declarationScope: Scope) -> Closure {
    // Prototype
    // ---------
    let argument = Argument(name: "value", type: .real, isAnonymous: true)
    let prototype = Prototype(name: "atanh", arguments: [argument], type: .real)
    
    return getNativeFunctionClosure(prototype: prototype, declarationScope: declarationScope) {
        (expressions, _) in
        
        guard let value = expressions?.first?.value as? Double else {
            throw ProgramError(errorType: InterpreterError.nativeFunctionCallParameterError, debugInfo: nil)
        }
        return Variable(type: .real, isConstant: true, value: atanh(value))
    }
}

/// Native binding for cosh(Double) -> Double
private func getCoshDeclaration(declarationScope: Scope) -> Closure {
    // Prototype
    // ---------
    let argument = Argument(name: "value", type: .real, isAnonymous: true)
    let prototype = Prototype(name: "cosh", arguments: [argument], type: .real)
    
    return getNativeFunctionClosure(prototype: prototype, declarationScope: declarationScope) {
        (expressions, _) in
        
        guard let value = expressions?.first?.value as? Double else {
            throw ProgramError(errorType: InterpreterError.nativeFunctionCallParameterError, debugInfo: nil)
        }
        return Variable(type: .real, isConstant: true, value: cosh(value))
    }
}

/// Native binding for sinh(Double) -> Double
private func getSinhDeclaration(declarationScope: Scope) -> Closure {
    // Prototype
    // ---------
    let argument = Argument(name: "value", type: .real, isAnonymous: true)
    let prototype = Prototype(name: "sinh", arguments: [argument], type: .real)
    
    return getNativeFunctionClosure(prototype: prototype, declarationScope: declarationScope) {
        (expressions, _) in
        
        guard let value = expressions?.first?.value as? Double else {
            throw ProgramError(errorType: InterpreterError.nativeFunctionCallParameterError, debugInfo: nil)
        }
        return Variable(type: .real, isConstant: true, value: sinh(value))
    }
}

/// Native binding for tanh(Double) -> Double
private func getTanhDeclaration(declarationScope: Scope) -> Closure {
    // Prototype
    // ---------
    let argument = Argument(name: "value", type: .real, isAnonymous: true)
    let prototype = Prototype(name: "tanh", arguments: [argument], type: .real)
    
    return getNativeFunctionClosure(prototype: prototype, declarationScope: declarationScope) {
        (expressions, _) in
        
        guard let value = expressions?.first?.value as? Double else {
            throw ProgramError(errorType: InterpreterError.nativeFunctionCallParameterError, debugInfo: nil)
        }
        return Variable(type: .real, isConstant: true, value: tanh(value))
    }
}

/// Native binding for exp(Double) -> Double
private func getExpDeclaration(declarationScope: Scope) -> Closure {
    // Prototype
    // ---------
    let argument = Argument(name: "value", type: .real, isAnonymous: true)
    let prototype = Prototype(name: "exp", arguments: [argument], type: .real)
    
    return getNativeFunctionClosure(prototype: prototype, declarationScope: declarationScope) {
        (expressions, _) in
        
        guard let value = expressions?.first?.value as? Double else {
            throw ProgramError(errorType: InterpreterError.nativeFunctionCallParameterError, debugInfo: nil)
        }
        return Variable(type: .real, isConstant: true, value: exp(value))
    }
}

/// Native binding for log(Double) -> Double
private func getLogDeclaration(declarationScope: Scope) -> Closure {
    // Prototype
    // ---------
    let argument = Argument(name: "value", type: .real, isAnonymous: true)
    let prototype = Prototype(name: "log", arguments: [argument], type: .real)
    
    return getNativeFunctionClosure(prototype: prototype, declarationScope: declarationScope) {
        (expressions, _) in
        
        guard let value = expressions?.first?.value as? Double else {
            throw ProgramError(errorType: InterpreterError.nativeFunctionCallParameterError, debugInfo: nil)
        }
        return Variable(type: .real, isConstant: true, value: log(value))
    }
}

/// Native binding for log10(Double) -> Double
private func getLog10Declaration(declarationScope: Scope) -> Closure {
    // Prototype
    // ---------
    let argument = Argument(name: "value", type: .real, isAnonymous: true)
    let prototype = Prototype(name: "log10", arguments: [argument], type: .real)
    
    return getNativeFunctionClosure(prototype: prototype, declarationScope: declarationScope) {
        (expressions, _) in
        
        guard let value = expressions?.first?.value as? Double else {
            throw ProgramError(errorType: InterpreterError.nativeFunctionCallParameterError, debugInfo: nil)
        }
        return Variable(type: .real, isConstant: true, value: log10(value))
    }
}

/// Native binding for fabs(Double) -> Double
private func getFabsDeclaration(declarationScope: Scope) -> Closure {
    // Prototype
    // ---------
    let argument = Argument(name: "value", type: .real, isAnonymous: true)
    let prototype = Prototype(name: "fabs", arguments: [argument], type: .real)
    
    return getNativeFunctionClosure(prototype: prototype, declarationScope: declarationScope) {
        (expressions, _) in
        
        guard let value = expressions?.first?.value as? Double else {
            throw ProgramError(errorType: InterpreterError.nativeFunctionCallParameterError, debugInfo: nil)
        }
        return Variable(type: .real, isConstant: true, value: fabs(value))
    }
}

/// Native binding for hypot(Double, Double) -> Double
private func getHypotDeclaration(declarationScope: Scope) -> Closure {
    // Prototype
    // ---------
    let xArgument = Argument(name: "x", type: .real, isAnonymous: true)
    let yArgument = Argument(name: "y", type: .real, isAnonymous: true)
    let prototype = Prototype(name: "hypot", arguments: [xArgument, yArgument], type: .real)
    
    return getNativeFunctionClosure(prototype: prototype, declarationScope: declarationScope) {
        (expressions, _) in
        
        guard let expressions = expressions,
            expressions.count == 2,
            let x = expressions[0].value as? Double,
            let y = expressions[1].value as? Double else {
                throw ProgramError(errorType: InterpreterError.nativeFunctionCallParameterError, debugInfo: nil)
        }
        return Variable(type: .real, isConstant: true, value: hypot(x, y))
    }
}


/// Native binding for pow(Double, Double) -> Double
private func getPowDeclaration(declarationScope: Scope) -> Closure {
    // Prototype
    // ---------
    let xArgument = Argument(name: "x", type: .real, isAnonymous: true)
    let yArgument = Argument(name: "y", type: .real, isAnonymous: true)
    let prototype = Prototype(name: "pow", arguments: [xArgument, yArgument], type: .real)
    
    return getNativeFunctionClosure(prototype: prototype, declarationScope: declarationScope) {
        (expressions, _) in
        
        guard let expressions = expressions,
            expressions.count == 2,
            let x = expressions[0].value as? Double,
            let y = expressions[1].value as? Double else {
                throw ProgramError(errorType: InterpreterError.nativeFunctionCallParameterError, debugInfo: nil)
        }
        
        return Variable(type: .real, isConstant: true, value: pow(x, y))
    }
}

/// Native binding for sqrt(Double) -> Double
private func getSqrtDeclaration(declarationScope: Scope) -> Closure {
    // Prototype
    // ---------
    let argument = Argument(name: "value", type: .real, isAnonymous: true)
    let prototype = Prototype(name: "sqrt", arguments: [argument], type: .real)
    
    return getNativeFunctionClosure(prototype: prototype, declarationScope: declarationScope) {
        (expressions, _) in
        
        guard let value = expressions?.first?.value as? Double else {
            throw ProgramError(errorType: InterpreterError.nativeFunctionCallParameterError, debugInfo: nil)
        }
        return Variable(type: .real, isConstant: true, value: sqrt(value))
    }
}

/// Native binding for ceil(Double) -> Double
private func getCeilDeclaration(declarationScope: Scope) -> Closure {
    // Prototype
    // ---------
    let argument = Argument(name: "value", type: .real, isAnonymous: true)
    let prototype = Prototype(name: "ceil", arguments: [argument], type: .real)
    
    return getNativeFunctionClosure(prototype: prototype, declarationScope: declarationScope) {
        (expressions, _) in
        
        guard let value = expressions?.first?.value as? Double else {
            throw ProgramError(errorType: InterpreterError.nativeFunctionCallParameterError, debugInfo: nil)
        }
        return Variable(type: .real, isConstant: true, value: ceil(value))
    }
}

/// Native binding for acos(Double) -> Double
private func getFloorDeclaration(declarationScope: Scope) -> Closure {
    // Prototype
    // ---------
    let argument = Argument(name: "value", type: .real, isAnonymous: true)
    let prototype = Prototype(name: "floor", arguments: [argument], type: .real)
    
    return getNativeFunctionClosure(prototype: prototype, declarationScope: declarationScope) {
        (expressions, _) in
        
        guard let value = expressions?.first?.value as? Double else {
            throw ProgramError(errorType: InterpreterError.nativeFunctionCallParameterError, debugInfo: nil)
        }
        return Variable(type: .real, isConstant: true, value: floor(value))
    }
}

/// Native binding for round(Double) -> Double
private func getRoundDeclaration(declarationScope: Scope) -> Closure {
    // Prototype
    // ---------
    let argument = Argument(name: "value", type: .real, isAnonymous: true)
    let prototype = Prototype(name: "round", arguments: [argument], type: .real)
    
    return getNativeFunctionClosure(prototype: prototype, declarationScope: declarationScope) {
        (expressions, _) in
        
        guard let value = expressions?.first?.value as? Double else {
            throw ProgramError(errorType: InterpreterError.nativeFunctionCallParameterError, debugInfo: nil)
        }
        return Variable(type: .real, isConstant: true, value: round(value))
    }
}

