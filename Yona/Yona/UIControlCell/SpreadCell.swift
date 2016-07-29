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
    
    var pxSpreadHeight : CGFloat = 2
    var pxPerMinute : CGFloat = 0
    var pxWidthPerSpread : CGFloat = 2
    
    var spreadCells : [Int] = []
    var activitySpread : [Int] = []
    var totalMinutesBeyondGoal = 0
    var totalActivityDurationMinutes = 0
    
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
        var spreadCellsValue = 0
        
        self.message.text = NSLocalizedString("meday.spreadcontrol.minutestotal", comment: "")
        let spreadY = self.backgroundMinsView.frame.size.height

        //draw the spreadcells where the user has set timezones
        for currentSpread in spreadCells {
            var spreadX = CGFloat(spreadCellsValue) * CGFloat(pxWidthPerSpread) //value int

            let spreadCellView = SpreadCellCustomView.init(frame: CGRectZero, colour: UIColor.clearColor())
            if currentSpread > 0 {
                pxSpreadHeight = pxPerMinute * CGFloat(currentSpread)
                spreadCellView.frame = CGRectMake(spreadX, spreadY - pxSpreadHeight, pxWidthPerSpread, pxSpreadHeight)
                if spreadCells.contains(spreadCellsValue) {
                    spreadCellView.backgroundColor = UIColor.yiPeaColor()
                } else {
                    spreadCellView.backgroundColor = UIColor.yiDarkishPinkColor()
                }
            } else {
                pxSpreadHeight = pxWidthPerSpread
                spreadCellView.frame = CGRectMake(spreadX, spreadY - pxSpreadHeight, pxWidthPerSpread, pxSpreadHeight)
                spreadCellView.backgroundColor = UIColor.yiGraphBarOneColor()
            }
            backgroundMinsView.addSubview(spreadCellView)
            spreadCellsValue += 2
            spreadX += 5
        }
        
        
        //set goal title
        self.goalType.text = NSLocalizedString("meday.spreadcontrol.title", comment: "")
        
        //set minutes title
        if totalMinutesBeyondGoal > 0 {
            self.minutesUsed.textColor = UIColor.yiDarkishPinkColor()
            self.minutesUsed.text = String(totalActivityDurationMinutes)
        } else {
            self.minutesUsed.textColor = UIColor.yiBlackColor()
            self.minutesUsed.text = String(totalActivityDurationMinutes)
        }
    }

    override func prepareForReuse() {
        backgroundMinsView.subviews.forEach({ $0.removeFromSuperview() })
    }
    
    func setWeekActivityDetailForView (weekActivityDetail: WeekSingleActivityDetail,animated: Bool) {
        self.totalMinutesBeyondGoal = weekActivityDetail.totalMinutesBeyondGoal
        self.totalActivityDurationMinutes = weekActivityDetail.totalActivityDurationMinutes
        self.spreadCells = weekActivityDetail.weekSpread
        self.activitySpread = weekActivityDetail.spreadCells
    }

    func setDayActivityDetailForView (dayActivity: DaySingleActivityDetail, animated: Bool) {
        self.totalMinutesBeyondGoal = dayActivity.totalMinutesBeyondGoal
        self.totalActivityDurationMinutes = dayActivity.totalActivityDurationMinutes
        self.spreadCells = dayActivity.daySpread
        self.activitySpread = dayActivity.spreadCells
    }
}