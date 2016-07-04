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
    @IBOutlet weak var minutes: UILabel!
    @IBOutlet weak var goalMessage: UILabel!
    @IBOutlet weak var minsView: UIView!
    @IBOutlet weak var backgroundMinsView: UIView!
    @IBOutlet weak var startMinutes: UILabel!
    @IBOutlet weak var endMinutes: UILabel!
    
    @IBOutlet weak var horizontalSpaceingConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setUpView(activityGoal : ActivitiesGoal) {
    
        let neg = activityGoal.totalMinutesBeyondGoal
        let positive = activityGoal.totalActivityDurationMinutes - activityGoal.totalMinutesBeyondGoal
        
        let totalMinutes = neg + positive
        let pxPrMinute = backgroundMinsView.frame.size.width / CGFloat(totalMinutes)
        
        let negattveView = UIView(frame: CGRectMake(CGFloat(neg)*pxPrMinute,0,0,backgroundMinsView.frame.size.height))
        negattveView.backgroundColor = UIColor.redColor()
        negattveView.alpha = 0
        
        let positiveView = UIView(frame: CGRectMake(CGFloat(neg)*pxPrMinute,0,CGFloat(positive)*pxPrMinute,backgroundMinsView.frame.size.height))
        positiveView.backgroundColor = UIColor.greenColor()
        positiveView.alpha = 0
        
        backgroundMinsView.addSubview(negattveView)
        backgroundMinsView.addSubview(positiveView)
        
        var positiveFrame : CGRect = positiveView.frame
        positiveFrame.size.width = 0
        
        var negFrame = negattveView.frame
        negFrame.size.width = CGFloat(neg) * pxPrMinute
        negFrame.origin.x = 0
        
        positiveView.alpha = 1
        negattveView.alpha = 1
        
        UIView.animateWithDuration(2, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                positiveView.frame = positiveFrame
            }, completion: {finished in
                UIView.animateWithDuration(2, animations: {
                    negattveView.frame = negFrame
                })
        })
    }

}