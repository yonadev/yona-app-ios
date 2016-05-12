//
//  DashboardTabBarController.swift
//  Yona
//
//  Created by Chandan on 23/03/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

struct ViewControllerStatus {
    var profileViewController: ProfileViewController?
    var friendsOverViewViewController: FriendsOverViewViewController?
    var challengesViewController: TimeBucketChallenges?
    var settingsViewController: SettingsViewController?
}

class DashboardTabBarController: UIViewController {
    
    @IBOutlet var containerView : UIView!
    @IBOutlet var tabbar: UITabBar!
    
    var currentViewControllers = ViewControllerStatus()
    var currentViewController: UIViewController?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tabbar.selectedItem = tabbar.items![2]
        tabbar.tintColor = UIColor.yiGrapeColor()
        performSegueWithIdentifier("Challenges", sender: self)
    }
    
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        performSegueWithIdentifier(item.title!, sender: self)
    }
}
