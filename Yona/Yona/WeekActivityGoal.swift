//
//  WeekActivityGoal.swift
//  Yona
//
//  Created by Anders Liebl on 29/06/2016.
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

class WeekActivityGoal: NSObject {
    var date : Date  = Date()
    var activity : [WeekSingleActivityGoal] = []
    
    
    init(data : BodyDataDictionary, allGoals : [Goal] ) {
        if let adDate = data[YonaConstants.jsonKeys.date] as? String {
            var userCalendar = Calendar.init(identifier: Calendar.Identifier.iso8601)//NSGregorianCalendar)
            userCalendar.firstWeekday = 1
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY'-W'ww"
            //formatter.locale = NSLocale.currentLocale()
            formatter.locale = Locale(identifier: "en_US")
            formatter.calendar = userCalendar;

            if let startdate = formatter.date(from: adDate) {
                date = startdate
            }
            

        }
        if let singleWeek = data[YonaConstants.jsonKeys.weekActivities] as? [BodyDataDictionary] {
            for object in singleWeek  {
                let singleWeekObj = WeekSingleActivityGoal(data: object, allGoals : allGoals)
                if singleWeekObj.goalType != nil {
                    singleWeekObj.date = self.date
                    activity.append(singleWeekObj)
                }
            }
        }
        activity = activity.sorted(by: {$0.goalName > $1.goalName})

    }
    
}
