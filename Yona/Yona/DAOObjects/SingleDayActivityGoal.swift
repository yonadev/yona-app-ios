//
//  SingleDayActivityGoal.swift
//  Yona
//
//  Created by Anders Liebl on 29/06/2016.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation
enum DayOfWeek : Int {
    case Sunday = 1
    case Monday
    case Tuesday
    case Wednesday
    case Thursday
    case Friday
    case Saturday
}

class SingleDayActivityGoal : NSObject {
    var totalActivityDurationMinutes : Int
    let goalAccomplished : Bool
    var totalMinutesBeyondGoal : Int
    let dayofweek : DayOfWeek
    let yonadayDetails : String
    
    init(data : BodyDataDictionary , allGoals : [Goal]) {
        
        var dayData = data as Dictionary<String, AnyObject>
        let key = dayData.0
        let value = dayData.1
        dayofweek = SingleDayActivityGoal.dayOfWeekFromString(key)
        
        if let total = value[YonaConstants.jsonKeys.totalActivityDurationMinutes] as? Int {
            totalActivityDurationMinutes = total
        } else {
            totalActivityDurationMinutes = 0
        }
        
        if let total = value[YonaConstants.jsonKeys.goalAccomplished] as? Bool {
            goalAccomplished = total
        } else {
            goalAccomplished = false
        }
        
        if let total = value[YonaConstants.jsonKeys.totalMinutesBeyondGoal] as? Int {
            totalMinutesBeyondGoal = total
        } else {
            totalMinutesBeyondGoal = 0
        }
        
        if let links = value[YonaConstants.jsonKeys.linksKeys] as? [String: AnyObject]{
            if let link = links[YonaConstants.jsonKeys.yonaDayDetails] as? [String: AnyObject],
                let dayLink = link[YonaConstants.jsonKeys.hrefKey] as? String{
                yonadayDetails = dayLink
            } else {
                yonadayDetails = ""
            }
        } else {
            yonadayDetails = ""
        }
    }
    
        
     class func dayOfWeekFromString(day:String) -> DayOfWeek {
        if day.lowercaseString == "sunday" {
            return .Sunday
        } else if day.lowercaseString == "monday" {
            return .Monday
        } else if day.lowercaseString == "tuesday" {
            return .Tuesday
        } else if day.lowercaseString == "wednesday" {
            return .Wednesday
        } else if day.lowercaseString == "thursday" {
            return .Thursday
        } else if day.lowercaseString == "friday" {
            return .Friday
        } else if day.lowercaseString == "saturday" {
            return .Saturday
        }
        return .Sunday
    }
    

}
