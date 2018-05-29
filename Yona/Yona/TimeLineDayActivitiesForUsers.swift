//
//  TimeLinedayActivitiesForUsers.swift
//  Yona
//
//  Created by Anders Liebl on 04/08/2016.
//  Copyright © 2016 Yona. All rights reserved.
//


import Foundation
class TimeLinedayActivitiesForUsers : NSObject {
    
    //let date : NSDate
    var goalAccomplished = true
    var totalMinutesBeyondGoal = 0
    var totalActivityDurationMinutes = 0
    var goalLink : String?
    var goalName : String = ""
    var dayDetailLink : String?
    var buddyLink : String?
    var userLink : String?
    var spread : [Int] = []
    var zones : [String] = []
    var spreadCells : [Int] = []
    var maxDurationMinutes = 0
    
    var goalType : String = ""
    var buddy : Buddies?
    var user : Users?
    init(jsonData: BodyDataDictionary) {

        
        if let total = jsonData[YonaConstants.jsonKeys.totalActivityDurationMinutes] as? Int {
            totalActivityDurationMinutes = total
        } else {
            totalActivityDurationMinutes = 0
        }
        
        if let total = jsonData[YonaConstants.jsonKeys.goalAccomplished] as? Bool {
            goalAccomplished = total
        } else {
            goalAccomplished = false
        }
        
        if let total = jsonData[YonaConstants.jsonKeys.totalMinutesBeyondGoal] as? Int {
            totalMinutesBeyondGoal = total
        } else {
            totalMinutesBeyondGoal = 0
        }

        if let theSpread = jsonData[YonaConstants.jsonKeys.spread] as? [Int] {
            spread = theSpread
        } else {
            spread = []
        }

    
        if let links = jsonData[YonaConstants.jsonKeys.linksKeys] as? [String: AnyObject]{
            if let edit = links[YonaConstants.jsonKeys.yonaDayDetails] as? [String: AnyObject],
                let link = edit[YonaConstants.jsonKeys.hrefKey] as? String{
                dayDetailLink = link
            }
            if let edit = links[YonaConstants.jsonKeys.yonaGoal] as? [String: AnyObject],
                let link = edit[YonaConstants.jsonKeys.hrefKey] as? String{
                goalLink = link
            }
            if let edit = links[YonaConstants.jsonKeys.yonaBuddy] as? [String: AnyObject],
                let link = edit[YonaConstants.jsonKeys.hrefKey] as? String{
                buddyLink = link
            }
            if let edit = links[YonaConstants.jsonKeys.yonaUserSelfLink] as? [String: AnyObject],
                let link = edit[YonaConstants.jsonKeys.hrefKey] as? String{
                userLink = link
            }

        }
        
    }
    
    func setGoalData(_ goals : [Goal]) {
        
        let range1 =  goalLink?.range(of: "goals/")?.lowerBound
        var goal1ID = ""
        if let txt = goalLink?.substring(from: range1!) {
            goal1ID = txt
        }
        for goal in goals {
            let range1 =  goal.selfLinks?.range(of: "goals/")?.lowerBound
            var goal2ID = ""
            if let txt = goal.selfLinks?.substring(from: range1!) {
                goal2ID = txt
            }
            if goal1ID == goal2ID {
                zones = goal.zones
                spreadCells = goal.spreadCells
                maxDurationMinutes = goal.maxDurationMinutes  // datat for a week
                if let txt = goal.goalType {
                    goalType = txt
                }
            }
        }

    }

    func setBuddyOrUser(_ buddies : [Buddies], aUser : Users) {
        
        if userLink == aUser.getSelfLink {
            user = aUser
            setGoalData(aUser.userGoals)
        }
        for aBuddy in buddies {
            if buddyLink == aBuddy.selfLink {
                buddy = aBuddy
                setGoalData(aBuddy.buddyGoals)
            }
        }
        
        
    }

}
