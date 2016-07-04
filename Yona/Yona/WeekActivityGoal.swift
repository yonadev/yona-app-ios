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
            let userCalendar = NSCalendar.init(calendarIdentifier: NSGregorianCalendar)//NSCalendarIdentifierISO8601)
            userCalendar?.firstWeekday = 1
            let formatter = NSDateFormatter()
            formatter.dateFormat = "YYYY'-W'ww"
            formatter.locale = NSLocale.currentLocale()
//            let calendar = NSCalendar.currentCalendar()
//            
//            calendar.firstWeekday = 1;
            formatter.calendar = userCalendar;

            if let startdate = formatter.dateFromString(adDate) {
                date = startdate//.dateByAddingTimeInterval(60*60*3)
            }
            
/*            let weekdayAndWeekdayOrdinal: NSCalendarUnit = [.Weekday, .WeekdayOrdinal]
            let tenDaysFromNowComponents = userCalendar.components(
                weekdayAndWeekdayOrdinal,
                fromDate: startdate!)
            let t = tenDaysFromNowComponents.weekday
            let b = tenDaysFromNowComponents.weekdayOrdinal
            
            let periodComponents = NSDateComponents()
            periodComponents.weekday = 1
            var then = userCalendar.dateByAddingComponents(
                periodComponents,
                toDate: NSDate(),
                options: [])!
            
            print(then)
            periodComponents.weekday = 2
            then = userCalendar.dateByAddingComponents(
                periodComponents,
                toDate: NSDate(),
                options: [])!
            print(then)*/
//            let gregorian = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
//            //gregorian.firstWeekday = 2 // Monday
//            //gregorian.minimumDaysInFirstWeek = 4
//            let components =
//                gregorian.components(ymdhmsUnitFlags, fromDate: date)
//            let dayOfset = 6
//            components.set
//            
//            //components.setDay(
//            if let greg :NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierISO8601) {
//                greg.locale = NSLocale.currentLocale()
//                greg.minimumDaysInFirstWeek = 4
//                greg.firstWeekday = 2
//                
//                let comp = greg.components( .NSWeekCalendarUnit , fromDate: startdate!)
//                //comp.yearForWeekOfYear = 2016
////                comp.year = 2016
//                    comp.weekOfYear = 27
////                comp.weekday = 1
//                if let aDate = greg.dateFromComponents(comp) {
//                    date = aDate
//                }
//                let components = NSDateComponents()
//                components.year = 2016
//                components.weekOfYear = 27
            
//            }


        }
        if let singleWeek = data[YonaConstants.jsonKeys.weekActivities] as? [BodyDataDictionary] {
            for object in singleWeek  {
                let singleWeekObj = WeekSingleActivityGoal(data: object, allGoals : allGoals)
                singleWeekObj.date = self.date
                activity.append(singleWeekObj)
            }
        }
    }
    
}