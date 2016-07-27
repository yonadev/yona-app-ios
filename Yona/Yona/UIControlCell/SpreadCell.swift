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
    weak var dayActivity : DaySingleActivityDetail!
    
    var pxPerSpreadHeight : CGFloat = 2
    var pxPerMinute : CGFloat = 0
    var pxWidthPerSpread : CGFloat = 2
    
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
        
        pxWidthPerSpread = self.backgroundMinsView.frame.size.width / 192 //double spreadcells for gap 96x2
        pxPerMinute = self.backgroundMinsView.frame.size.height / 15 //calculate pix per minute height wise
        
        fourleftConstraint.constant = 32 * pxWidthPerSpread + self.backgroundMinsView.frame.origin.x - fourAm.frame.size.width/2
        self.fourAm.setNeedsLayout()
        
        eightAmConstraint.constant = 64 * pxWidthPerSpread + self.backgroundMinsView.frame.origin.x - eightAM.frame.size.width/2
        self.eightAM.setNeedsLayout()
        
        sixteenHundredConstraint.constant = 128 * pxWidthPerSpread + self.backgroundMinsView.frame.origin.x - sixteenHundred.frame.size.width/2
        self.sixteenHundred.setNeedsLayout()
        
        twentyHundredConstraint.constant = 160 * pxWidthPerSpread + self.backgroundMinsView.frame.origin.x - twentyHundred.frame.size.width/2
        self.twentyHundred.setNeedsLayout()
    }
    
    func drawTheCell (){
        //test data, indicates where the activity is  how long it occurred for , if the spreadCells array has a value at cell colour blue, else colour red (outside)
        //var spreadCells = [15,15,15,15,0,15,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,15,0,0,0,0,0,0,0,0,0,0,0,15,0,0,0,0,0,0,0,0,0,0,0,0]
        var spreadCells = self.dayActivity
        var spreadCellsValue = 0
        
        self.message.text = NSLocalizedString("meday.spreadcontrol.minutestotal", comment: "")
        let spreadY = self.backgroundMinsView.frame.size.height

        //draw the spreadcells where the user has set timezones
        for currentSpread in dayActivity.daySpread {
            var spreadX = CGFloat(spreadCellsValue) * CGFloat(pxWidthPerSpread) //value int
            var spreadCellheight = pxWidthPerSpread

            let spreadCellView = SpreadCellCustomView.init(frame: CGRectZero, colour: UIColor.clearColor())
            if currentSpread > 0 {
                spreadCellheight = pxWidthPerSpread * CGFloat(currentSpread)
                spreadCellView.frame = CGRectMake(spreadX, spreadY - spreadCellheight, pxWidthPerSpread, spreadCellheight)
                spreadCellView.backgroundColor = UIColor.yiPeaColor()
            } else {
                spreadCellheight = pxWidthPerSpread
                spreadCellView.frame = CGRectMake(spreadX, spreadY - spreadCellheight, pxWidthPerSpread, spreadCellheight)
                spreadCellView.backgroundColor = UIColor.yiPeaColor()
            }
            backgroundMinsView.addSubview(spreadCellView)
            spreadCellsValue += 2
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
//            let timeZoneView = TimeZoneCustomView.init(frame: CGRectMake(spreadValue * , y: CGFloat, width: CGFloat, height: CGFloat), colour: UIColor.yiGraphBarOneColor())
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
//        if dayActivity.totalMinutesBeyondGoal != 0 {
//            self.minutesUsed.textColor = UIColor.yiDarkishPinkColor()
//            self.minutesUsed.text = String(dayActivity.totalMinutesBeyondGoal)
//        } else {
//            self.minutesUsed.text = String(dayActivity.totalActivityDurationMinutes)
//        }
    }

    override func prepareForReuse() {
        backgroundMinsView.subviews.forEach({ $0.removeFromSuperview() })
    }
    
    func setWeekActivityDetailForView (weekActivityDetail: WeekSingleActivityDetail,animated: Bool) {

    }

    func setDayActivityDetailForView (dayActivity: DaySingleActivityDetail,animated: Bool) {
        self.dayActivity = dayActivity
    }
}