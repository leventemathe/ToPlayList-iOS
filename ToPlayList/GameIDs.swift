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
    
    var developers: [UInt64]? {
        didSet {
            developers = developers?.sorted()
        }
    }
    
    var publishers: [UInt64]? {
        didSet {
            publishers = publishers?.sorted()
        }
    }
    
    var genres: [UInt64]? {
        didSet {
            genres = genres?.sorted()
        }
    }
    
    init(_ id: UInt64) {
        self.id = id
    }
}
