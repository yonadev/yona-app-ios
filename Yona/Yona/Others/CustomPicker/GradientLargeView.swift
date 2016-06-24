//
//  GradientLargeView.swift
//  Yona
//
//  Created by Anders Liebl on 21/06/2016.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

class GradientLargeView: GradientView {

    
    override func getPath() -> CGPath {
        let size = self.bounds.size
        let path = CGPathCreateMutable()
        
        CGPathMoveToPoint(path, nil, 0, 0)
//        CGPathAddLineToPoint(path, nil, (size.width/3)*2, 0)
//        CGPathAddLineToPoint(path, nil, 0, size.height-15)
        CGPathAddLineToPoint(path, nil, size.width, 0)
        CGPathAddLineToPoint(path, nil, 0, size.height)
        CGPathAddLineToPoint(path, nil, 0, 0)
        
        return path
    }


}