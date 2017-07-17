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
    var region: Region?
    
    init(platform: Platform, date: Double, region: Region?) {
        self.platform = platform
        self.date = date
        self.region = region
    }
    
    var description: String {
        let regionString = region == nil ? "" : ", region: \(region!.name)"
        return "date: \(date), platform: \(platform.name)\(regionString)"
    }
}
