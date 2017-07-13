//
//  ErrorHandler.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 02. 18..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import Foundation

protocol ErrorHandlerDelegate: class {
    
    func handleError()
    func handleError(_ message: String)
}

extension ErrorHandlerDelegate {
    func handleError() {
        
    }
}
