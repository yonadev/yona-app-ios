//
//  Goals.swift
//  Yona
//
//  Created by Ben Smith on 12/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

struct Goal {
    var goalID: String?
    var GoalName: String?
    var maxDurationMinutes: Int!
    var selfLinks: String?
    var editLinks: String?
    var activityCategoryLink: String?
    var goalType: String?
    var zones:[String] = []
    var spreadCells : [Int] = []
    var isMandatory: Bool?
    var isHistoryItem : Bool!
    init(goalData: BodyDataDictionary, activities: [Activities]) {
            if let links = goalData[YonaConstants.jsonKeys.linksKeys] as? [String: AnyObject]{
                if let edit = links[YonaConstants.jsonKeys.editLinkKeys] as? [String: AnyObject],
                    let editLink = edit[YonaConstants.jsonKeys.hrefKey] as? String{
                    self.editLinks = editLink
                }
                if let selfLink = links[YonaConstants.jsonKeys.selfLinkKeys] as? [String:AnyObject],
                    let href = selfLink[YonaConstants.jsonKeys.hrefKey] as? String{
                    self.selfLinks = href
                    if let lastPath = NSURL(string: href)?.lastPathComponent {
                        self.goalID = lastPath
                    }
                }
                if let activityCategoryLink = links[YonaConstants.jsonKeys.yonaActivityCategory] as? [String:AnyObject],
                    let href = activityCategoryLink[YonaConstants.jsonKeys.hrefKey] as? String{
                    self.activityCategoryLink = href
                    
                    for activity in activities {
                        if let activityCategoryLink = activity.selfLinks
                            where self.activityCategoryLink == activityCategoryLink {
                            self.GoalName = activity.activityCategoryName
                        }
                    }
                }
            }
            
            if let zones = goalData[YonaConstants.jsonKeys.zones] as? NSArray {
                for zone in zones {
                    self.zones.append(zone as! String)
                }
            }

            if let spreds = goalData[YonaConstants.jsonKeys.spredCells] as? NSArray {
                for data in spreds {
                    self.spreadCells.append(data as! Int)
                }
            }

            if let maxDurationMinutes = goalData[YonaConstants.jsonKeys.maxDuration] as? Int {
                self.maxDurationMinutes = maxDurationMinutes
            } else {
                self.maxDurationMinutes = 0
            }
            if let goalType = goalData[YonaConstants.jsonKeys.goalType] as? String {
                self.goalType = goalType
            }
            if let history = goalData[YonaConstants.jsonKeys.historyItem] as? Bool {
                    isHistoryItem = history
            } else {
                    isHistoryItem = false
            }
        
            //if goal is of type no go, it has no max minutes, and is type budgetgoal, then mandatory is true
            if self.maxDurationMinutes == 0 && self.goalType == GoalType.BudgetGoalString.rawValue {
                self.isMandatory = true
                self.goalType = GoalType.NoGoGoalString.rawValue
            } else { //else it is not nogo so mandatory is false
                self.isMandatory = false
            }
        
    }
}