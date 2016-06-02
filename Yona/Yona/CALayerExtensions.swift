//
//  StringExtensions.swift
//  Yona
//
//  Created by Chandan Varma on 30/05/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

extension CALayer {
    
    func configureGradientBackground(height:CGFloat, colors:CGColorRef...){
        
        let gradient = CAGradientLayer()
        
        let maxWidth = max(self.bounds.size.height,self.bounds.size.width)
        let squareFrame = CGRect(origin: self.bounds.origin, size: CGSizeMake(maxWidth, height))
        gradient.frame = squareFrame
        
        gradient.colors = colors
//        self.addSublayer(gradient)
        self.insertSublayer(gradient, atIndex: 0)
    }
    
}

func setTableViewBackgroundGradient(sender: UITableViewController, _ topColor:UIColor, _ bottomColor:UIColor) {
    
    let gradientBackgroundColors = [topColor.CGColor, bottomColor.CGColor]
    let gradientLocations = [0.0,1.0]
    
    let gradientLayer = CAGradientLayer()
    gradientLayer.colors = gradientBackgroundColors
    gradientLayer.locations = gradientLocations
    
    gradientLayer.frame = sender.tableView.bounds
    let backgroundView = UIView(frame: sender.tableView.bounds)
    backgroundView.layer.insertSublayer(gradientLayer, atIndex: 0)
    sender.tableView.backgroundView = backgroundView
}