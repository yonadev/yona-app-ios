//
//  DaySingleActivityDetail.swift
//  Yona
//
//  Created by Ben Smith on 22/07/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

class DaySingleActivityDetail: SingleDayActivityGoal {
    
    var daySpread : [Int] = []
    var dayActivity  : Int = 0
    var zones : [String] = []
    var spreadCells : [Int] = []
    var date : NSDate  = NSDate()

    var maxDurationMinutes: Int = 0
    var goalLinks : String?
    var nextLink : String?
    var prevLink : String?
    var messageLink : String?
 
    override init(data : BodyDataDictionary, allGoals : [Goal]) {
        super.init(data: data, allGoals : allGoals)
        
        if let adDate = data[YonaConstants.jsonKeys.date] as? String {
            let userCalendar = NSCalendar.init(calendarIdentifier: NSGregorianCalendar)
            userCalendar?.firstWeekday = 1
            let formatter = NSDateFormatter()
            formatter.dateFormat = "YYYY'-W'ww"
            formatter.locale = NSLocale.currentLocale()
            formatter.calendar = userCalendar;
            
            if let startdate = formatter.dateFromString(adDate) {
                date = startdate
            }
        }
        
        if let total = data[YonaConstants.jsonKeys.totalActivityDurationMinutes] as? Int {
            totalActivityDurationMinutes = total
        } else {
            totalActivityDurationMinutes = 0
        }
        
        if let total = data[YonaConstants.jsonKeys.totalMinutesBeyondGoal] as? Int {
            totalMinutesBeyondGoal = total
        } else {
            totalMinutesBeyondGoal = 0
        }
        
        
        if let allSpread = data[YonaConstants.jsonKeys.spread] as? [Int] {
            daySpread = allSpread
        }
        
        if let aDayActivity = data[YonaConstants.jsonKeys.totalActivityDurationMinutes] as? Int {
            dayActivity = aDayActivity
        }
        
        if let links = data[YonaConstants.jsonKeys.linksKeys] as? [String: AnyObject]{
            if let link = links[YonaConstants.jsonKeys.yonaMessages] as? [String: AnyObject],
                let messagelink = link[YonaConstants.jsonKeys.hrefKey] as? String{
                messageLink = messagelink
            }
            if let link = links[YonaConstants.jsonKeys.yonaGoal] as? [String: AnyObject],
                let goalLink = link[YonaConstants.jsonKeys.hrefKey] as? String{
                goalLinks = goalLink
            }
            if let link = links[YonaConstants.jsonKeys.prevLink] as? [String: AnyObject],
                let aPrevLink = link[YonaConstants.jsonKeys.hrefKey] as? String{
                prevLink = aPrevLink
            }
            if let link = links[YonaConstants.jsonKeys.nextLink] as? [String: AnyObject],
                let aNextLink = link[YonaConstants.jsonKeys.hrefKey] as? String{
                nextLink = aNextLink
            }
        }
        for goal in allGoals {
            if goalLinks == goal.selfLinks {
                zones = goal.zones
                spreadCells = goal.spreadCells
                maxDurationMinutes = goal.maxDurationMinutes
            }
        }
    }
}