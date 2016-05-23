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
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(true)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func foreground() {
        self.presentViewController(R.storyboard.login.loginStoryboard!, animated: false) { 
        }
    }
}


