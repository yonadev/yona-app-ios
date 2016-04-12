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
    var maxDurationMinutes: String?
    var selfLinks: String?
    var editLinks: String?
    var goalType: String?
    var goals:[Goal] = []

    init(goalData: BodyDataDictionary) {
        
        if let embedded = goalData[YonaConstants.jsonKeys.embedded],
            let embeddedGoals = embedded[YonaConstants.jsonKeys.goals] as? NSArray{
                for goal in embeddedGoals {
                    if let activityCategoryName = goal[YonaConstants.jsonKeys.activityCategoryName] as? String {
                        self.activityCategoryName = activityCategoryName
                    }
                    if let maxDurationMinutes = goal[YonaConstants.jsonKeys.maxDuration] as? String {
                        self.maxDurationMinutes = maxDurationMinutes
                    }
                    if let goalType = goal[YonaConstants.jsonKeys.goalType] as? String {
                        self.goalType = goalType
                    }
                    
                    if let links = goal[YonaConstants.jsonKeys.linksKeys] as? [String: AnyObject]{
                        if let edit = links[YonaConstants.jsonKeys.editLinkKeys] as? [String: AnyObject],
                            let editLink = edit[YonaConstants.jsonKeys.hrefKey] as? String{
                            self.editLinks = editLink
                        }
                        if let selfLink = links[YonaConstants.jsonKeys.selfLinkKeys] as? String{
                            self.selfLinks = selfLink
                        }
                    }
                    self.goals.append(self)
                }
        }

        
    }

}