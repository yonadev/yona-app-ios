//
//  TimeZoneControlCell.swift
//  Yona
//
//  Created by Ben Smith on 07/07/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation
class TimeZoneControlCell : UITableViewCell {
    
    @IBOutlet weak var goalType: UILabel!
    @IBOutlet weak var minutesUsed: UILabel!
    @IBOutlet weak var message: UILabel!
    
    weak var timeZoneView: UIView!
    weak var outsideTimeZoneView: UIView!
    weak var insideTimeZoneView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    func setUpView(activityGoal : ActivitiesGoal) {
        
        for currentSpread in activityGoal.spread {
            //
            print(currentSpread)
            timeZoneView = CGRectMake(currentSpread * , <#T##y: CGFloat##CGFloat#>, <#T##width: CGFloat##CGFloat#>, <#T##height: CGFloat##CGFloat#>)
        }
        
        //set goal title
        self.goalType.text = activityGoal.goalName
        
        //set minutes title
        if activityGoal.totalMinutesBeyondGoal != 0 {
            self.minutesUsed.textColor = UIColor.yiDarkishPinkColor()
            self.minutesUsed.text = String(activityGoal.totalMinutesBeyondGoal)
        } else {
            self.minutesUsed.text = String(activityGoal.totalActivityDurationMinutes)
        }
    }
}