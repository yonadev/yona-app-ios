//
//  DoubleExtension.swift
//  Yona
//
//  Created by Ben Smith on 01/08/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

extension CGFloat {
    mutating func roundNearest(_ nearest: CGFloat) -> CGFloat {
        let n = 1/nearest
        //return round(self * n) / n
        let a = self * n
        return Darwin.round(a) / n
    }
}

