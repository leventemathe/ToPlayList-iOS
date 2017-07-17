//
//  GameIDs.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 01. 01..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import Foundation

struct ReleaseDateID {
    var date: Double
    var platformID: UInt64
    var regionID: UInt64?
}

struct GameIDs {
    
    let id: UInt64
    
    var developers: [UInt64]?
    var publishers: [UInt64]?
    
    var genres: [UInt64]?
    
    var screenshots: [String]?
    var videos: [String]?
    
    var description: String?
    
    var status: UInt64?
    var category: UInt64?
    
    var franchise: UInt64?
    var collection: UInt64?
    
    var gameModes: [UInt64]?
    var playerPerspectives: [UInt64]?
    
    var releaseDateIDs: [ReleaseDateID]?
    
    init(_ id: UInt64) {
        self.id = id
    }
}
