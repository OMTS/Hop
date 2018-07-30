//
//  Error.swift
//  Hop
//
//  Created by Iman Zarrabian on 31/07/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

protocol ProgramPrintableError: Error {
    var errorType: ErrorType {get set}
    var lineNumber: Int {get set}
    var postion: Int {get set}
    var getDescription: String {get}
}

public protocol ErrorType {
    func getDescription() -> String
}

public struct ProgrammError: ProgramPrintableError {
    public var errorType: ErrorType
    public var getDescription: String {
        return errorType.getDescription()
    }
    public var lineNumber: Int
    public var postion: Int
}
