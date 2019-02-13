//
//  DaySingleActivityDetail.swift
//  Yona
//
//  Created by Ben Smith on 22/07/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

class DaySingleActivityDetail: NSObject {
    
    var daySpread : [Int] = []
    var spreadCells : [Int] = []
    var dayActivity  : Int = 0
    var zones : [String] = []
    var date : Date?
    var dayOfWeek : String?

    var selfLink : String?
    var goalLinks : String?
    var nextLink : String?
    var prevLink : String?
    var messageLink : String?
    var commentLink : String?
    var goalName : String?
    var goalType: String?
    
    var totalActivityDurationMinutes : Int = 0
    var goalAccomplished : Bool = false
    var totalMinutesBeyondGoal : Int = 0
    var maxDurationMinutes: Int = 0
    
    init(data : BodyDataDictionary, allGoals : [Goal]) {
        super.init()
        retrieveDayOfWeekFromDate(data)
        retrieveActivityDetail(data)
        retrieveUserLinks(data)
        retrieveGoalDetails(allGoals)
    }

    fileprivate func retrieveDayOfWeekFromDate(_ data: BodyDataDictionary) {
        dayOfWeek = ""
        if let adDate = data[YonaConstants.jsonKeys.date] as? String {
            var userCalendar = Calendar.init(identifier: .gregorian)
            userCalendar.firstWeekday = 1
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.locale = Locale.current
            formatter.calendar = userCalendar;
            
            if let startdate = formatter.date(from: adDate) {
                date = startdate
                dayOfWeek = date?.dayOfTheWeek()
            }
        }
    }
    
    fileprivate func retrieveActivityDetail(_ data: BodyDataDictionary) {
        if let total = data[YonaConstants.jsonKeys.goalAccomplished] as? Bool {
            goalAccomplished = total
        } else {
            goalAccomplished = false
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
    }
    
    fileprivate func retrieveUserLinks(_ data: BodyDataDictionary) {
        if let links = data[YonaConstants.jsonKeys.linksKeys] as? [String: AnyObject]{
            if let linksSelf = links[YonaConstants.jsonKeys.selfLinkKeys],
                let linksSelfHref = linksSelf[YonaConstants.jsonKeys.hrefKey] as? String{
                self.selfLink = linksSelfHref
            }
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
        }
    }
    
    fileprivate func retrieveGoalDetails(_ allGoals: [Goal]) {
        if let goal = allGoals.first(where: { goalLinks == $0.selfLinks }) {
            goalType = goal.goalType
            zones = goal.zones
            spreadCells = goal.spreadCells
            maxDurationMinutes = goal.maxDurationMinutes
            goalName = goal.GoalName
        }
    }
}
