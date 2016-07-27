//
//  WeekActivityGoal.swift
//  Yona
//
//  Created by Anders Liebl on 29/06/2016.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

class WeekSingleActivityGoal: NSObject {
    var date : NSDate  = NSDate()
    var activity : [SingleDayActivityGoal] = []
    var goalLinks: String?
    var goalName: String?
    var goalType: String?
    var weekDetailLink : String?
    var numberOfDaysGoalWasReached : Int = 0
    
    
    init(data : BodyDataDictionary , allGoals : [Goal]) {
        
        
        if let aSingleDay = data[YonaConstants.jsonKeys.dayActivities] as? BodyDataDictionary{
            
            for eachDay in aSingleDay {
                //print (eachDay
                let object = SingleDayActivityGoal.init(data: eachDay , allGoals: allGoals)
                activity.append(object)
                if object.goalAccomplished {
                    numberOfDaysGoalWasReached += 1
                }
            }
            
            if let links = data[YonaConstants.jsonKeys.linksKeys] as? [String: AnyObject]{
                if let link = links[YonaConstants.jsonKeys.yonaWeekDetails] as? [String: AnyObject],
                    let weeklink = link[YonaConstants.jsonKeys.hrefKey] as? String{
                    weekDetailLink = weeklink
                }
                if let link = links[YonaConstants.jsonKeys.yonaGoal] as? [String: AnyObject],
                    let goalLink = link[YonaConstants.jsonKeys.hrefKey] as? String{
                    goalLinks = goalLink
                }
            }
            for goal in allGoals {
                if goalLinks == goal.selfLinks {
                    goalName = goal.GoalName
                    goalType = goal.goalType
                    
                }
            }
        }
    }
    
}