//
//  TimeBucketControlCell.swift
//  Yona
//
//  Created by Anders Liebl on 28/06/2016.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation
import UIKit

class TimeBucketControlCell : UITableViewCell {
    
    @IBOutlet weak var goalType: UILabel!
    @IBOutlet weak var minutesTitle: UILabel!
    @IBOutlet weak var goalMessage: UILabel!
   // @IBOutlet weak var minsView: UIView!

    @IBOutlet weak var positiveView: UIView!
    @IBOutlet weak var negativeView: UIView!
    @IBOutlet weak var zeroMins: UILabel!
    @IBOutlet weak var backgroundMinsView: UIView!
    
    @IBOutlet weak var zeroMinsConstraint: NSLayoutConstraint!
    @IBOutlet weak var minutesBeyondGoal: UILabel!
    @IBOutlet weak var endMinutes: UILabel!
    
    @IBOutlet weak var horizontalSpaceingConstraint: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        negativeView.backgroundColor = UIColor.redColor()
        negativeView.alpha = 0
        
        positiveView.backgroundColor = UIColor.greenColor()
        positiveView.alpha = 0
        
        zeroMins.text = "0"
        zeroMins.font = UIFont(name: "SFUIDisplay-Regular", size: 11)
        zeroMins.textColor = UIColor.yiBlackColor()
        zeroMins.alpha = 0.5

    }
    
    func setUpView(activityGoal : ActivitiesGoal, animated: Bool) {

        
        
        let neg = 10//activityGoal.totalMinutesBeyondGoal
        let positive = 30//activityGoal.totalActivityDurationMinutes - activityGoal.totalMinutesBeyondGoal
        
        let totalMinutes = neg + positive
        
        var pxPrMinute : CGFloat = 0.0 //number of pixels per minute
        if totalMinutes > 0 {
            pxPrMinute = backgroundMinsView.frame.size.width / CGFloat(totalMinutes)
        }
        
        negativeView.frame = CGRectMake(CGFloat(neg) * pxPrMinute, 0, 0, backgroundMinsView.frame.size.height)
        
        positiveView.frame =  CGRectMake(CGFloat(neg) * pxPrMinute, 0, CGFloat(positive) * pxPrMinute, backgroundMinsView.frame.size.height)
        
        var positiveFrame : CGRect = positiveView.frame
        positiveFrame.size.width = 0
        
        var negFrame = negativeView.frame
        negFrame.size.width = CGFloat(neg) * pxPrMinute
        negFrame.origin.x = 0
        
        positiveView.alpha = 1
        negativeView.alpha = 1
        
        if (animated) {
            UIView.animateWithDuration(2, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                    self.positiveView.frame = positiveFrame
                }, completion: {finished in
                    UIView.animateWithDuration(2, animations: {
                        self.negativeView.frame = negFrame
                    })
            })
        } else {
            positiveView.frame = positiveFrame
            negativeView.frame = negFrame
        }
        
        //set the end minutes
        if let maxMins = activityGoal.maxDurationMinutes {
            self.endMinutes.text = String(maxMins)
        }
        
        //set beyond goal label minutes
        if neg == 0 {
            self.minutesBeyondGoal.hidden = true
        }
        self.minutesBeyondGoal.text = "-\(neg)"
        
        //set position of the zero point
        let zeroMinsFrametemp = self.endMinutes.frame
        
        
        // THE backgroundview holds both the neg view and the pos view, so
        // use the backgroundviews indent (x) as base for the label 
        let indent = backgroundMinsView.frame.origin.x
        zeroMinsConstraint.constant = CGFloat(neg) * pxPrMinute + zeroMins.frame.size.width
        zeroMins.setNeedsLayout()
        
        //set minutes title
        if neg != 0 {
            self.minutesTitle.textColor = UIColor.yiDarkishPinkColor()
            self.minutesTitle.text = String(neg)
            self.goalMessage.text = NSLocalizedString("meday.message.minutesover", comment: "")
        } else {
            self.minutesTitle.text = String(positive)
            self.goalMessage.text = NSLocalizedString("meday.message.minutesleft", comment: "")
        }
        
        //set goal title
        self.goalType.text = activityGoal.goalName
        
    }

}