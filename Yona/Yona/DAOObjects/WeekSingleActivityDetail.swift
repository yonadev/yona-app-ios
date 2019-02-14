//
//  WeekSingleActivityDetail.swift
//  Yona
//
//  Created by Anders Liebl on 16/07/2016.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

class WeekSingleActivityDetail: WeekSingleActivityGoal {
   
    var weekSpread : [Int] = []
    var weekActivity  : Int = 0
    var messageLink : String?
    var zones : [String] = []
    var spreadCells : [Int] = []

    var maxDurationMinutes: Int = 0
    var averageActivityDurationMinutes : Int = 0
    var totalActivityDurationMinutes : Int = 0
    var totalMinutesBeyondGoal : Int = 0
    var nextLink : String?
    var prevLink : String?
    var commentLink : String?
    var yonaBuddyLink: String?
    
    override init(data : BodyDataDictionary , allGoals : [Goal]) {
        super.init(data: data, allGoals: allGoals)
        
        if let adDate = data[YonaConstants.jsonKeys.date] as? String {
            var userCalendar = Calendar.init(identifier: .gregorian)
            userCalendar.firstWeekday = 1
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY'-W'ww"
            formatter.locale = Locale.current
            formatter.calendar = userCalendar;
            
            if let startdate = formatter.date(from: adDate) {
                date = startdate
            }
        }
                
        if let total = data[YonaConstants.jsonKeys.totalActivityDurationMinutes] as? Int {
            totalActivityDurationMinutes = total
            averageActivityDurationMinutes = total / 7
        } else {
            totalActivityDurationMinutes = 0
            averageActivityDurationMinutes = 0
        }
        
//        if let total = data[YonaConstants.jsonKeys.goalAccomplished] as? Bool {
//            goalAccomplished = total
//        } else {
//            goalAccomplished = false
//        }
        
        if let total = data[YonaConstants.jsonKeys.totalMinutesBeyondGoal] as? Int {
            totalMinutesBeyondGoal = total
        } else {
            totalMinutesBeyondGoal = 0
        }

        
        if let allSpread = data[YonaConstants.jsonKeys.spread] as? [Int] {
            weekSpread = allSpread
        }

        if let aWeekActivity = data[YonaConstants.jsonKeys.totalActivityDurationMinutes] as? Int {
            weekActivity = aWeekActivity
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
            if let link = links[YonaConstants.jsonKeys.commentLink] as? [String: AnyObject],
                let aCommentLink = link[YonaConstants.jsonKeys.hrefKey] as? String{
                commentLink = aCommentLink
            }
            if let link = links[YonaConstants.jsonKeys.yonaBuddy] as? [String: AnyObject],
                let buddyLink = link[YonaConstants.jsonKeys.hrefKey] as? String{
                yonaBuddyLink = buddyLink
            }
        }
        for goal in allGoals {
            if goalLinks == goal.selfLinks {
                goalType = goal.goalType
                zones = goal.zones
                spreadCells = goal.spreadCells
                maxDurationMinutes = goal.maxDurationMinutes  // datat for a week
            }
        }

    }
}
