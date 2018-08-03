//
//  Debuggable.swift
//  Hop
//
//  Created by Iman Zarrabian on 31/07/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

public struct DebugInfo {
    public let lineNumber: Int
    public let position: Int

    init?(lineNumber: Int?, position: Int?) {
        guard let lineNumber = lineNumber, let position = position else {
            return nil
        }
        self.lineNumber = lineNumber
        self.position = position
    }
}

protocol Debuggable {
    var debugInfo: DebugInfo? {get set}
}

