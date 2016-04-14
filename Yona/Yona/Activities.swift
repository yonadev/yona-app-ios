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
    var activityID: String?
    var applicationsStore:[String] = []
    var mandatoryNoGo: Bool?
    var editLinks: String?
    var selfLinks: String?
    
    init(activityData: BodyDataDictionary) {
        if let activityCategoryName = activityData[YonaConstants.jsonKeys.name] as? String {
            self.activityCategoryName = activityCategoryName
        }
        if let applications = activityData[YonaConstants.jsonKeys.applications] as? NSArray {
            for application in applications {
                applicationsStore.append(application as! String)
            }
        }
        if let mandatoryNoGo = activityData[YonaConstants.jsonKeys.mandatoryNoGo] as? Bool {
            self.mandatoryNoGo = mandatoryNoGo
        }
        
        if let links = activityData[YonaConstants.jsonKeys.linksKeys] as? [String: AnyObject]{
            if let edit = links[YonaConstants.jsonKeys.editLinkKeys] as? [String: AnyObject],
                let editLink = edit[YonaConstants.jsonKeys.hrefKey] as? String{
                self.editLinks = editLink
            }
            if let selfLink = links[YonaConstants.jsonKeys.selfLinkKeys] as? [String: AnyObject],
                let href = selfLink[YonaConstants.jsonKeys.hrefKey] as? String{
                self.selfLinks = href
                if let lastPath = NSURL(string: href)?.lastPathComponent {
                    self.activityID = lastPath
                }
            }
        }
    }
}