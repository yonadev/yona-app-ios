//
//  WeekActivityGoal.swift
//  Yona
//
//  Created by Anders Liebl on 29/06/2016.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation
class WeekActivityGoal: NSObject {
    var date : NSDate  = NSDate()
    var activity : [WeekSingleActivityGoal] = []
    
    
    init(data : BodyDataDictionary, allGoals : [Goal] ) {
        if let adDate = data[YonaConstants.jsonKeys.date] as? String {
            let userCalendar = NSCalendar.init(calendarIdentifier: NSGregorianCalendar)
            userCalendar?.firstWeekday = 1
            let formatter = NSDateFormatter()
            formatter.dateFormat = "YYYY'-W'ww"
            formatter.locale = NSLocale.currentLocale()
            formatter.calendar = userCalendar;

            if let startdate = formatter.dateFromString(adDate) {
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
        activity = activity.sort({$0.goalName > $1.goalName})

    }
    
}