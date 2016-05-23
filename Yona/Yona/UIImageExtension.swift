//
//  UIImageExtension.swift
//  Yona
//
//  Created by Ben Smith on 23/05/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

extension UIImage {
    class func imageWithView(view: UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0)
        view.drawViewHierarchyInRect(view.bounds, afterScreenUpdates: false)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
}