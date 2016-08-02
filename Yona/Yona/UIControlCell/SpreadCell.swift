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
    var pxWidthPerSpread : CGFloat = 4
    var pxGap : CGFloat = 0

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
        pxWidthPerSpread = pxWidthPerSpread.roundNearest(1)
        pxPerMinute = self.backgroundMinsView.frame.size.height / 15 //calculate pix per minute height wise
        pxGap = (self.backgroundMinsView.frame.size.width - pxWidthPerSpread * 96) / 95
        
        fourleftConstraint.constant = backgroundMinsView.frame.origin.x +  (16 * pxWidthPerSpread + 15 * pxGap) - fourAm.frame.size.width/2
        self.fourAm.setNeedsLayout()
        
        eightAmConstraint.constant = backgroundMinsView.frame.origin.x +  (32 * pxWidthPerSpread + 31 * pxGap) - eightAM.frame.size.width/2
        self.eightAM.setNeedsLayout()
        
        sixteenHundredConstraint.constant = backgroundMinsView.frame.origin.x +  (64 * pxWidthPerSpread + 64 * pxGap) - sixteenHundred.frame.size.width/2
        self.sixteenHundred.setNeedsLayout()
        
        twentyHundredConstraint.constant = backgroundMinsView.frame.origin.x +  (80 * pxWidthPerSpread + 79 * pxGap) - twentyHundred.frame.size.width/2
        self.twentyHundred.setNeedsLayout()
    }
    
    func drawTheCell (){
        //test data, indicates where the activity is  how long it occurred for , if the spreadCells array has a value at cell colour blue, else colour red (outside)
//        spreadCells = [15,15,15,15,0,15,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,15,0,0,0,0,0,0,0,0,0,0,0,15,0,0,0,0,0,0,0,0,0,0,0,0]
        var spreadCellsValue = 0
        
        self.message.text = NSLocalizedString("meday.spreadcontrol.minutestotal", comment: "")
        let spreadY = self.backgroundMinsView.frame.size.height

        //draw the spreadcells where the user has set timezones
        for currentSpread in spreadCells {
            let spreadX = CGFloat(spreadCellsValue) * CGFloat(pxWidthPerSpread + pxGap) //value int
            print("This is my x \(spreadX)")
            let spreadCellView = SpreadCellCustomView.init(frame: CGRectZero, colour: UIColor.clearColor())
            determineCellColour(spreadCellView, spreadCellsValue: spreadCellsValue, currentSpread: currentSpread)

            if currentSpread > 0 {
                pxSpreadHeight = pxPerMinute * CGFloat(currentSpread)
                spreadCellView.frame = CGRectMake(spreadX, spreadY - pxSpreadHeight, pxWidthPerSpread, pxSpreadHeight)
            } else {
                pxSpreadHeight = pxWidthPerSpread
                spreadCellView.frame = CGRectMake(spreadX, spreadY - pxSpreadHeight, pxWidthPerSpread, pxSpreadHeight)
            }
            backgroundMinsView.addSubview(spreadCellView)
            spreadCellsValue += 1
        }
        
        
        //set goal title
        self.goalType.text = NSLocalizedString("meday.spreadcontrol.title", comment: "")
        
        //set minutes title
        self.minutesUsed.textColor = UIColor.yiBlackColor()
        self.minutesUsed.text = String(totalActivityDurationMinutes)
        
    }
    
    func determineCellColour(spreadCellView: SpreadCellCustomView, spreadCellsValue: Int, currentSpread: Int){
        if currentSpread > 0 {
            if activitySpread.count == 0 {
                if totalMinutesBeyondGoal > 0 {
                    spreadCellView.backgroundColor = UIColor.yiDarkishPinkColor()
                } else {
                    spreadCellView.backgroundColor = UIColor.yiMidBlueColor()
                }
            } else {
                if activitySpread.contains(spreadCellsValue) {
                    spreadCellView.backgroundColor = UIColor.yiMidBlueColor()
                } else {
                    spreadCellView.backgroundColor = UIColor.yiDarkishPinkColor()
                }
            }
        } else {
            spreadCellView.backgroundColor = UIColor.yiGraphBarOneColor()
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