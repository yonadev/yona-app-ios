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

struct ActivitiesGoal {
    var activityCategoryName: String?
    var activityID: String?
    var applicationsStore:[String] = []
    var dayDetailLinks: String?
    var goalLinks: String?
    var goalName: String?
    var goalType: String?
    var maxDurationMinutes: Int?
    
    init(activityData: BodyDataDictionary) {
        if let activityCategoryName = activityData[YonaConstants.jsonKeys.name] as? String {
            self.activityCategoryName = activityCategoryName
        }
        if let applications = activityData[YonaConstants.jsonKeys.applications] as? NSArray {
            for application in applications {
                applicationsStore.append(application as! String)
            }
        }
        
        if let links = activityData[YonaConstants.jsonKeys.linksKeys] as? [String: AnyObject]{
            if let edit = links[YonaConstants.jsonKeys.yonaGoals] as? [String: AnyObject],
                let editLink = edit[YonaConstants.jsonKeys.hrefKey] as? String{
                self.goalLinks = editLink
            }
            if let selfLink = links[YonaConstants.jsonKeys.yonadayDetails] as? [String: AnyObject],
                let href = selfLink[YonaConstants.jsonKeys.hrefKey] as? String{
                self.dayDetailLinks = href
                if let lastPath = NSURL(string: href)?.lastPathComponent {
                    self.activityID = lastPath
                }
            }
        }
    }
    func addGoalsData(aGoal : Goal){
    
    }
    func addActivityType( aActivity : [Activities]) {
    
    }
    
}