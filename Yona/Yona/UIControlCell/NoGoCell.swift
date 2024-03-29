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
    var goalDate: Date = Date()
    var totalMinutesBeyondGoal: Int = 0
    
    override func layoutSubviews() {
        contentView.layoutIfNeeded()
        setupGradient()
        drawTheCell()
    }

    func setupGradient () {
        gradientView.setGradientSmooth(UIColor.yiBgGradientTwoColor(), color2: UIColor.yiBgGradientOneColor())
        
    }
    

    
    
    func drawTheCell (){
        
        nogoType.text = goalName
        if goalAccomplished {
            self.nogoMessage.text = NSLocalizedString("meday.nogo.message", comment: "")
            self.nogoImage.image = R.image.adultHappy()
        } else {
            self.nogoImage.image = R.image.adultSad()
            let dateFromat = DateFormatter()
            dateFromat.dateFormat = "HH:mm"
            let date = dateFromat.string(from: goalDate)
            self.nogoMessage.text =  "\(totalMinutesBeyondGoal) " + "\(NSLocalizedString("meday.nogo.minutes", comment: ""))"
        }
    }
    
    func setDataForView(_ activityGoal : ActivitiesGoal) {
        goalAccomplished = activityGoal.goalAccomplished
        self.goalDate = activityGoal.date as Date
        self.totalMinutesBeyondGoal = activityGoal.totalMinutesBeyondGoal
        if let goalName = activityGoal.goalName{
            self.goalName = goalName
        }
    }
    
    func setDayActivityDetailForView(_ activityGoal : DaySingleActivityDetail) {
        goalAccomplished = activityGoal.goalAccomplished
        if let goalDate = activityGoal.date {
            self.goalDate = goalDate as Date
        }
        self.goalName = NSLocalizedString("meweek.message.score", comment: "")
        self.totalMinutesBeyondGoal = activityGoal.totalMinutesBeyondGoal
    }
    
    func setDataForWeekDetailView(_ activityGoal : WeekSingleActivityDetail) {
        if activityGoal.totalMinutesBeyondGoal > 0 {
            self.goalAccomplished = false
        }
        self.goalName = NSLocalizedString("meweek.message.score", comment: "")
        
        self.totalMinutesBeyondGoal = activityGoal.totalMinutesBeyondGoal
    }
    
    
}
