//
//  BaseTabViewController.swift
//  Yona
//
//  Created by Chandan on 17/05/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

let selectedTab = "selectedTab"
enum Tab: Int {
    case profile = 0
    case friends = 1
    case challenges = 2
    case settings = 3
}

class BaseTabViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        updateSelectedIndex()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BaseTabViewController.presentLoginScreen), name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    
    func presentLoginScreen() {
        self.presentViewController(R.storyboard.login.initialViewController!, animated: false) {
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func updateSelectedIndex() {
        if userHasGaols(){
            self.selectedIndex = Tab.profile.rawValue
        }else{
            self.selectedIndex = Tab.challenges.rawValue
        }
    }
    
    func userHasGaols() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(YonaConstants.nsUserDefaultsKeys.isGoalsAdded);
    }
}
