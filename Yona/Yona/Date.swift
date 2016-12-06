//
//  Date.swift
//  Yona
//
//  Created by Chandan on 04/05/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

extension NSDate {
    private var calendar : NSCalendar {
        return NSCalendar.currentCalendar()
    }
    
    func fullDayMonthDateString() -> String { //Woensday, 9 April, 2016
        return Date.formatterEEEEDMMMMYYYY.stringFromDate(self).uppercaseString
    }
    
    func shortDayMonthDateString() -> String { //9 April
        return Date.formatterDDMMM.stringFromDate(self).uppercaseString
    }
    
    func isYesterday() -> Bool {
        let today = NSDate()
        let yesterday = today.dateByAddingTimeInterval(-86400.0)
        return self.isSameDayAs(yesterday)
    }
    
    func isToday() -> Bool {
        let today = NSDate()
        return self.isSameDayAs(today)
    }
    
    func monthNameFromDate() -> String {
        return NSDateFormatter().monthSymbols[self.months - 1]
    }
    
    public var years: Int {
        return self.calendar.components(.Year, fromDate: self).year
    }
    
    public var months: Int {
        return self.calendar.components(.Month, fromDate: self).month
    }
    
    public var weeks: Int {
        return self.calendar.components(.WeekOfYear, fromDate: self).weekOfYear
    }
    
    public var days: Int {
        return self.calendar.components(.Day, fromDate: self).day
    }
    
    public var hours: Int {
        return self.calendar.components(.Hour, fromDate: self).hour
    }
    
    public var minutes: Int {
        return self.calendar.components(.Minute, fromDate: self).minute
    }
    
    public var seconds: Int {
        return self.calendar.components(.Second, fromDate: self).second
    }
    
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

        static let formatterYYYYWW: NSDateFormatter = {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-'W'ww"
            return formatter
        }()
        
        static let formatterMMDD: NSDateFormatter = {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "MMdd"
            return formatter
        }()
        
        static let formatterDD: NSDateFormatter = {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "dd"
            return formatter
        }()
        
        static let formatterDDMMM: NSDateFormatter = {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "dd MMM"
            return formatter
        }()
        
        static let formatterEEEEDMMMMYYYY: NSDateFormatter = {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "eeee, d MMMM, YYYY"
            return formatter
        }()

    }
    
    var MonthDay: String {
        return Date.formatterMMDD.stringFromDate(self)
    }
    
    var Day: String {
        return Date.formatterDD.stringFromDate(self)
    }
    
    var yearWeek : String {
        return Date.formatterYYYYWW.stringFromDate(self)
    }
    
    var yearMonthDay: String {
        return Date.formatterYYYYMMDD.stringFromDate(self)
    }
    func isSameDayAs(date:NSDate) -> Bool {
        return yearMonthDay == date.yearMonthDay
    }
    
    func dayOfTheWeek() -> String? {
        let weekdays = [
            NSLocalizedString("notifications.day.sunday", comment: ""),
            NSLocalizedString("notifications.day.monday", comment: ""),
            NSLocalizedString("notifications.day.tuesday", comment: ""),
            NSLocalizedString("notifications.day.wednesday", comment: ""),
            NSLocalizedString("notifications.day.thursday", comment: ""),
            NSLocalizedString("notifications.day.friday", comment: ""),
            NSLocalizedString("notifications.day.saturday", comment: "")
        ]
        
        let calendar: NSCalendar = NSCalendar.currentCalendar()
        let components: NSDateComponents = calendar.components(.Weekday, fromDate: self)
        return weekdays[components.weekday - 1]
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
    
    /// Returns the5 start and length of the next weekend after the given date. Returns nil if the
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