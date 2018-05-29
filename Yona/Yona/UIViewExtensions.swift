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
    func addTopBorderWithColor(_ color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: width)
        self.layer.addSublayer(border)
    }
    
    func addRightBorderWithColor(_ color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: self.frame.size.width - width, y: 0, width: width, height: self.frame.size.height)
        self.layer.addSublayer(border)
    }
    
    func addBottomBorderWithColor(_ color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: width)
        self.layer.addSublayer(border)
    }
    
    func addLeftBorderWithColor(_ color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: 0, width: width, height: self.frame.size.height)
        self.layer.addSublayer(border)
    }
}

func getViewControllerToDisplay(_ key: String)-> String? {
    let defaults = UserDefaults.standard
    defaults.object(forKey: key)
    if (defaults.object(forKey: key) == nil) && (key == YonaConstants.nsUserDefaultsKeys.screenToDisplay) {
        setViewControllerToDisplay(ViewControllerTypeString.walkThrough,key: key)
    }
    return defaults.object(forKey: key) as? String
}

func setViewControllerToDisplay(_ value: ViewControllerTypeString?, key: String) {
    let defaults = UserDefaults.standard
    defaults.setValue(value?.rawValue, forKey: key)
    defaults.synchronize()
}

func getTabToDisplay(_ key: String)-> String? {
    let defaults = UserDefaults.standard
    defaults.object(forKey: key)
    if (defaults.object(forKey: key) == nil) && (key == YonaConstants.nsUserDefaultsKeys.screenToDisplay) {
        setViewControllerToDisplay(ViewControllerTypeString.walkThrough,key: key)
    }
    return defaults.object(forKey: key) as? String
}

func setTimeBucketTabToDisplay(_ value: timeBucketTabNames?, key: String) {
    let defaults = UserDefaults.standard
    defaults.setValue(value?.rawValue, forKey: key)
    defaults.synchronize()
}

func getTimeBucketToDisplay(_ key: String)-> AnyObject? {
    let defaults = UserDefaults.standard
    defaults.object(forKey: key)
    return defaults.object(forKey: key) as AnyObject?
}
