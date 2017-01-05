//
//  Dates.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 01. 05..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import Foundation

struct Dates {
    
    static func dateFromUnixTime(_ time: Double) -> String {
        let date = Date(timeIntervalSince1970: time)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM"
        return dateFormatter.string(from: date)
    }
}
