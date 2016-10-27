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
    
    @IBOutlet weak var goalTypeTitle: UILabel!
    @IBOutlet weak var minutesTitle: UILabel!
    @IBOutlet weak var goalMessage: UILabel!
    @IBOutlet weak var gradientView: GradientSmooth!

    weak var positiveView: UIView!
    
    weak var negativeView: UIView!
    
    var isWeek : Bool = false
    
    var totalMinutesBeyondGoal = 0
    var maxDurationMinutes = 0
    var totalActivityDurationMinutes = 0
    var averageActivityDurationMinutes = 0
    var goalName = ""

    var shouldAnimate : Bool = false
    
    @IBOutlet weak var zeroMins: UILabel!
    @IBOutlet weak var backgroundMinsView: UIView!
    
    @IBOutlet weak var zeroMinsConstraint: NSLayoutConstraint!
    @IBOutlet weak var minutesBeyondGoal: UILabel!
    @IBOutlet weak var endMinutes: UILabel!
    
    @IBOutlet weak var horizontalSpaceingConstraint: NSLayoutConstraint!
  
    //MARK: - override methods
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layoutIfNeeded()
        setupGradient()
        setUpView()
        doInitialSetup()
        drawTheCell(shouldAnimate)
    }
    
    func setupGradient () {
        gradientView.setGradientSmooth(UIColor.yiBgGradientTwoColor(), color2: UIColor.yiBgGradientOneColor())
    
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        zeroMins.text = "0"
        zeroMins.font = UIFont(name: "SFUIDisplay-Regular", size: 11)
        zeroMins.textColor = UIColor.yiBlackColor()
        zeroMins.alpha = 0.5
    }
    
    override func prepareForReuse() {
        backgroundMinsView.subviews.forEach({ $0.removeFromSuperview() })
        goalName = ""
        totalMinutesBeyondGoal = 0
        maxDurationMinutes = 0
        totalActivityDurationMinutes = 0
        
    }

    //MARK: - private methods
    private func setUpView() {
        
        var aView  = UIView(frame:CGRectMake( 0, 0, backgroundMinsView.frame.size.width , backgroundMinsView.frame.height))
        
        positiveView = aView
        backgroundMinsView.addSubview(positiveView)
        
        
        aView  = UIView(frame:CGRectMake(10, 0, 0, backgroundMinsView.frame.height))
        negativeView = aView
        backgroundMinsView.addSubview(negativeView)

    }
    
    private func doInitialSetup() {
    
        var fra = backgroundMinsView.frame
        fra.size.width = frame.size.width-64
        backgroundMinsView.frame = fra
        
        let negative = totalMinutesBeyondGoal
        var positive = maxDurationMinutes - totalActivityDurationMinutes
        if positive < 0 { positive = 0}
        var totalMinutes = totalActivityDurationMinutes

        if isWeek {
            positive = averageActivityDurationMinutes
            totalMinutes = maxDurationMinutes
        }

        
        var pxPrMinute : CGFloat = 0.0 //number of pixels per minute
        if totalMinutes > 0 {
            pxPrMinute = (backgroundMinsView.frame.size.width) / CGFloat(totalMinutes)
        }
        var aViewframe = CGRectMake( CGFloat(negative) * pxPrMinute, 0, (backgroundMinsView.frame.size.width) - CGFloat(negative) * pxPrMinute , backgroundMinsView.frame.height)
        positiveView.frame = aViewframe
        
        aViewframe  = CGRectMake(CGFloat(negative) * pxPrMinute, 0, 0, backgroundMinsView.frame.height)
        negativeView.frame = aViewframe

        negativeView.backgroundColor = UIColor.yiDarkishPinkColor()
        
        positiveView.backgroundColor = UIColor.yiPeaColor()
        
        positiveView.alpha = 1
        negativeView.alpha = 1
        //set the end minutes

        self.endMinutes.text = String(maxDurationMinutes)
        
        //set beyond goal label minutes
        if negative == 0 {
            self.minutesBeyondGoal.hidden = true
        }
        self.minutesBeyondGoal.text = "-\(negative)"
        
        
        // THE backgroundview holds both the neg view and the pos view, so
        // use the backgroundviews indent (x) as base for the label 
        zeroMinsConstraint.constant = CGFloat(negative) * pxPrMinute + zeroMins.frame.size.width
        zeroMins.setNeedsLayout()
        
        //set minutes title
        if negative != 0 {
            self.minutesTitle.textColor = UIColor.yiDarkishPinkColor()
            self.minutesTitle.text = String(negative)
            self.goalMessage.text = NSLocalizedString("meday.message.minutesover", comment: "")
        } else {
            self.minutesTitle.textColor = UIColor.yiBlackColor()
            self.minutesTitle.text = String(positive)
            self.goalMessage.text = NSLocalizedString("meday.message.minutesleft", comment: "")
        }
        
        //set goal title
        self.goalTypeTitle.text = goalName
        
    }
    
    
    private func drawTheCell (animated: Bool) {
        let negative = totalMinutesBeyondGoal
        
        var positive = maxDurationMinutes - totalActivityDurationMinutes
        if positive < 0 { positive = 0}
        
        var totalMinutes = maxDurationMinutes + totalMinutesBeyondGoal
        if totalMinutes == 0 {
            totalMinutes = maxDurationMinutes
        }
        
        if positive < 0 {
            positive = 0
        }
        if isWeek {
            positive = averageActivityDurationMinutes
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
    
    
//MARK: - cell setter methods
    func setDataForView (activityGoal : ActivitiesGoal,animated: Bool) {
        totalMinutesBeyondGoal = activityGoal.totalMinutesBeyondGoal
        maxDurationMinutes = activityGoal.maxDurationMinutes
        totalActivityDurationMinutes = activityGoal.totalActivityDurationMinutes
        if let txt = activityGoal.goalName {
            goalName = txt
        }
        
        shouldAnimate = animated
    }

    func setWeekActivityDetailForView (weekActivityDetail: WeekSingleActivityDetail,animated: Bool) {
        totalMinutesBeyondGoal = weekActivityDetail.totalMinutesBeyondGoal
        maxDurationMinutes = weekActivityDetail.maxDurationMinutes
        averageActivityDurationMinutes = weekActivityDetail.averageActivityDurationMinutes
        
        goalName = NSLocalizedString("meweek.message.score", comment: "")
        goalMessage.text = NSLocalizedString("meday.spreadcontrol.title", comment: "")

        isWeek = true
        
        shouldAnimate = animated
    }

    func setDayActivityDetailForView (dayActivity: DaySingleActivityDetail, animated: Bool) {
        isWeek = false
        totalMinutesBeyondGoal = dayActivity.totalMinutesBeyondGoal
        maxDurationMinutes = dayActivity.maxDurationMinutes
        totalActivityDurationMinutes = dayActivity.totalActivityDurationMinutes
        
        goalName = NSLocalizedString("meweek.message.score", comment: "")
        
        shouldAnimate = animated
    }
}