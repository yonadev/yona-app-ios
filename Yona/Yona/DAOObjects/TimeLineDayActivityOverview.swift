//
//  TimeLineDayActivityOverview.swift
//  Yona
//
//  Created by Anders Liebl on 04/08/2016.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

class TimeLineDayActivityOverview: NSObject {
    
    var date : Date
    var timezone :String
    var activites : [TimeLineDayActivities] = []
    var tableViewCells : [AnyObject] = []
    var rowCount = 0
    init(jsonData: BodyDataDictionary, activities : [Activities]) {
        date = Date()
        var storage : [TimeLineDayActivities] = []
        tableViewCells = []
        if let activityDate = jsonData[YonaConstants.jsonKeys.date] as? String {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = getMessagesKeys.dateFormatSimple.rawValue
            if let aDate = dateFormatter.date(from: activityDate) {
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
        
        activites = storage.sorted(by: {$0.activityCategoryLink > $1.activityCategoryLink})
    }
    
    func configureForTableView(_ allBuddies :[Buddies], aUser : Users) {
        tableViewCells = []
        for obj in activites{
            var cat = ""

            if let txt = obj.activityCategoryName {
                cat = txt
            }
            for row in obj.userData {
                row.setBuddyOrUser(allBuddies, aUser: aUser)
                row.goalName = cat
                
            }
            var validData = false
            for row in obj.userData {
//                if row.goalType == "NoGoGoal" && !row.goalAccomplished {
//                    validData = true
//                } else if row.goalType != "NoGoGoal" {
                    validData = true
//                }
            }

            if validData {
                if let txt = obj.activityCategoryName {
                    tableViewCells.append(txt as AnyObject)
                }
                for row in obj.userData {
                    tableViewCells.append(row)
                }
            }
        }
    }
}
