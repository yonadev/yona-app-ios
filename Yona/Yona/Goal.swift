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
    var maxDurationMinutes: Int?
    var selfLinks: String?
    var editLinks: String?
    var activityCategoryLink: String?
    var goalType: String?
    var zonesStore:[String] = []
    var isMandatory: Bool?

    init(goalData: BodyDataDictionary) {
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
                    
                    //depending on what activity link we have in our goal this determines the name!
                    switch self.activityCategoryLink! {
                    case YonaConstants.ActivityCategoryLinkID.Gambling:
                        self.GoalName = CategoryName.gamblingString.rawValue
                    case YonaConstants.ActivityCategoryLinkID.News:
                        self.GoalName = CategoryName.newsString.rawValue
                    case YonaConstants.ActivityCategoryLinkID.Social:
                        self.GoalName = CategoryName.socialString.rawValue
                    default:
                        self.GoalName = "Unknown"
                    }
                }
            }
            
            if let zones = goalData[YonaConstants.jsonKeys.zones] as? NSArray {
                for zone in zones {
                    self.zonesStore.append(zone as! String)
                }
            }
            
            if let maxDurationMinutes = goalData[YonaConstants.jsonKeys.maxDuration] as? Int {
                self.maxDurationMinutes = maxDurationMinutes
            }
            if let goalType = goalData[YonaConstants.jsonKeys.goalType] as? String {
                self.goalType = goalType
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