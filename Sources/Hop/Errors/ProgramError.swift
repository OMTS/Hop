//
//  ProgramError.swift
//  Hop
//
//  Created by Iman Zarrabian on 31/07/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

public protocol ErrorType {
    func getDescription() -> String
}

public struct ProgramError: Error {
    public var errorType: ErrorType
    public var getDescription: String {
        return errorType.getDescription()
    }
    public var debugInfo: DebugInfo?
}
