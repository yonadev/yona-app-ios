//
//  BaseTabViewController.swift
//  Yona
//
//  Created by Chandan on 17/05/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

let selectedTab = "selectedTab"
enum Tab: String {
    case profile = "Profile"
    case friends = "Friends"
    case challenges = "Challenges"
    case settings = "Settings"
    
    init?() {
        self = .challenges
    }
    
    func getTag(value: String) -> Int {
        switch value {
        case Tab.profile.rawValue:
            return 0
        case Tab.friends.rawValue:
            return 1
        case Tab.challenges.rawValue:
            return 2
        case Tab.settings.rawValue:
            return 3
        default:
            return 2
        }
    }
}

class BaseTabViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedIndex = NSUserDefaults.standardUserDefaults().integerForKey(selectedTab)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        NSUserDefaults.standardUserDefaults().setInteger(Tab()!.getTag(item.title!), forKey: selectedTab)
    }
}
