//
//  TimeLineTimeBucketCell.swift
//  Yona
//
//  Created by Anders Liebl on 06/08/2016.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

class TimeLineTimeBucketCell : UITableViewCell {
    @IBOutlet weak var userIcon: UIImageView!
    @IBOutlet weak var userInitial: UILabel!
    
    @IBOutlet weak var gradientView: GradientSmooth!
    
    weak var positiveView: UIView!
    weak var negativeView: UIView!
    var isWeek : Bool = false
    
    var totalMinutesBeyondGoal = 0
    var maxDurationMinutes = 0
    var totalActivityDurationMinutes = 0
    var averageActivityDurationMinutes = 0
    //var goalName = ""
    
    var shouldAnimate : Bool = false
    
    @IBOutlet weak var zeroMins: UILabel!
    @IBOutlet weak var backgroundMinsView: UIView!
    
    @IBOutlet weak var zeroMinsConstraint: NSLayoutConstraint!
    @IBOutlet weak var minutesBeyondGoal: UILabel!
    @IBOutlet weak var endMinutes: UILabel!

    var firstName = ""
    var lastName = ""
    
    //MARK: - override methods
    override func layoutSubviews() {
        super.layoutSubviews()
        setUpView()
        doInitialSetup()
        drawTheCell(shouldAnimate)
        dravTheUser()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //gradientView.setGradientSmooth(UIColor.yiBgGradientOneColor(), color2: UIColor.yiBgGradientTwoColor())
        zeroMins.text = "0"
        zeroMins.font = UIFont(name: "SFUIDisplay-Regular", size: 11)
        zeroMins.textColor = UIColor.yiBlackColor()
        zeroMins.alpha = 0.5
    }
    
    override func prepareForReuse() {
        backgroundMinsView.subviews.forEach({ $0.removeFromSuperview() })
        
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
        
        
        userInitial.text = ""
        userInitial.textColor = UIColor.yiWhiteColor()
        
        
        userIcon.layer.borderWidth = 0.0
        userIcon.layer.masksToBounds = true
        userIcon.layer.cornerRadius = userIcon.frame.size.width/2
        userIcon.backgroundColor = UIColor.yiGrapeColor()
    }

    private func dravTheUser () {
    
        //will crash if empty
        if firstName.characters.count > 0 && lastName.characters.count > 0{
            userInitial.text =  "\(firstName.capitalizedString.characters.first!) \(lastName.capitalizedString.characters.first!)"
        }

    }
    
    private func doInitialSetup() {
        
//        var fra = backgroundMinsView.frame
//        fra.size.width = frame.size.width-64
//        backgroundMinsView.frame = fra
        
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
        zeroMinsConstraint.constant = backgroundMinsView.frame.origin.y+9 + CGFloat(negative) * pxPrMinute + zeroMins.frame.size.width
        zeroMins.setNeedsLayout()
        
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
    
    func setData(timeline : TimeLinedayActivitiesForUsers,animated: Bool) {
    
        totalMinutesBeyondGoal = timeline.totalMinutesBeyondGoal
        maxDurationMinutes = timeline.maxDurationMinutes
        totalActivityDurationMinutes = timeline.totalActivityDurationMinutes
        if let bud = timeline.buddy {
            firstName = bud.UserRequestfirstName
            lastName = bud.UserRequestlastName
        } else if let theUser = timeline.user {
            firstName = theUser.firstName
            lastName = theUser.lastName
        }

        
        shouldAnimate = animated
    }


}