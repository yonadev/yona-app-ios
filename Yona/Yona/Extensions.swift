//
//  Extensions.swift
//  Yona
//
//  Created by Alessio Roberto on 16/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

extension CALayer {
    var borderUIColor: UIColor {
        set {
            self.borderColor = newValue.cgColor
        }
        get {
            return UIColor(cgColor: self.borderColor!)
        }
    }
}
