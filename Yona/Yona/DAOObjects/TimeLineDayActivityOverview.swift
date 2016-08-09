//
//  TimeLineDayActivityOverview.swift
//  Yona
//
//  Created by Anders Liebl on 04/08/2016.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation
class TimeLineDayActivityOverview: NSObject {
    
    var date : NSDate
    var timezone :String
    var activites : [TimeLineDayActivities] = []
    var tableViewCells : [AnyObject] = []
    var rowCount = 0
    init(jsonData: BodyDataDictionary, activities : [Activities]) {
        date = NSDate()
        var storage : [TimeLineDayActivities] = []
        tableViewCells = []
        if let activityDate = jsonData[YonaConstants.jsonKeys.date] as? String {
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = getMessagesKeys.dateFormatSimple.rawValue
            if let aDate = dateFormatter.dateFromString(activityDate) {
                date = aDate
            }
        }

        if let txt = jsonData[YonaConstants.jsonKeys.timeZone] as? String {
            timezone = txt
        } else {
            timezone = "undefined"
        }
        
        if let arr = jsonData[YonaConstants.jsonKeys.dayActivities] as? [AnyObject] {
        
            for data in arr {
                let obj =  TimeLineDayActivities(jsonData: data as! BodyDataDictionary)
                storage.append(obj)
                
                
                
            }
            
        }
        
        activites = storage.sort({$0.activityCategoryLink > $1.activityCategoryLink})
    }
    
    func configureForTableView(allBuddies :[Buddies], aUser : Users) {
        tableViewCells = []
        for obj in activites{
            var cat = ""
            if let txt = obj.activityCategoryName {
                tableViewCells.append(txt)
                cat = txt
            }            
            for row in obj.userData {
                row.setBuddyOrUser(allBuddies, aUser: aUser)
                row.goalName = cat
                
                tableViewCells.append(row)
            }
        }
    }
}