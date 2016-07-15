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
    weak var activityGoal : ActivitiesGoal!

    override func layoutSubviews() {
        super.layoutSubviews()
        drawTheCell()
    }

    override func awakeFromNib() {
        gradientView.setGradientSmooth(UIColor.yiBgGradientOneColor(), color2: UIColor.yiBgGradientTwoColor())

    }
    
    func drawTheCell (){
        
        nogoType.text = activityGoal.goalName
        if activityGoal.goalAccomplished {
            self.nogoMessage.text = "geen hits, hou vol"
            self.nogoImage.image = R.image.adultHappy
        } else {
            self.nogoImage.image = R.image.adultSad
            let dateFromat = NSDateFormatter()
            dateFromat.dateFormat = "hh:mm a"
            let date = dateFromat.stringFromDate(activityGoal.date)
            self.nogoMessage.text =  "\(date) - \(String(activityGoal.totalMinutesBeyondGoal)) minuten"
        }
    }
    
    func setDataForView(activityGoal : ActivitiesGoal) {
        self.activityGoal = activityGoal
    }
    
}