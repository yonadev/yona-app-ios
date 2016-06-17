//
//  GradientView.swift
//  Yona
//
//  Created by Chandan on 13/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

class GradientView: UIView {
    var shapeLayer = CAShapeLayer()
    
    // Default Colors
    var colors:[UIColor] = [] {
        didSet {
            setGradient(colors[0], color2: colors[1])
        }
    }
    
    func setGradient(color1: UIColor, color2: UIColor) {
        
        shapeLayer.frame = self.bounds
        shapeLayer.path = getPath()
        shapeLayer.lineWidth = 1.0
        shapeLayer.strokeColor = color1.CGColor
        shapeLayer.fillColor = color2.CGColor
        
        self.layer.insertSublayer(shapeLayer, atIndex: 0)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.shapeLayer.path = getPath()
    }
    
    func getPath() -> CGPath {
        let size = self.bounds.size
        let path = CGPathCreateMutable()
        
        CGPathMoveToPoint(path, nil, 0, 0)
//        CGPathAddLineToPoint(path, nil, (size.width/3)*2, 0)
//        CGPathAddLineToPoint(path, nil, 0, size.height)
        CGPathAddLineToPoint(path, nil, size.width, 0)
        CGPathAddLineToPoint(path, nil, 0, size.height)
        CGPathAddLineToPoint(path, nil, 0, 0)
        
        return path
    }
}