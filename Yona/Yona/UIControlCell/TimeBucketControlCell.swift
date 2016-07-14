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
    @IBOutlet weak var gradientView: GradientSmooth!

    weak var positiveView: UIView!
    
    weak var negativeView: UIView!
    weak var activityGoal : ActivitiesGoal!
    var shouldAnimate : Bool = false
    
    @IBOutlet weak var zeroMins: UILabel!
    @IBOutlet weak var backgroundMinsView: UIView!
    
    @IBOutlet weak var zeroMinsConstraint: NSLayoutConstraint!
    @IBOutlet weak var minutesBeyondGoal: UILabel!
    @IBOutlet weak var endMinutes: UILabel!
    
    @IBOutlet weak var horizontalSpaceingConstraint: NSLayoutConstraint!
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        doInitialSetup()
        drawTheCell(shouldAnimate)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        gradientView.setGradientSmooth(UIColor.yiBgGradientOneColor(), color2: UIColor.yiBgGradientTwoColor())
        zeroMins.text = "0"
        zeroMins.font = UIFont(name: "SFUIDisplay-Regular", size: 11)
        zeroMins.textColor = UIColor.yiBlackColor()
        zeroMins.alpha = 0.5
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func setUpView(activityGoal : ActivitiesGoal) {
        
        var aView  = UIView(frame:CGRectMake( 0, 0, backgroundMinsView.frame.size.width , 32))
        
        positiveView = aView
        backgroundMinsView.addSubview(positiveView)
        
        
        aView  = UIView(frame:CGRectMake(10, 0, 0, 32))
        negativeView = aView
        backgroundMinsView.addSubview(negativeView)

    }
    
    func doInitialSetup() {
    
        var fra = backgroundMinsView.frame
        fra.size.width = frame.size.width-64
        backgroundMinsView.frame = fra
        
        let negative = activityGoal!.totalMinutesBeyondGoal
        var positive = activityGoal!.maxDurationMinutes - activityGoal!.totalActivityDurationMinutes
        if positive < 0 { positive = 0}
        let totalMinutes = activityGoal!.totalActivityDurationMinutes
       
        print("backgroundMinsView : \(backgroundMinsView)")
        
        var pxPrMinute : CGFloat = 0.0 //number of pixels per minute
        if totalMinutes > 0 {
            pxPrMinute = (backgroundMinsView.frame.size.width) / CGFloat(totalMinutes)
        }
        var aViewframe = CGRectMake( CGFloat(negative) * pxPrMinute, 0, (backgroundMinsView.frame.size.width) - CGFloat(negative) * pxPrMinute , 32)
        positiveView.frame = aViewframe
        
        aViewframe  = CGRectMake(CGFloat(negative) * pxPrMinute, 0, 0, 32)
        negativeView.frame = aViewframe

        negativeView.backgroundColor = UIColor.yiDarkishPinkColor()
        
        positiveView.backgroundColor = UIColor.yiPeaColor()
        
        positiveView.alpha = 1
        negativeView.alpha = 1
        //set the end minutes

        self.endMinutes.text = String(activityGoal!.maxDurationMinutes)
        
        //set beyond goal label minutes
        if negative == 0 {
            self.minutesBeyondGoal.hidden = true
        }
        self.minutesBeyondGoal.text = "-\(negative)"
        
        
        // THE backgroundview holds both the neg view and the pos view, so
        // use the backgroundviews indent (x) as base for the label 
     //   let indent = backgroundMinsView.frame.origin.x
        zeroMinsConstraint.constant = CGFloat(negative) * pxPrMinute + zeroMins.frame.size.width
        zeroMins.setNeedsLayout()
        
        //set minutes title
        if negative != 0 {
            self.minutesTitle.textColor = UIColor.yiDarkishPinkColor()
            self.minutesTitle.text = String(negative)
            self.goalMessage.text = NSLocalizedString("meday.message.minutesover", comment: "")
        } else {
            self.minutesTitle.text = String(positive)
            self.goalMessage.text = NSLocalizedString("meday.message.minutesleft", comment: "")
        }
        
        //set goal title
        self.goalType.text = activityGoal!.goalName
        
    }

    
    func setDataForView (activityGoal : ActivitiesGoal,animated: Bool) {
        self.activityGoal = activityGoal
        shouldAnimate = animated
    }
    func drawTheCell (animated: Bool) {
        let negative = activityGoal!.totalMinutesBeyondGoal
        var positive = activityGoal!.maxDurationMinutes - activityGoal!.totalActivityDurationMinutes
        if positive < 0 { positive = 0}
        
        var totalMinutes = activityGoal!.maxDurationMinutes + activityGoal!.totalMinutesBeyondGoal
        if totalMinutes == 0 {
            totalMinutes = activityGoal!.maxDurationMinutes
        }
        
        if positive < 0 {
            positive = 0
        }
     
        var pxPrMinute : CGFloat = 0.0 //number of pixels per minute
        if totalMinutes > 0 {
            //pxPrMinute = (backgroundMinsView.frame.size.width + 8) / CGFloat(totalMinutes)
            pxPrMinute = (backgroundMinsView.frame.size.width) / CGFloat(totalMinutes)
        }

        var positiveFrame = positiveView.frame
        positiveFrame.origin.x = CGFloat(negative) * pxPrMinute
        positiveFrame.size.width = CGFloat(positive) * pxPrMinute

        var negativeFrame = negativeView.frame
        negativeFrame.origin.x = 0
        negativeFrame.size.width = CGFloat(negative) * pxPrMinute
        
        if animated {
            UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseOut,
                                       animations: {
                                        self.positiveView.frame = positiveFrame
                }, completion: {finished in
                    UIView.animateWithDuration(0.3, animations: {
                        self.negativeView.frame = negativeFrame
                    })
                    
            } )
        } else {
            self.positiveView.frame = positiveFrame
            self.negativeView.frame = negativeFrame
        }
    
    }
    
    override func prepareForReuse() {
        backgroundMinsView.subviews.forEach({ $0.removeFromSuperview() })
    }
}