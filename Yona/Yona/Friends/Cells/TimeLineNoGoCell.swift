//
//  NoGoView.swift
//  Yona
//
//  Created by Ben Smith on 12/07/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

class TimeLineNoGoCell : UITableViewCell {
    
    @IBOutlet weak var nogoImage: UIImageView!
    @IBOutlet weak var personName: UILabel!
    @IBOutlet weak var nogoMessage: UILabel!
    @IBOutlet weak var gradientView: GradientSmooth!
    var goalAccomplished: Bool = false
    var goalName: String = NSLocalizedString("meday.nogo.message", comment: "")
    var goalDate: NSDate = NSDate()
    var totalMinutesBeyondGoal: Int = 0
    
    override func layoutSubviews() {
        super.layoutSubviews()
       // drawTheCell()
    }

    override func awakeFromNib() {
      //  gradientView.setGradientSmooth(UIColor.yiBgGradientOneColor(), color2: UIColor.yiBgGradientTwoColor())

    }
    
    func drawTheCell (){
        
        
        if goalAccomplished {
            self.nogoMessage.text = NSLocalizedString("meday.nogo.message", comment: "")
            self.nogoImage.image = R.image.adultHappy
        } else {
            self.nogoImage.image = R.image.adultSad
            let dateFromat = NSDateFormatter()
            dateFromat.dateFormat = "hh:mm a"
            let date = dateFromat.stringFromDate(goalDate)
            self.nogoMessage.text =  "\(date) - \(String(totalMinutesBeyondGoal)) \(NSLocalizedString("meday.nogo.minutes", comment: ""))"
        }
    }
    
    
    func setData(timelineData : TimeLinedayActivitiesForUsers) {
        
        if timelineData.totalMinutesBeyondGoal > 0 {
            self.goalAccomplished = false
            self.nogoImage.image = R.image.adultSad
            let dateFromat = NSDateFormatter()
            dateFromat.dateFormat = "hh:mm a"
            let date = dateFromat.stringFromDate(goalDate)
            self.nogoMessage.text =  "\(date) - \(String(totalMinutesBeyondGoal)) \(NSLocalizedString("meday.nogo.minutes", comment: ""))"
        } else {
            self.nogoImage.image = R.image.adultHappy
            self.nogoMessage.text = NSLocalizedString("meday.nogo.message", comment: "")
        }
        
//        if let firstname =  timelineData.user?.firstName {
//            if let last = timelineData.user?.lastName {
//                personName.text = firstname + " " + last
//            }
//        } else if let firstname =  timelineData.buddy?.UserRequestfirstName {
//            if let last = timelineData.buddy?.UserRequestlastName {
//                personName.text = firstname + " " + last
//            }
        if let txt =  timelineData.user?.nickname {
                personName.text = txt
        } else if let txt = timelineData.buddy?.buddyNickName {
            personName.text = txt
        }
        else {
            personName.text = ""
        }
        self.totalMinutesBeyondGoal = timelineData.totalMinutesBeyondGoal
    }
    
    
}