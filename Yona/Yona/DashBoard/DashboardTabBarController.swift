//
//  DashboardTabBarController.swift
//  Yona
//
//  Created by Chandan on 23/03/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

class DashboardTabBarController: UIViewController {
    
    @IBOutlet var containerView : UIView!
    @IBOutlet var tabbar: UITabBar!
    
    var currentViewController: UIViewController?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tabbar.selectedItem = tabbar.items![2]
        
        performSegueWithIdentifier("Challenges", sender: self)
    }
    
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        performSegueWithIdentifier(item.title!, sender: self)
    }
}
