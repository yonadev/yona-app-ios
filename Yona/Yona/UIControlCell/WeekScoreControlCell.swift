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
    @IBOutlet weak var goalMessage: UILabel!
    @IBOutlet weak var gradientView: GradientSmooth!
    
    @IBOutlet weak var day1CircelView: WeekCircleView!
    @IBOutlet weak var day2CircelView: WeekCircleView!
    @IBOutlet weak var day3CircelView: WeekCircleView!
    @IBOutlet weak var day4CircelView: WeekCircleView!
    @IBOutlet weak var day5CircelView: WeekCircleView!
    @IBOutlet weak var day6CircelView: WeekCircleView!
    @IBOutlet weak var day7CircelView: WeekCircleView!

    
    @IBOutlet weak var firstLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var secondLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var fourthLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var lastLayoutConstraint: NSLayoutConstraint!
    
    
    weak var aActivityGoal : WeekSingleActivityGoal!
    weak var delegate : MeDashBoardMainViewController?
    
    override func layoutSubviews() {
        var width = frame.width
        width -= day1CircelView.frame.size.width*7+(2*32)
        let distanceBetweenEach = width / 7
        firstLayoutConstraint.constant = distanceBetweenEach
        secondLayoutConstraint.constant = distanceBetweenEach
        fourthLayoutConstraint.constant = distanceBetweenEach
        lastLayoutConstraint.constant = distanceBetweenEach
        
    }
    
    func setSingleActivity(theActivityGoal : WeekSingleActivityGoal, isScore :Bool = false) {
        aActivityGoal = theActivityGoal
        self.goalMessage.text = NSLocalizedString("meweek.message.timescompleted", comment: "")
        
        let userCalendar = NSCalendar.init(calendarIdentifier: NSGregorianCalendar)
        userCalendar?.firstWeekday = 1
        scoreLabel.text = "\(aActivityGoal.numberOfDaysGoalWasReached)"
        if !isScore {
            goalTypeLabel.text = aActivityGoal.goalName
        } else {
            goalTypeLabel.text = NSLocalizedString("meweek.message.score", comment: "")
        }
        for index in 0...6 {
            let periodComponents = NSDateComponents()
            periodComponents.weekday = index-1
            let aDate = userCalendar!.dateByAddingComponents(
                periodComponents,
                toDate: aActivityGoal.date,
                options: [])!

            
            
            //let aDate = theActivityGoal.date.dateByAddingTimeInterval(-Double(index)*60*60*24)
            let obje :  WeekCircleView = self.valueForKey("day\(index+1)CircelView") as! WeekCircleView
            var tempStatus : circleViewStatus = circleViewStatus.noData
            for dayActivity in aActivityGoal.activity {
                if dayActivity.dayofweek.rawValue == getDayOfWeek(aDate) {
                    obje.activity = dayActivity
                    if (dayActivity.goalAccomplished) {
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

    @IBAction func singeldayAction(sender : UIButton){
        var aDate : NSDate?
        var aActivity : SingleDayActivityGoal?
        switch sender.tag {
        case 1:
            aDate = day1CircelView.theData
            aActivity = day1CircelView.activity
        case 2:
            aDate = day2CircelView.theData
            aActivity = day2CircelView.activity
        case 3:
            aDate = day3CircelView.theData
            aActivity = day3CircelView.activity
        case 4:
            aDate = day4CircelView.theData
            aActivity = day4CircelView.activity
        case 5:
            aDate = day5CircelView.theData
            aActivity = day5CircelView.activity
        case 6:
            aDate = day6CircelView.theData
            aActivity = day6CircelView.activity
        case 7:
            aDate = day7CircelView.theData
            aActivity = day7CircelView.activity
        default:
            return
        }
        
        if aDate != nil {
            if let activ = aActivity {
                delegate?.didSelectDayInWeek(activ, aDate: aDate!)
            }
        }
    }

}