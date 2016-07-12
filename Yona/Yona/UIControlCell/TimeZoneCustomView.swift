//
//  TimeZoneView.swift
//  Yona
//
//  Created by Ben Smith on 12/07/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

class TimeZoneCustomView: UIView {
    
    var spreadX : CGFloat = 0
    var spreadWidth : CGFloat?
    var spreadHeight : CGFloat = 32
    var timeZoneColour : UIColor?

    override init(frame: CGRect) {
        super.init(frame: frame)
        spreadX = frame.origin.x
        spreadWidth = frame.size.width
    }
    
    init(frame: CGRect, colour: UIColor) { // for using CustomView in code
        super.init(frame: frame)
        spreadX = frame.origin.x
        spreadWidth = frame.size.width
        timeZoneColour = colour
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func rightAlign (spreadValue: Int, spreadCells : [Int], pxPerMinute: CGFloat, pxPerSpread: CGFloat){
        //right align
        if (spreadValue + 1) < spreadCells.count && (spreadValue - 1) >= 0 { ///don't go out of bounds
            if spreadCells[spreadValue + 1] == 15 //if next cell is full
                && spreadCells[spreadValue] < 15 //And current cell is less than 15
                && spreadCells[spreadValue] > 0 { //and great than 0
                spreadX = (CGFloat(spreadValue) * pxPerSpread) + (pxPerSpread - (CGFloat(spreadCells[spreadValue]) * pxPerMinute)) //then align to right
            } else if spreadCells[spreadValue - 1] == 15 //if previous cell is full
                && spreadCells[spreadValue] < 15 //And current cell is less than 15
                && spreadCells[spreadValue] > 0 { //and great than 0
                spreadX = CGFloat(spreadValue) * pxPerSpread //align to left
            } else { //else centre align
                spreadX = (CGFloat(spreadValue) * pxPerSpread) + (pxPerSpread/2 - spreadWidth!/2) //align in center
            }
        } else {
            spreadX = CGFloat(spreadValue) * pxPerSpread
        }

  // YOU must set the calculated frame and the backgroundcolor
        frame = CGRectMake(spreadX, 0, spreadWidth!, spreadHeight)
        backgroundColor = timeZoneColour
        //print (self)
    }
}