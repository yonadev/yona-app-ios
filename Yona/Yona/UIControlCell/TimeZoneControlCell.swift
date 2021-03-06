//
//  TimeZoneControlCell.swift
//  Yona
//
//  Created by Ben Smith on 07/07/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation
class TimeZoneControlCell : UITableViewCell {
    
    //time labels
    @IBOutlet weak var fourAm: UILabel!
    @IBOutlet weak var eightAM: UILabel!
    @IBOutlet weak var sixteenHundred: UILabel!
    @IBOutlet weak var twentyHundred: UILabel!

    @IBOutlet weak var goalType: UILabel?
    @IBOutlet weak var minutesUsed: UILabel?
    @IBOutlet weak var message: UILabel?
    @IBOutlet weak var backgroundMinsView: UIView!
    @IBOutlet weak var gradientView: GradientSmooth!

    @IBOutlet weak var twentyHundredConstraint: NSLayoutConstraint!
    @IBOutlet weak var sixteenHundredConstraint: NSLayoutConstraint!
    @IBOutlet weak var eightAmConstraint: NSLayoutConstraint!
    @IBOutlet weak var fourleftConstraint: NSLayoutConstraint!
    weak var outsideTimeZoneView: UIView!
    weak var insideTimeZoneView: UIView!
    var shouldAnimate : Bool = false

    var pxPerSpread : CGFloat = 0
    var pxPerMinute : CGFloat = 0
    
    var spreadCells : [Int] = []
    var activitySpread : [Int] = []
    var totalMinutesBeyondGoal = 0
    var totalActivityDurationMinutes = 0
    
    var goalNameText = ""
    
    var fourLeftIndent : CGFloat = 16
    var eightLeftIndent : CGFloat = 32
    var sixteenLeftIndent : CGFloat = 64
    var twentyLeftIndent : CGFloat = 80
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layoutIfNeeded()
        setupGradient()
        doInitialSetup()
        drawTheCell()
    }

    func setupGradient () {
//        gradientView.setGradientSmooth(UIColor.yiBgGradientTwoColor(), color2: UIColor.yiBgGradientOneColor())
        
    }

    
    func doInitialSetup() {
        if goalType != nil {
            goalType!.text = goalNameText
        }
        var fra = backgroundMinsView.frame
        fra.size.width = frame.size.width-64
        backgroundMinsView.frame = fra
        
        pxPerSpread = self.backgroundMinsView.frame.size.width / 96
        pxPerMinute = pxPerSpread / 15
        
        fourleftConstraint.constant = fourLeftIndent * pxPerSpread - fourAm.frame.size.width/2
        self.fourAm.setNeedsLayout()
        
        eightAmConstraint.constant = eightLeftIndent * pxPerSpread - eightAM.frame.size.width/2
        self.eightAM.setNeedsLayout()
        
        sixteenHundredConstraint.constant = sixteenLeftIndent * pxPerSpread - sixteenHundred.frame.size.width/2
        self.sixteenHundred.setNeedsLayout()
        
        twentyHundredConstraint.constant = twentyLeftIndent * pxPerSpread - twentyHundred.frame.size.width/2
        self.twentyHundred.setNeedsLayout()
    }
    
    func drawTheCell (){
        //test data, indicates where the activity is  how long it occurred for , if the spreadCells array has a value at cell colour blue, else colour red (outside)
        //var spreadCells = [15,15,15,15,0,15,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,15,0,0,0,0,0,0,0,0,0,0,0,15,0,0,0,0,0,0,0,0,0,0,0,0]
        
        //var spreadCells = activityGoal.spread
        var spreadCellsValue = 0
        if message != nil {
            message!.text = NSLocalizedString("meday.message.timezone", comment: "")
        }
        //draw the spreadcells where the user has set timezones
        for currentSpread in activitySpread {
            let spreadX = CGFloat(currentSpread) * CGFloat(pxPerSpread) //value int
            let spreadWidth = CGFloat(pxPerSpread)//CGFloat(currentSpread) * CGFloat(pxPerMinute)
            let timeZoneView = UIView(frame: CGRect(x: spreadX, y: 0, width: spreadWidth, height: backgroundMinsView.frame.height))
            timeZoneView.backgroundColor = UIColor.yiPeaColor()
            backgroundMinsView.addSubview(timeZoneView)
            spreadCellsValue += 1
        }
        
        //draw the activity
        //blue cells
        //red cells
        var spreadValue = 0
        
        //change spreadTest to
        //activityGoal.spread
        var timeWithinTimeZone = 0
        var timeOutsideTimeZone = 0

        for spreadCell in spreadCells {
            //set frame of timezone
            let timeZoneView = TimeZoneCustomView.init(frame: CGRect.zero)
            timeZoneView.animated = self.shouldAnimate
            if activitySpread.contains(spreadValue){ //if activity goal spread cells contains
                timeZoneView.timeZoneColour = UIColor.yiMidBlueColor()
                timeWithinTimeZone += spreadCell
            } else {
                timeZoneView.timeZoneColour = UIColor.yiDarkishPinkColor()
                timeOutsideTimeZone += spreadCell
            }
            
            //calculate width of timezone, get value in that cell times by pixels per min
            timeZoneView.spreadWidth = CGFloat(spreadCell) * pxPerMinute
            timeZoneView.rightAlign(spreadValue, spreadCells: spreadCells, pxPerMinute: pxPerMinute, pxPerSpread: pxPerSpread)
            backgroundMinsView.addSubview(timeZoneView)
            spreadValue += 1
            
        }
        if minutesUsed != nil {
            minutesUsed!.text = String(timeOutsideTimeZone)
        }
        //set minutes title
        if totalMinutesBeyondGoal != 0 {
            if minutesUsed != nil {
                minutesUsed!.textColor = UIColor.yiDarkishPinkColor()
            }
        } else {
            if minutesUsed != nil {
                minutesUsed!.textColor = UIColor.yiBlackColor()
            }
        }
    }
    
    func setDataForView (_ activityGoal : ActivitiesGoal, animated: Bool) {
        self.shouldAnimate = animated
        spreadCells = activityGoal.spread
        activitySpread = activityGoal.spreadCells
        if let txt = activityGoal.goalName {
            goalNameText = txt
        }
        totalMinutesBeyondGoal = activityGoal.totalMinutesBeyondGoal
        totalActivityDurationMinutes = activityGoal.totalActivityDurationMinutes
    }
    
    func setDayActivityDetailForView (_ dayActivity: DaySingleActivityDetail, animated: Bool) {
        self.shouldAnimate = animated
        spreadCells = dayActivity.daySpread
        activitySpread = dayActivity.spreadCells
        goalNameText = NSLocalizedString("meweek.message.score", comment: "")
        totalMinutesBeyondGoal = dayActivity.totalMinutesBeyondGoal
        totalActivityDurationMinutes = dayActivity.totalActivityDurationMinutes
    }
    
    override func prepareForReuse() {
        backgroundMinsView.subviews.forEach({ $0.removeFromSuperview() })
    }
}
