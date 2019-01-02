//
//  Date.swift
//  Yona
//
//  Created by Chandan on 04/05/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

extension Foundation.Date {
    fileprivate var calendar : Calendar {
        return Calendar.current
    }
    
    func fullDayMonthDateString() -> String { //Woensday, 9 April, 2016
        return Date.formatterEEEEDMMMMYYYY.string(from: self).uppercased()
    }
    
    func shortDayMonthDateString() -> String { //9 April
        return Date.formatterDDMMM.string(from: self).uppercased()
    }
    
    func isYesterday() -> Bool {
        let today = Foundation.Date()
        let yesterday = today.addingTimeInterval(-86400.0)
        return self.isSameDayAs(yesterday)
    }
    
    func isToday() -> Bool {
        let today = Foundation.Date()
        return self.isSameDayAs(today)
    }
    
    func monthNameFromDate() -> String {
        return DateFormatter().monthSymbols[self.months - 1]
    }
    
    public var years: Int {
        return (self.calendar as NSCalendar).components(.year, from: self).year!
    }
    
    public var months: Int {
        return (self.calendar as NSCalendar).components(.month, from: self).month!
    }
    
    public var weeks: Int {
        return (self.calendar as NSCalendar).components(.weekOfYear, from: self).weekOfYear!
    }
    
    public var days: Int {
        return (self.calendar as NSCalendar).components(.day, from: self).day!
    }
    
    public var hours: Int {
        return (self.calendar as NSCalendar).components(.hour, from: self).hour!
    }
    
    public var minutes: Int {
        return (self.calendar as NSCalendar).components(.minute, from: self).minute!
    }
    
    public var seconds: Int {
        return (self.calendar as NSCalendar).components(.second, from: self).second!
    }
    
    func isGreaterThanDate(_ dateToCompare: Foundation.Date) -> Bool {
        var isGreater = false
        if self.compare(dateToCompare) == ComparisonResult.orderedDescending {
            isGreater = true
        }
        return isGreater
    }
    
    /**
     Round ff the time to next 15 minutes i.e if time is 10:27 it will set it as 10:30.
     
     - parameter none
     - return Rounded value of object NSDate in HH:mm format
     */
    func dateRoundedDownTo15Minute() -> Foundation.Date {
        let referenceTime = self.timeIntervalSinceReferenceDate
        let remainingSeconds = referenceTime.truncatingRemainder(dividingBy: 900)
        var timeRound15 = referenceTime - (referenceTime.truncatingRemainder(dividingBy: 900))
        
        if timeRound15 > 450 {
            timeRound15 = referenceTime + (900 - remainingSeconds)
        }
        
        let date = Foundation.Date.init(timeIntervalSinceReferenceDate: timeRound15)
        return date
    }
    
    struct Date {
        static let formatterYYYYMMDD: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd"
            return formatter
        }()

        static let formatterYYYYWW: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-'W'ww"
            return formatter
        }()
        
        static let formatterMMDD: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMdd"
            return formatter
        }()
        
        static let formatterDD: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd"
            return formatter
        }()
        
        static let formatterDDMMM: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM"
            formatter.timeZone = TimeZone.init(abbreviation: "UTC")
            return formatter
        }()
        
        static let formatterEEEEDMMMMYYYY: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "eeee, d MMMM, YYYY"
            return formatter
        }()

    }
    
    var MonthDay: String {
        return Date.formatterMMDD.string(from: self)
    }
    
    var Day: String {
        return Date.formatterDD.string(from: self)
    }
    
    var yearWeek : String {
        return Date.formatterYYYYWW.string(from: self)
    }
    
    var yearMonthDay: String {
        return Date.formatterYYYYMMDD.string(from: self)
    }
    func isSameDayAs(_ date:Foundation.Date) -> Bool {
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
        
        let calendar: Calendar = Calendar.current
        let components: DateComponents = (calendar as NSCalendar).components(.weekday, from: self)
        return weekdays[components.weekday! - 1]
    }
}
// NSCalendar+Swift.swift
// A set of Swift-idiomatic methods for NSCalendar
//
// (c) 2015 Nate Cook, licensed under the MIT license

@available(iOS 8.0, *)
extension Calendar {
    /// Returns the hour, minute, second, and nanoseconds of a given date.
    @available(iOS 8.0, *)
    /// Returns the hour, minute, second, and nanoseconds of a given date.
    func getTimeFromDate(_ date: Date) -> (hour: Int, minute: Int, second: Int, nanosecond: Int) {
        let components = dateComponents([.hour, .minute, .second, .nanosecond], from: date)
        return (components.hour ?? 0, components.minute ?? 0, components.second ?? 0, components.nanosecond ?? 0)
    }
    
    /// Returns the era, year, month, and day of a given date.
    func getDateItemsFromDate(_ date: Date) -> (era: Int, year: Int, month: Int, day: Int) {
        let components = dateComponents([.era, .year, .month, .day], from: date)
        return (components.era ?? 0, components.year ?? 0, components.month ?? 0, components.day ?? 0)
    }
    
    /// Returns the era, year for week-of-year calculations, week of year, and weekday of a given date.
    func getWeekItemsFromDate(_ date: Date) -> (era: Int, yearForWeekOfYear: Int, weekOfYear: Int, weekday: Int) {
        let components = dateComponents([.era, .yearForWeekOfYear, .weekOfYear, .weekday], from: date)
        return (components.era ?? 0, components.yearForWeekOfYear ?? 0, components.weekOfYear ?? 0, components.weekday ?? 0)
    }
    
    /// Returns the start and length of the next weekend after the given date. Returns nil if the
    /// calendar or locale don't support weekends.
    func nextWeekendAfterDate(_ date: Date) -> (startDate: Date, interval: TimeInterval)? {
        var startDate: Date = .distantFuture
        var interval: TimeInterval = 0
        
        if nextWeekend(startingAfter: date, start: &startDate, interval: &interval, direction: .forward) {
            return (startDate, interval)
        }
        
        return nil
    }
    
    /// Returns the start and length of the weekend before the given date. Returns nil if the
    /// calendar or locale don't support weekends.
    func nextWeekendBeforeDate(_ date: Date) -> (startDate: Date, interval: TimeInterval)? {
        var startDate: Date = .distantPast
        var interval: TimeInterval = 0
        
        if nextWeekend(startingAfter: date, start: &startDate, interval: &interval, direction: .backward) {
            return (startDate, interval)
        }
        
        return nil
    }
    
    /// Returns the start and length of the weekend containing the given date. Returns nil if the
    /// given date isn't in a weekend or if the calendar or locale don't support weekends.
    func rangeOfWeekendContainingDate(_ date: Date) -> (startDate: Date, interval: TimeInterval)? {
        var startDate: Date = .distantPast
        var interval: TimeInterval = 0
        
        if dateIntervalOfWeekend(containing: date, start: &startDate, interval: &interval)
        {
            return (startDate, interval)
        }
        
        return nil
    }
}
