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
        let storyboard = UIStoryboard(name: self.title!, bundle: Bundle.main)
        self.viewControllers = [storyboard.instantiateInitialViewController()!]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print(item)
    }

}
