//
//  Status.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 04. 29..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import Foundation

class Status: IdentifiableObject {
    
    static let RELEASED = "Released"
    static let UNKNOWN = "Unknown status"
}

class IGDBStatus: Status {
    
    static func getString(_ id: UInt64) -> String {
        switch id {
        case 0:
            return Status.RELEASED
        case 2:
            return "Alpha"
        case 3:
            return "Beta"
        case 4:
            return "Early access"
        case 5:
            return "Offline"
        case 6:
            return "Cancelled"
        default:
            return Status.UNKNOWN
        }
    }
}
