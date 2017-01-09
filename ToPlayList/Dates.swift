//
//  Dates.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 01. 05..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import Foundation

struct Dates {
    
    private static let DATE_FORMAT = "dd MMM"
    
    static func dateFromUnixTime(_ time: Double) -> String {
        let date = Date(timeIntervalSince1970: time)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DATE_FORMAT
        return dateFormatter.string(from: date)
    }
    
    static func dateToUnixTime(_ time: String) -> Double? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DATE_FORMAT
        let date = dateFormatter.date(from: time)
        if let unixTime = date?.timeIntervalSince1970 {
            return unixTime
        }
        return nil
    }
}
