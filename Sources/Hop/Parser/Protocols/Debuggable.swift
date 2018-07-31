//
//  Debuggable.swift
//  Hop
//
//  Created by Iman Zarrabian on 31/07/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

protocol Debuggable {
    var lineNumber: Int? {get set}
    var position: Int? {get set}

    func setDebuggabbleInfo(lineNumber: Int?, position: Int?)
}

extension Debuggable where Self: DebuggableElement {
    func setDebuggabbleInfo(lineNumber: Int?, position: Int?) {
        self.lineNumber = lineNumber
        self.position = position
    }
}
