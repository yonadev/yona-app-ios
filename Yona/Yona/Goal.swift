//
//  Goals.swift
//  Yona
//
//  Created by Ben Smith on 12/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

struct Goal {
    var activityCategoryName: String?
    var goalID: String?
    var maxDurationMinutes: Int?
    var selfLinks: String?
    var editLinks: String?
    var goalType: YonaConstants.GoalType?
    var zonesStore:[String] = []
    var isMandatory: Bool?

    init(goalData: BodyDataDictionary) {
            if let activityCategoryName = goalData[YonaConstants.jsonKeys.activityCategoryName] as? String {
                self.activityCategoryName = activityCategoryName
            }
            if let zones = goalData[YonaConstants.jsonKeys.zones] as? NSArray {
                for zone in zones {
                    zonesStore.append(zone as! String)
                }
            }
            
            if let maxDurationMinutes = goalData[YonaConstants.jsonKeys.maxDuration] as? Int {
                self.maxDurationMinutes = maxDurationMinutes
            }
            if let goalType = goalData[YonaConstants.jsonKeys.goalType] as? String {
                
                switch goalType {
                case "BudgetGoal":
                    self.goalType = YonaConstants.GoalType.BudgetGoal
                case "TimeZoneGoal":
                    self.goalType = YonaConstants.GoalType.TimeZoneGoal
                case "NoGo":
                    self.goalType = YonaConstants.GoalType.NoGo
                default:
                    break
                }
            }
            
            if let links = goalData[YonaConstants.jsonKeys.linksKeys] as? [String: AnyObject]{
                if let edit = links[YonaConstants.jsonKeys.editLinkKeys] as? [String: AnyObject],
                    let editLink = edit[YonaConstants.jsonKeys.hrefKey] as? String{
                    self.editLinks = editLink
                    self.isMandatory = false
                } else {
                    self.isMandatory = true
                }
                if let selfLink = links[YonaConstants.jsonKeys.selfLinkKeys] as? [String:AnyObject],
                    let href = selfLink[YonaConstants.jsonKeys.hrefKey] as? String{
                    self.selfLinks = href
                    if let lastPath = NSURL(string: href)?.lastPathComponent {
                        self.goalID = lastPath
                    }
                }
            }
    }
}