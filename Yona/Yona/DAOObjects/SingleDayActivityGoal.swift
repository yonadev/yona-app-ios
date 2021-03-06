//
//  SingleDayActivityGoal.swift
//  Yona
//
//  Created by Anders Liebl on 29/06/2016.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

class SingleDayActivityGoal : NSObject {
    var totalActivityDurationMinutes : Int
    var goalAccomplished : Bool = false
    var totalMinutesBeyondGoal : Int
    var dayofweek : DayOfWeek
    var yonadayDetails : String
    
    init(data : (String, AnyObject) , allGoals : [Goal]) {
        
        let key = data.0
        let value = data.1
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
    
        
     class func dayOfWeekFromString(_ day:String) -> DayOfWeek {
        if day.lowercased() == "sunday" {
            return .sunday
        } else if day.lowercased() == "monday" {
            return .monday
        } else if day.lowercased() == "tuesday" {
            return .tuesday
        } else if day.lowercased() == "wednesday" {
            return .wednesday
        } else if day.lowercased() == "thursday" {
            return .thursday
        } else if day.lowercased() == "friday" {
            return .friday
        } else if day.lowercased() == "saturday" {
            return .saturday
        }
        return .sunday
    }
    

}
