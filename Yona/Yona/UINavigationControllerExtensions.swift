//
//  UINavigationControllerExtensions.swift
//  Yona
//
//  Created by Chandan on 28/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit
import Foundation


extension UINavigationController
{
    func makeBlackNavigationbar (){
        navigationController?.navigationBarHidden = false
    }
}

extension UINavigationBar
{
    
    func makeBlackNavigationBar ()
    {
        barTintColor = UIColor.blackColor()
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.yiWhiteColor()]
        titleTextAttributes = (titleDict as! [String : AnyObject])
    }
}