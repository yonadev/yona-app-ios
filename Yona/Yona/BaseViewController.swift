//
//  BaseViewController.swift
//  Yona
//
//  Created by Chandan on 19/05/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BaseViewController.foreground), name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    func foreground() {
        self.presentViewController(R.storyboard.login.loginStoryboard!, animated: false) { 
            
        }
    }
}


