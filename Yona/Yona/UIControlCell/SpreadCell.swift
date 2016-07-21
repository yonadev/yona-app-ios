//
//  SpreadCell.swift
//  Yona
//
//  Created by Ben Smith on 20/07/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation
class SpreadCell : UITableViewCell {
    
    //time labels
    @IBOutlet weak var fourAm: UILabel!
    @IBOutlet weak var eightAM: UILabel!
    @IBOutlet weak var sixteenHundred: UILabel!
    @IBOutlet weak var twentyHundred: UILabel!
    
    @IBOutlet weak var goalType: UILabel!
    @IBOutlet weak var minutesUsed: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var backgroundMinsView: UIView!
    @IBOutlet weak var gradientView: GradientSmooth!
    
    @IBOutlet weak var twentyHundredConstraint: NSLayoutConstraint!
    @IBOutlet weak var sixteenHundredConstraint: NSLayoutConstraint!
    @IBOutlet weak var eightAmConstraint: NSLayoutConstraint!
    @IBOutlet weak var fourleftConstraint: NSLayoutConstraint!
    weak var outsideTimeZoneView: UIView!
    weak var insideTimeZoneView: UIView!
    weak var weekActivity : WeekSingleActivityDetail!
    
    var pxPerSpread : CGFloat = 0
    var pxPerMinute : CGFloat = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        gradientView.setGradientSmooth(UIColor.yiBgGradientOneColor(), color2: UIColor.yiBgGradientTwoColor())
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        doInitialSetup()
        drawTheCell()
    }
    
    func doInitialSetup() {
        
        var fra = backgroundMinsView.frame
        fra.size.width = frame.size.width-64
        backgroundMinsView.frame = fra
        
        pxPerSpread = self.backgroundMinsView.frame.size.width / 96
        pxPerMinute = pxPerSpread / 15
        
        fourleftConstraint.constant = 16 * pxPerSpread + self.backgroundMinsView.frame.origin.x - fourAm.frame.size.width/2
        self.fourAm.setNeedsLayout()
        
        eightAmConstraint.constant = 32 * pxPerSpread + self.backgroundMinsView.frame.origin.x - eightAM.frame.size.width/2
        self.eightAM.setNeedsLayout()
        
        sixteenHundredConstraint.constant = 64 * pxPerSpread + self.backgroundMinsView.frame.origin.x - sixteenHundred.frame.size.width/2
        self.sixteenHundred.setNeedsLayout()
        
        twentyHundredConstraint.constant = 80 * pxPerSpread + self.backgroundMinsView.frame.origin.x - twentyHundred.frame.size.width/2
        self.twentyHundred.setNeedsLayout()
    }
    
    func drawTheCell (){
        //test data, indicates where the activity is  how long it occurred for , if the spreadCells array has a value at cell colour blue, else colour red (outside)
        //var spreadCells = [15,15,15,15,0,15,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,15,0,0,0,0,0,0,0,0,0,0,0,15,0,0,0,0,0,0,0,0,0,0,0,0]
        var spreadCells = self.weekActivity.spreadCells
        var spreadCellsValue = 0
        
        self.message.text = NSLocalizedString("meday.spreadcontrol.minutestotal", comment: "")
        
        //draw the spreadcells where the user has set timezones
        for currentSpread in weekActivity.spreadCells {
            var spreadX = CGFloat(currentSpread) * CGFloat(pxPerSpread) //value int
            let spreadWidth = CGFloat(pxPerSpread)//CGFloat(currentSpread) * CGFloat(pxPerMinute)
            let spreadCellView = SpreadCellCustomView.init(frame: CGRectMake(spreadX, 40, 10, spreadWidth), colour: UIColor.yiGraphBarOneColor())
//            spreadCellView = UIView(frame: CGRectMake(spreadX, 0, spreadWidth, 32))
            spreadCellView.backgroundColor = UIColor.yiPeaColor()
            backgroundMinsView.addSubview(spreadCellView)
            spreadCellsValue += 1
            spreadX += 5
        }
        
        //draw the activity
        //blue cells
        //red cells
//        var spreadValue = 0        
        //change spreadTest to
        //activityGoal.spread
//        for spreadCell in spreadCells {
//            //set frame of timezone
//            let timeZoneView = TimeZoneCustomView.init(frame: CGRectMake(spreadValue * , <#T##y: CGFloat##CGFloat#>, <#T##width: CGFloat##CGFloat#>, <#T##height: CGFloat##CGFloat#>), colour: UIColor.yiGraphBarOneColor())
//            if activityGoal.spreadCells.contains(spreadValue){ //if activity goal spread cells contains
//                timeZoneView.timeZoneColour = UIColor.yiMidBlueColor()
//            } else {
//                timeZoneView.timeZoneColour = UIColor.yiDarkishPinkColor()
//            }
//            
//            //calculate width of timezone, get value in that cell times by pixels per min
//            timeZoneView.spreadWidth = CGFloat(spreadCell) * pxPerMinute
//            timeZoneView.rightAlign(spreadValue, spreadCells: spreadCells, pxPerMinute: pxPerMinute, pxPerSpread: pxPerSpread)
//            backgroundMinsView.addSubview(timeZoneView)
//            spreadValue += 1
//            
//        }
        
        //set goal title
        self.goalType.text = NSLocalizedString("meday.spreadcontrol.title", comment: "")
        
        //set minutes title
        if weekActivity.totalMinutesBeyondGoal != 0 {
            self.minutesUsed.textColor = UIColor.yiDarkishPinkColor()
            self.minutesUsed.text = String(weekActivity.totalMinutesBeyondGoal)
        } else {
            self.minutesUsed.text = String(weekActivity.totalActivityDurationMinutes)
        }
    }

    override func prepareForReuse() {
        backgroundMinsView.subviews.forEach({ $0.removeFromSuperview() })
    }
    
    
    func setWeekActivityDetailForView (weekActivityDetail: WeekSingleActivityDetail,animated: Bool) {
        self.weekActivity = weekActivityDetail
//        totalMinutesBeyondGoal = weekActivityDetail.totalMinutesBeyondGoal
//        maxDurationMinutes = weekActivityDetail.maxDurationMinutes
//        totalActivityDurationMinutes = weekActivityDetail.totalActivityDurationMinutes
//        
//        goalName = NSLocalizedString("meweek.message.minutesAverage", comment: "")
//        
//        shouldAnimate = animated
    }
}