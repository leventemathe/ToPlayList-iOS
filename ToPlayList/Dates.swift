//
//  Dates.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 01. 05..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import Foundation

struct Dates {
    
    private static let DATE_FORMAT_SHORT = "dd MMM"
    private static let DATE_FORMAT_FULL = "dd MMM y"
    
    static func dateForNewestReleases() -> Double {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        
        var components = DateComponents()
        components.day = 1
        components.second = -1
        
        if let date = calendar.date(byAdding: components, to: startOfToday) {
            return date.timeIntervalSince1970
        }
        return Date().timeIntervalSince1970
    }
    
    static func dateForUpcomingReleases() -> Double {
        let calendar = Calendar.current
        if let date = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: Date())) {
            return date.timeIntervalSince1970
        }
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
