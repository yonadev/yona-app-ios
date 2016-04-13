//
//  GradientView.swift
//  Yona
//
//  Created by Chandan on 13/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

class GradientView: UIView {
    
    // Default Colors
    var colors:[UIColor] = [] {
        didSet {
            setGradient(colors[0], color2: colors[1])
        }
    }
    
    override func drawRect(rect: CGRect) {
//        setGradient(colors[0], color2: colors[1])
}
    
    func setGradient(color1: UIColor, color2: UIColor) {
        let mask = CAShapeLayer()
        mask.frame = self.layer.bounds
        
        let width = self.layer.frame.size.width
        let height = self.layer.frame.size.height
        
        let path = CGPathCreateMutable()
        
        CGPathMoveToPoint(path, nil, 0, 0)
        CGPathAddLineToPoint(path, nil, (width/3)*2, 0)
        CGPathAddLineToPoint(path, nil, 0, height)
        CGPathAddLineToPoint(path, nil, 0, height)
        CGPathAddLineToPoint(path, nil, 0, 0)
        
        mask.path = path
        
        self.layer.mask = mask
        
        let shape = CAShapeLayer()
        shape.frame = self.bounds
        shape.path = path
        shape.lineWidth = 3.0
        
        shape.strokeColor = color1.CGColor//UIColor.yiGrapeColor().CGColor
        shape.fillColor = color2.CGColor//UIColor.yiGrapeTwoColor().CGColor
        
        self.layer.insertSublayer(shape, atIndex: 0)
        
    }
    override func layoutSubviews() {
        
        // Ensure view has a transparent background color (not required)
//        backgroundColor = UIColor.clearColor()
    }
    
}