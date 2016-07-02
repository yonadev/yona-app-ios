//
//  Date.swift
//  Yona
//
//  Created by Chandan on 04/05/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

extension NSDate {
    func isGreaterThanDate(dateToCompare: NSDate) -> Bool {
        var isGreater = false
        if self.compare(dateToCompare) == NSComparisonResult.OrderedDescending {
            isGreater = true
        }
        
        return isGreater
    }
    
    /**
     Round ff the time to next 15 minutes i.e if time is 10:27 it will set it as 10:30.
     
     - parameter none
     - return Rounded value of object NSDate in HH:mm format
     */
    func dateRoundedDownTo15Minute() -> NSDate {
        let referenceTime = self.timeIntervalSinceReferenceDate
        let remainingSeconds = referenceTime % 900
        var timeRound15 = referenceTime - (referenceTime % 900)
        
        if timeRound15 > 450 {
            timeRound15 = referenceTime + (900 - remainingSeconds)
        }
        
        let date = NSDate.init(timeIntervalSinceReferenceDate: timeRound15)
        return date
    }
    
    struct Date {
        static let formatterYYYYMMDD: NSDateFormatter = {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyyMMdd"
            return formatter
        }()
    }
    var yearMonthDay: String {
        return Date.formatterYYYYMMDD.stringFromDate(self)
    }
    func isSameDayAs(date:NSDate) -> Bool {
        return yearMonthDay == date.yearMonthDay
    }
}
// NSCalendar+Swift.swift
// A set of Swift-idiomatic methods for NSCalendar
//
// (c) 2015 Nate Cook, licensed under the MIT license

@available(iOS 8.0, *)
extension NSCalendar {
    /// Returns the hour, minute, second, and nanoseconds of a given date.
    @available(iOS 8.0, *)
    func getTimeFromDate(date: NSDate) -> (hour: Int, minute: Int, second: Int, nanosecond: Int) {
        var (hour, minute, second, nanosecond) = (0, 0, 0, 0)
        getHour(&hour, minute: &minute, second: &second, nanosecond: &nanosecond, fromDate: date)
        return (hour, minute, second, nanosecond)
    }
    
    /// Returns the era, year, month, and day of a given date.
    func getDateItemsFromDate(date: NSDate) -> (era: Int, year: Int, month: Int, day: Int) {
        var (era, year, month, day) = (0, 0, 0, 0)
        getEra(&era, year: &year, month: &month, day: &day, fromDate: date)
        return (era, year, month, day)
    }
    
    /// Returns the era, year for week-of-year calculations, week of year, and weekday of a given date.
    func getWeekItemsFromDate(date: NSDate) -> (era: Int, yearForWeekOfYear: Int, weekOfYear: Int, weekday: Int) {
        var (era, yearForWeekOfYear, weekOfYear, weekday) = (0, 0, 0, 0)
        getEra(&era, yearForWeekOfYear: &yearForWeekOfYear, weekOfYear: &weekOfYear, weekday: &weekday, fromDate: date)
        return (era, yearForWeekOfYear, weekOfYear, weekday)
    }
    
    /// Returns the start and length of the next weekend after the given date. Returns nil if the
    /// calendar or locale don't support weekends.
//    func nextWeekendAfterDate(date: NSDate) -> (startDate: NSDate, interval: NSTimeInterval)? {
//        var startDate: NSDate?
//        var interval: NSTimeInterval = 0
//        
//        if nextWeekendStartDate(&startDate, interval: &interval, options: NSCalendarWrapComponents, afterDate: date),
//            let startDate = startDate
//        {
//            return (startDate, interval)
//        }
//        
//        return nil
//    }
    
    /// Returns the start and length of the weekend before the given date. Returns nil if the
    /// calendar or locale don't support weekends.
    func nextWeekendBeforeDate(date: NSDate) -> (startDate: NSDate, interval: NSTimeInterval)? {
        var startDate: NSDate?
        var interval: NSTimeInterval = 0
        
        if nextWeekendStartDate(&startDate, interval: &interval, options: .SearchBackwards, afterDate: date),
            let startDate = startDate
        {
            return (startDate, interval)
        }
        
        return nil
    }
    
    /// Returns the start and length of the weekend containing the given date. Returns nil if the
    /// given date isn't in a weekend or if the calendar or locale don't support weekends.
    func rangeOfWeekendContainingDate(date: NSDate) -> (startDate: NSDate, interval: NSTimeInterval)? {
        var startDate: NSDate?
        var interval: NSTimeInterval = 0
        
        if rangeOfWeekendStartDate(&startDate, interval: &interval, containingDate: date),
            let startDate = startDate
        {
            return (startDate, interval)
        }
        
        return nil
    }
}