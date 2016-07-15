//
//  GradientSmooth.swift
//  Yona
//
//  Created by Ben Smith on 14/07/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation
class GradientSmooth: GradientView {

    func setGradientSmooth(color1: UIColor, color2: UIColor) {
        
        // 1
        self.backgroundColor = UIColor.greenColor()
        
        // 2
        gradientLayer.frame = self.bounds
        
        // 3
        let color1 = color1.CGColor as CGColorRef
        let color2 = color2.CGColor as CGColorRef
        gradientLayer.colors = [color1, color2]
        
        // 4
        gradientLayer.locations = [0.0, 0.5]
        
        // 5
        self.layer.addSublayer(gradientLayer)
        
    }
}