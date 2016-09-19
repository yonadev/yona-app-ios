//
//  NoGoView.swift
//  Yona
//
//  Created by Ben Smith on 12/07/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

class NoGoCell : UITableViewCell {
    
    @IBOutlet weak var nogoImage: UIImageView!
    @IBOutlet weak var nogoType: UILabel!
    @IBOutlet weak var nogoMessage: UILabel!
    @IBOutlet weak var gradientView: GradientSmooth!
    var goalAccomplished: Bool = false
    var goalName: String = NSLocalizedString("meday.nogo.message", comment: "")
    var goalDate: NSDate = NSDate()
    var totalMinutesBeyondGoal: Int = 0
    
    override func layoutSubviews() {
        contentView.layoutIfNeeded()
        setupGradient()
        drawTheCell()
    }

    func setupGradient () {
        gradientView.setGradientSmooth(UIColor.yiBgGradientOneColor(), color2: UIColor.yiBgGradientTwoColor())
        
    }
    

    
    
    func drawTheCell (){
        
        nogoType.text = goalName
        if goalAccomplished {
            self.nogoMessage.text = NSLocalizedString("meday.nogo.message", comment: "")
            self.nogoImage.image = R.image.adultHappy
        } else {
            self.nogoImage.image = R.image.adultSad
            let dateFromat = NSDateFormatter()
            dateFromat.dateFormat = "hh:mm a"
            let date = dateFromat.stringFromDate(goalDate)
            self.nogoMessage.text =  "\(NSLocalizedString("meday.nogo.minutes", comment: ""))"
        }
    }
    
    func setDataForView(activityGoal : ActivitiesGoal) {
        goalAccomplished = activityGoal.goalAccomplished
        self.goalDate = activityGoal.date
        self.totalMinutesBeyondGoal = activityGoal.totalMinutesBeyondGoal
        if let goalName = activityGoal.goalName{
            self.goalName = goalName
        }
    }
    
    func setDayActivityDetailForView(activityGoal : DaySingleActivityDetail) {
        goalAccomplished = activityGoal.goalAccomplished
        if let goalDate = activityGoal.date {
            self.goalDate = goalDate
        }
        self.goalName = activityGoal.goalName
        self.totalMinutesBeyondGoal = activityGoal.totalMinutesBeyondGoal
    }
    
    func setDataForWeekDetailView(activityGoal : WeekSingleActivityDetail) {
        if activityGoal.totalMinutesBeyondGoal > 0 {
            self.goalAccomplished = false
        }
        if let goalName = activityGoal.goalName {
            self.goalName = goalName
        }
        self.totalMinutesBeyondGoal = activityGoal.totalMinutesBeyondGoal
    }
    
    
}