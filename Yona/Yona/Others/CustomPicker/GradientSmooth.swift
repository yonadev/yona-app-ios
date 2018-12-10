//
//  GradientSmooth.swift
//  Yona
//
//  Created by Ben Smith on 14/07/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation
class GradientSmooth: GradientView {

    func setGradientSmooth(_ color1: UIColor, color2: UIColor) {
        
        // 1
        self.backgroundColor = UIColor.white
        
        // 2
        gradientLayer.frame = CGRect(origin: self.bounds.origin, size: CGSize(width: UIScreen.main.bounds.width, height: self.bounds.height))
        
        // 3
        let color1 = color1.cgColor as CGColor
        let color2 = color2.cgColor as CGColor
        gradientLayer.colors = [color1, color2]
        
        // 4
        gradientLayer.locations = [0.0, 0.5]
        
        // 5
        self.layer.addSublayer(gradientLayer)
        
    }
    func setSolid(_ color1: UIColor) {
        self.backgroundColor = color1
        gradientLayer.removeFromSuperlayer()
    }
}
