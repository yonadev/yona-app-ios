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
    let gradientLayer = CAGradientLayer()
    
    @IBInspectable var gradientColor: UIColor! {
        didSet{
            self.awakeFromNib()
        }
    }
    
    @IBInspectable var gradientColor2: UIColor! {
        didSet{
            self.awakeFromNib()
        }
    }
    
    // Default Colors
    var colors:[UIColor] = [] {
        didSet {
            setGradient(colors[0], color2: colors[1])
        }
    }
    
    func setGradient(_ color1: UIColor, color2: UIColor) {
        gradientColor = color1
        gradientColor2 = color2
        shapeLayer.frame = self.bounds
        shapeLayer.path = getPath()
        shapeLayer.lineWidth = 1.0
        shapeLayer.strokeColor = gradientColor.cgColor
        shapeLayer.fillColor = gradientColor2.cgColor
        
        self.layer.insertSublayer(shapeLayer, at: 0)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.shapeLayer.path = getPath()

    }
    
    func getPath() -> CGPath {
        let size = self.bounds.size
        let path = CGMutablePath()
        
        //CGPathMoveToPoint(path, nil, 0, 0)
        path.move(to: CGPoint(x:0,y:0))
        
        //CGPathAddLineToPoint(path, nil, (size.width/3)*2, 0)
        path.addLine(to: CGPoint(x:(size.width/3)*2,y:0))
        
        //CGPathAddLineToPoint(path, nil, 0, size.height-15)
        path.addLine(to: CGPoint(x:0,y:size.height-15))

        // CGPathAddLineToPoint(path, nil, 0, 0)
        path.addLine(to: CGPoint(x:0,y:0))

        return path
    }
}
