//
//  GameIDs.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 01. 01..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import Foundation

struct GameIDs {
    
    let id: UInt64
    
    var developers: [UInt64]?
    var publishers: [UInt64]?
    
    var genres: [UInt64]?
    
    var screenshots: [String]?
    
    init(_ id: UInt64) {
        self.id = id
    }
}
