//
//  WeekScoreControlCell.swift
//  Yona
//
//  Created by Anders Liebl on 30/06/2016.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

class WeekScoreControlCell: UITableViewCell {
    

    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var goalTypeLabel: UILabel!

    
    
    @IBOutlet weak var day1CircelView: WeekCircleView!
    @IBOutlet weak var day2CircelView: WeekCircleView!
    @IBOutlet weak var day3CircelView: WeekCircleView!
    @IBOutlet weak var day4CircelView: WeekCircleView!
    @IBOutlet weak var day5CircelView: WeekCircleView!
    @IBOutlet weak var day6CircelView: WeekCircleView!
    @IBOutlet weak var day7CircelView: WeekCircleView!

    
    
    
    func setSingleActivity(theActivityGoal : WeekSingleActivityGoal) {
       
        let userCalendar = NSCalendar.init(calendarIdentifier: NSGregorianCalendar)
        userCalendar?.firstWeekday = 1
        scoreLabel.text = "\(theActivityGoal.numberOfDaysGoalWasReached)"
        goalTypeLabel.text = theActivityGoal.goalName
        for index in 0...6 {
            let periodComponents = NSDateComponents()
            periodComponents.weekday = index-1
            let aDate = userCalendar!.dateByAddingComponents(
                periodComponents,
                toDate: theActivityGoal.date,
                options: [])!

            
            
            //let aDate = theActivityGoal.date.dateByAddingTimeInterval(-Double(index)*60*60*24)
            let obje :  WeekCircleView = self.valueForKey("day\(index+1)CircelView") as! WeekCircleView
            var tempStatus : circleViewStatus = circleViewStatus.noData
            for dayActivity in theActivityGoal.activity {
                if dayActivity.dayofweek.rawValue == getDayOfWeek(aDate) {
                    if dayActivity.goalAccomplished {
                        tempStatus = .underGoal
                    } else if !dayActivity.goalAccomplished {
                        tempStatus =  .overGoal
                    } else {
                        tempStatus =  .noData
                    }
                }
            }
            obje.configureUI(aDate, status: tempStatus)
        }
    }
    
    func getDayOfWeek(theDate:NSDate)->Int {
        let myCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        myCalendar.firstWeekday = 1
        
        let myComponents = myCalendar.components(.Weekday, fromDate: theDate)
        let weekDay = myComponents.weekday
        return weekDay
    }
}