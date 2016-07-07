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
    @IBOutlet weak var backgroundMinsView: UIView!

    weak var outsideTimeZoneView: UIView!
    weak var insideTimeZoneView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    

    func setUpView(activityGoal : ActivitiesGoal) {
        
        let pxPerSpread = self.backgroundMinsView.frame.size.width / 96
        let pxPerMinute = pxPerSpread / 15

        var spreadValue = 0
        for currentSpread in activityGoal.spread {
            let spreadX = CGFloat(spreadValue) * pxPerSpread
            let spreadWidth = CGFloat(currentSpread) * pxPerMinute
            let timeZoneView = UIView(frame: CGRectMake(spreadX, 0, spreadWidth, 32))
            timeZoneView.backgroundColor = UIColor.yiPeaColor()
            backgroundMinsView.addSubview(timeZoneView)
            spreadValue += 1
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