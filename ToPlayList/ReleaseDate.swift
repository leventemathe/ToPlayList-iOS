//
//  ReleaseDate.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 07. 16..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import Foundation

class ReleaseDate: CustomStringConvertible {
    
    var platform: Platform
    var date: Double
    
    init(platform: Platform, date: Double) {
        self.platform = platform
        self.date = date
    }
    
    var description: String { return "date: \(date), platform: \(platform.name)" }
}
