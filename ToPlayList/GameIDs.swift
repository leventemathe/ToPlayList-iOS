//
//  GameIDs.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 01. 01..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import Foundation

struct GameIDs {
    
    let id: Int
    
    var developers: [Int]?
    var publishers: [Int]?
    var genres: [Int]?
    
    init(_ id: Int) {
        self.id = id
    }
}
