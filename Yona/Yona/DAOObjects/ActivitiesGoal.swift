//
//  ActivitieGoal.swift
//  Yona
//
//  Created by Anders Liebl on 28/06/2016.
//  Copyright © 2016 Yona. All rights reserved.
//


// THIS OBJECT will holad all data needed to present the UI Controls
//  http://wiki.yona.nu/display/DEV/UI+-+Controls

import Foundation

class ActivitiesGoal : NSObject{
    var activityID: String?
    var applicationsStore:[String] = []
    var dayDetailLinks: String?
    var goalLinks: String?
    var goalName: String?
    var goalType: String?
    var maxDurationMinutes: Int = 0
    var date : NSDate  = NSDate()
    var goalAccomplished : Bool = false
    var totalActivityDurationMinutes : Int = 0
    var totalMinutesBeyondGoal : Int = 0
    var spread : [Int] = [] //where the user has used (either within, blue, or without, red, the set timezone)
    var zones:[String] = [] //the string of time zones
    var spreadCells : [Int] = [] //the timezone cells
    
    /*
     "date": "2016-06-28",
     "timeZoneId": "Europe/Amsterdam",
     "dayActivities": [{
     "totalActivityDurationMinutes": 0,
     "goalAccomplished": true,
     "totalMinutesBeyondGoal": 0,
     "_links": {
					"yona:dayDetails": {
     "href": "http://85.222.227.142/users/34039ef8-5394-464c-a062-1b23b5051769/activity/days/2016-06-28/details/7da0f5c7-2f7d-42b8-93f8-8e5fb98a714d"
					},
					"yona:goal": {
     "href": "http://85.222.227.142/users/34039ef8-5394-464c-a062-1b23b5051769/goals/7da0f5c7-2f7d-42b8-93f8-8e5fb98a714d"
					}
     }

     */
    
    
    init(activityData: AnyObject, date theDate: NSDate) {
        
        date = theDate
                if let totalMinutesBeyondGoal = activityData[YonaConstants.jsonKeys.totalMinutesBeyondGoal] as? Int {
                    self.totalMinutesBeyondGoal = totalMinutesBeyondGoal
                }
                if let totalActivityDurationMinutes = activityData[YonaConstants.jsonKeys.totalActivityDurationMinutes] as? Int {
                    self.totalActivityDurationMinutes = totalActivityDurationMinutes
                }

        if let theSpread = activityData[YonaConstants.jsonKeys.spread] as? [Int] {
            self.spread = theSpread
        }

                if let goalAccomplished = activityData[YonaConstants.jsonKeys.goalAccomplished] as? Bool {
                    self.goalAccomplished = goalAccomplished
                }
                
                
                
                if let links = activityData[YonaConstants.jsonKeys.linksKeys] as? [String: AnyObject]{
                    if let edit = links[YonaConstants.jsonKeys.yonaGoal] as? [String: AnyObject],
                        let editLink = edit[YonaConstants.jsonKeys.hrefKey] as? String{
                        self.goalLinks = editLink
                    }
                    if let selfLink = links[YonaConstants.jsonKeys.yonaDayDetails] as? [String: AnyObject],
                        let href = selfLink[YonaConstants.jsonKeys.hrefKey] as? String{
                        self.dayDetailLinks = href
                        if let lastPath = NSURL(string: href)?.lastPathComponent {
                            self.activityID = lastPath
                        }
                    }
//                }
//            }
        }
    }
    
    func addGoalsAndActivity(goals : [Goal],  activities : [Activities]){
        for goal in goals {
            if goalLinks == goal.selfLinks {
                maxDurationMinutes = goal.maxDurationMinutes
                goalName = goal.GoalName
                goalType = goal.goalType
                spreadCells = goal.spreadCells
                zones = goal.zones
                maxDurationMinutes = goal.maxDurationMinutes
                for activity in activities {
                    if activity.selfLinks == goal.activityCategoryLink {
                        goalName = activity.activityCategoryName
                        activityID = activity.activityID
                    }
                    
                }

            }
            
        }
    }
        
}