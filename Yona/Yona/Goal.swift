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
    
    init(userData: BodyDataDictionary) {
        if let activityCategoryName = userData[YonaConstants.jsonKeys.activityCategoryName] as? String {
            self.activityCategoryName = activityCategoryName
        }
        if let maxDurationMinutes = userData[YonaConstants.jsonKeys.maxDuration] as? String {
            self.maxDurationMinutes = maxDurationMinutes
        }
        if let goalType = userData[YonaConstants.jsonKeys.goalType] as? String {
            self.goalType = goalType
        }
        
        if let links = userData[YonaConstants.jsonKeys.linksKeys],
            let edit = links[YonaConstants.jsonKeys.editLinkKeys],
            let editLink = edit?[YonaConstants.jsonKeys.hrefKey] as? String,
            let selfLink = links[YonaConstants.jsonKeys.selfLinkKeys] as? String{
                self.selfLinks = selfLink
                self.editLinks = editLink
        }
    }
}