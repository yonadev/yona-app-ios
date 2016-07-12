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

    @IBOutlet weak var goalType: UILabel!
    @IBOutlet weak var minutesUsed: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var backgroundMinsView: UIView!

    @IBOutlet weak var twentyHundredConstraint: NSLayoutConstraint!
    @IBOutlet weak var sixteenHundredConstraint: NSLayoutConstraint!
    @IBOutlet weak var eightAmConstraint: NSLayoutConstraint!
    @IBOutlet weak var fourleftConstraint: NSLayoutConstraint!
    weak var outsideTimeZoneView: UIView!
    weak var insideTimeZoneView: UIView!
    
    var pxPerSpread : CGFloat = 0
    var pxPerMinute : CGFloat = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //testSpread
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

    func setUpView(activityGoal : ActivitiesGoal) {
        
        //test data, indicates where the activity is  how long it occurred for , if the spreadCells array has a value at cell colour blue, else colour red (outside)
        var spreadCells = [15,15,15,15,0,15,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,15,0,0,0,0,0,0,0,0,0,0,0,15,0,0,0,0,0,0,0,0,0,0,0,0] //activityGoal.spread//
        
        var spreadCellsValue = 0
        //draw the spreadcells where the user has set timezones
        for currentSpread in activityGoal.spreadCells {
            let spreadX = CGFloat(currentSpread) * CGFloat(pxPerSpread) //value int
            let spreadWidth = CGFloat(currentSpread) * CGFloat(pxPerMinute)
            let timeZoneView = TimeZoneCustomView.init(frame: CGRectMake(spreadX, 0, spreadWidth, 32), colour: UIColor.yiPeaColor())
            backgroundMinsView.addSubview(timeZoneView)
            spreadCellsValue += 1
        }
    
        //draw the activity
        //blue cells
        //red cells
        var spreadValue = 0
        var spreadX = CGFloat(spreadValue) * pxPerSpread

        //change spreadTest to
        //activityGoal.spread
        for spreadCell in spreadCells {
            //set frame of timezone
            
            let timeZoneView = TimeZoneCustomView.init(frame: CGRectMake(0, 0, 0, 32))
            if activityGoal.spreadCells.contains(spreadValue){
                timeZoneView.timeZoneColour = UIColor.yiMidBlueColor()
            } else {
                timeZoneView.timeZoneColour = UIColor.yiDarkishPinkColor()
            }
            
            //calculate width of timezone, get value in that cell times by pixels per min
            timeZoneView.spreadWidth = CGFloat(spreadCell) * pxPerMinute
            
            timeZoneView.rightAlign(spreadValue, spreadCells: spreadCells, pxPerMinute: pxPerMinute, pxPerSpread: pxPerSpread)
            
//            //right align
//            if (spreadValue + 1) < spreadCells.count && (spreadValue - 1) >= 0 { ///don't go out of bounds
//                if spreadCells[spreadValue + 1] == 15 //if next cell is full
//                    && spreadCells[spreadValue] < 15 //And current cell is less than 15
//                    && spreadCells[spreadValue] > 0 { //and great than 0
//                    spreadX = (CGFloat(spreadValue) * pxPerSpread) + (pxPerSpread - (CGFloat(spreadCells[spreadValue]) * pxPerMinute)) //then align to right
//                } else if spreadCells[spreadValue - 1] == 15 //if previous cell is full
//                    && spreadCells[spreadValue] < 15 //And current cell is less than 15
//                    && spreadCells[spreadValue] > 0 { //and great than 0
//                    spreadX = CGFloat(spreadValue) * pxPerSpread //align to left
//                } else { //else centre align
//                    spreadX = (CGFloat(spreadValue) * pxPerSpread) + (pxPerSpread/2 - spreadWidth/2) //align in center
//                }
//            } else {
//                spreadX = CGFloat(spreadValue) * pxPerSpread
//            }
            



            backgroundMinsView.addSubview(timeZoneView)
            spreadValue += 1

        }

        
        //set goal title
        self.goalType.text = activityGoal.goalName
        
        //set minutes title
        if activityGoal.totalMinutesBeyondGoal != 0 {
            self.minutesUsed.textColor = UIColor.yiDarkishPinkColor()
            self.minutesUsed.text = String(activityGoal.totalMinutesBeyondGoal)
        } else {
            self.minutesUsed.text = String(activityGoal.totalActivityDurationMinutes)
        }
    }
}