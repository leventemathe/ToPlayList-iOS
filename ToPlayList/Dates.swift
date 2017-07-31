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
    
    static func randomHourOfDay(_ time: Double) -> Date {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date(timeIntervalSince1970: time))
        
        let min = 9 * 60 * 60
        let max = 14 * 60 * 60
        let random = arc4random_uniform(UInt32(max - min)) + UInt32(min)
        let newTime = startOfToday.timeIntervalSince1970 + Double(random)
        
        return Date(timeIntervalSince1970: newTime)
    }
    
    static func dateFromUnixTimeShort(_ time: Double) -> String {
        return dateFromUnixTime(time, withDateFormat: DATE_FORMAT_SHORT)
    }
    
    static func dateFromUnixTimeFull(_ time: Double) -> String {
        return dateFromUnixTime(time, withDateFormat: DATE_FORMAT_FULL)
    }
    
    private static func dateFromUnixTime(_ time: Double, withDateFormat format: String) -> String {
        let date = Date(timeIntervalSince1970: time)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: "us")
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
