//
//  Extensions.swift
//  Yona
//
//  Created by Alessio Roberto on 04/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func resetTheView(position: CGFloat, scrollView: UIScrollView, view: UIView) -> CGFloat? {
        scrollView.setContentOffset(CGPointMake(0, 0), animated: true)
        
        if (position > 0) {
            view.frame.origin.y += position
            return 0.0
        }
        
        return nil
    }
}

func setViewControllerToDisplay(value: String, key: String) {
    let defaults = NSUserDefaults.standardUserDefaults()
    defaults.setObject(value, forKey: key)
    defaults.synchronize()
}

func getViewControllerToDisplay(key: String)-> AnyObject? {
    let defaults = NSUserDefaults.standardUserDefaults()
    defaults.objectForKey(key)
    if defaults.objectForKey(key) == nil {
    setViewControllerToDisplay("Welcome",key: key)
    }
    return defaults.objectForKey(key)
}
