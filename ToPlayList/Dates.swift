//
//  Dates.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 01. 05..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import Foundation

struct Dates {
    
    private static let DATE_FORMAT_SHORT = "dd. MMM."
    private static let DATE_FORMAT_FULL = "dd. MMM. y."
    
    static func dateForNewestReleases() -> Double {
        return Date().timeIntervalSince1970
    }
    
    static func dateForUpcomingReleases() -> Double {
        return Date().timeIntervalSince1970
    }
    
    static func dateFromUnixTimeShort(_ time: Double) -> String {
        return dateFromUnixTime(time, withDateFormaf: DATE_FORMAT_SHORT)
    }
    
    static func dateFromUnixTimeFull(_ time: Double) -> String {
        return dateFromUnixTime(time, withDateFormaf: DATE_FORMAT_FULL)
    }
    
    private static func dateFromUnixTime(_ time: Double, withDateFormaf format: String) -> String {
        let date = Date(timeIntervalSince1970: time)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
    
    static func dateToUnixTimeShort(_ time: String) -> Double? {
        return dateToUnixTime(time, withDateFormat: DATE_FORMAT_SHORT)
    }
    
    static func dateToUnixTimeFull(_ time: String) -> Double? {
        return dateToUnixTime(time, withDateFormat: DATE_FORMAT_FULL)
    }
    
    static func dateToUnixTime(_ time: String, withDateFormat format: String) -> Double? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let date = dateFormatter.date(from: time)
        if let unixTime = date?.timeIntervalSince1970 {
            return unixTime
        }
        return nil
    }
}
