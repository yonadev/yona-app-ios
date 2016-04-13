//
//  Activities.swift
//  Yona
//
//  Created by Ben Smith on 13/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation
struct Activities {
    var activityCategoryName: String?
    var applicationsStore:[String] = []
    var mandatoryNoGo: Bool?
    var editLinks: String?
    var selfLinks: String?
    var activities:[Activities] = []
    
    init(activityData: BodyDataDictionary) {
        
        if let embedded = activityData[YonaConstants.jsonKeys.embedded],
            let embeddedActivities = embedded[YonaConstants.jsonKeys.activityCategories] as? NSArray{
            for activity in embeddedActivities {
                if let activityCategoryName = activity[YonaConstants.jsonKeys.name] as? String {
                    self.activityCategoryName = activityCategoryName
                }
                if let applications = activity[YonaConstants.jsonKeys.applications] as? NSArray {
                    for application in applications {
                        applicationsStore.append(application as! String)
                    }
                }
                if let mandatoryNoGo = activity[YonaConstants.jsonKeys.mandatoryNoGo] as? Bool {
                    self.mandatoryNoGo = mandatoryNoGo
                }
                
                if let links = activity[YonaConstants.jsonKeys.linksKeys] as? [String: AnyObject]{
                    if let edit = links[YonaConstants.jsonKeys.editLinkKeys] as? [String: AnyObject],
                        let editLink = edit[YonaConstants.jsonKeys.hrefKey] as? String{
                        self.editLinks = editLink
                    }
                    if let selfLink = links[YonaConstants.jsonKeys.selfLinkKeys] as? [String: AnyObject],
                        let href = selfLink[YonaConstants.jsonKeys.hrefKey] as? String{
                        self.selfLinks = href
                    }
                }
                self.activities.append(self)
            }
        }
    }
}