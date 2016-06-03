//
//  DashboardNavigationViewController.swift
//  Yona
//
//  Created by Ahmed Ali on 13/05/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

class DashboardNavigationViewController: UINavigationController, UITabBarDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBarHidden(false, animated: false)
        let storyboard = UIStoryboard(name: self.title!, bundle: NSBundle.mainBundle())
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffset(horizontal: 0, vertical: -100), forBarMetrics: .Default)
        self.viewControllers = [storyboard.instantiateInitialViewController()!]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        print(item)
    }
    
}