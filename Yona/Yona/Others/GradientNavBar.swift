//
//  GradientNavBar.swift
//  Yona
//
//  Created by Ben Smith on 23/05/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

class GradientNavBar: UINavigationBar {
    
    /** This is a custom value on so that any Nav bar using this class has a property in which you can set the colour */
    @IBInspectable var gradientColor: UIColor!
    /** An instance of our gradient view subview that we can reuse in our nav bar */
    var gradientView: GradientView = GradientView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        gradientView.frame = self.bounds
        //set gradient view to the colour set by our inspectable property
        gradientView.setGradient(gradientColor, color2: gradientColor)
        self.addSubview(gradientView)

        self.sendSubviewToBack(gradientView)
//        self.layer.zPosition = 3

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var frame = self.bounds
        //our frame (set to bounds is at 0,0 but the status bar covers is 20 px above, we want the gradient view to go all the way to the top, so take 20 pixels off the start of our bounds, add 20 to the height
        frame.origin.y -=  20
        frame.size.height += 19
        //make sure gradient view frame is set to the same bounds as the nav bar so that is goes all the way to the top
        gradientView.frame = frame

    }
}