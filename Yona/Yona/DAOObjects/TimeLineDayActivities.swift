//
//  TimeLinedayActivities.swift
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

class TimeLineDayActivities : NSObject {
    
    var activityCategoryName: String?

    var activityCategoryLink : String?
    var userData : [TimeLinedayActivitiesForUsers] = []

    init(jsonData: BodyDataDictionary) {
        //date = aDate
        //activites = theActivities.sort({$0.dayDetailLinks > $1.dayDetailLinks}) //sort in alphabetical order
    
        if let links = jsonData[YonaConstants.jsonKeys.linksKeys] as? [String: AnyObject]{
            if let edit = links[YonaConstants.jsonKeys.yonaActivityCategory] as? [String: AnyObject],
                let link = edit[YonaConstants.jsonKeys.hrefKey] as? String{
                activityCategoryLink = link
            }
        }
        
        if let arr = jsonData[YonaConstants.jsonKeys.dayActivitiesForUsers] as? [AnyObject] {
            for data in arr {
                let obj =  TimeLinedayActivitiesForUsers(jsonData: data as! BodyDataDictionary)
                
                userData.append(obj)
            }
    
            print("Found \(userData.count) object")
        }
        userData = userData.sorted(by: {$0.goalLink > $1.goalLink})
    }
    
    func setActivity(_ activity : Activities) {
        activityCategoryName = activity.activityCategoryName

    }
}
