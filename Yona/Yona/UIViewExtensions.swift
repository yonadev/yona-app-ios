//
//  Extensions.swift
//  Yona
//
//  Created by Chandan on 12/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func addTopBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.CGColor
        border.frame = CGRectMake(0, 0, self.frame.size.width, width)
        self.layer.addSublayer(border)
    }
    
    func addRightBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.CGColor
        border.frame = CGRectMake(self.frame.size.width - width, 0, width, self.frame.size.height)
        self.layer.addSublayer(border)
    }
    
    func addBottomBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.CGColor
        border.frame = CGRectMake(0, self.frame.size.height - width, self.frame.size.width, width)
        self.layer.addSublayer(border)
    }
    
    func addLeftBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.CGColor
        border.frame = CGRectMake(0, 0, width, self.frame.size.height)
        self.layer.addSublayer(border)
    }
}

func getViewControllerToDisplay(key: String)-> String? {
    let defaults = NSUserDefaults.standardUserDefaults()
    defaults.objectForKey(key)
    if (defaults.objectForKey(key) == nil) && (key == YonaConstants.nsUserDefaultsKeys.screenToDisplay) {
        setViewControllerToDisplay(ViewControllerTypeString.walkThrough,key: key)
    }
    return defaults.objectForKey(key) as? String
}

func setViewControllerToDisplay(value: ViewControllerTypeString?, key: String) {
    let defaults = NSUserDefaults.standardUserDefaults()
    defaults.setValue(value?.rawValue, forKey: key)
    defaults.synchronize()
}

func getTabToDisplay(key: String)-> String? {
    let defaults = NSUserDefaults.standardUserDefaults()
    defaults.objectForKey(key)
    if (defaults.objectForKey(key) == nil) && (key == YonaConstants.nsUserDefaultsKeys.screenToDisplay) {
        setViewControllerToDisplay(ViewControllerTypeString.walkThrough,key: key)
    }
    return defaults.objectForKey(key) as? String
}

func setTimeBucketTabToDisplay(value: timeBucketTabNames?, key: String) {
    let defaults = NSUserDefaults.standardUserDefaults()
    defaults.setValue(value?.rawValue, forKey: key)
    defaults.synchronize()
}

func getTimeBucketToDisplay(key: String)-> AnyObject? {
    let defaults = NSUserDefaults.standardUserDefaults()
    defaults.objectForKey(key)
    return defaults.objectForKey(key)
}
