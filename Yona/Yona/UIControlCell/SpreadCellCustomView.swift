//
//  SpreadCellCustomView.swift
//  Yona
//
//  Created by Ben Smith on 20/07/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

class SpreadCellCustomView: UIView {
    
    var spreadX : CGFloat = 0
    var spreadWidth : CGFloat?
    var spreadHeight : CGFloat = 32
    var timeZoneColour : UIColor?
    
    init(frame: CGRect, colour: UIColor) { // for using CustomView in code
        super.init(frame: frame)
        spreadX = frame.origin.x
        spreadWidth = frame.size.width
        timeZoneColour = colour
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}