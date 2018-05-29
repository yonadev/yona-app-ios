//
//  StringExtensions.swift
//  Yona
//
//  Created by Chandan Varma on 30/05/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

extension CALayer {
    
    func configureGradientBackground(_ height:CGFloat, colors:CGColor...){
        
        let gradient = CAGradientLayer()
        
        let maxWidth = max(self.bounds.size.height,self.bounds.size.width)
        let squareFrame = CGRect(origin: self.bounds.origin, size: CGSize(width: maxWidth, height: height))
        gradient.frame = squareFrame
        
        gradient.colors = colors
//        self.addSublayer(gradient)
        self.insertSublayer(gradient, at: 0)
    }
    
}

func setTableViewBackgroundGradient(_ sender: UITableViewController, _ topColor:UIColor, _ bottomColor:UIColor) {
    
    let gradientBackgroundColors = [topColor.cgColor, bottomColor.cgColor]
    let gradientLocations = [0.0,1.0]
    
    let gradientLayer = CAGradientLayer()
    gradientLayer.colors = gradientBackgroundColors
    gradientLayer.locations = gradientLocations as [NSNumber]?
    
    gradientLayer.frame = sender.tableView.bounds
    let backgroundView = UIView(frame: sender.tableView.bounds)
    backgroundView.layer.insertSublayer(gradientLayer, at: 0)
    sender.tableView.backgroundView = backgroundView
}
