//
//  Evaluable.swift
//  TestLexer
//
//  Created by poisson florent on 03/06/2018.
//  Copyright © 2018 poisson florent. All rights reserved.
//

import Foundation

protocol Evaluable: Loggable, Debuggable {

    /**
     
     - Parameter context: current scope,
     
     - Parameter environment: external & internal environment interface.
    
     */
    func evaluate(context: Scope,
                  session: Session) throws -> Evaluable?

}
