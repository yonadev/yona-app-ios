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