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
        self.viewControllers = [storyboard.instantiateInitialViewController()!]
    }
    
    override func viewWillLayoutSubviews() {
        var frame = self.navigationBar.bounds
        //our frame (set to bounds is at 0,0 but the status bar covers is 20 px above, we want the gradient view to go all the way to the top, so take 20 pixels off the start of our bounds, add 20 to the height
        frame.origin.y -=  10
        frame.size.height += 30
        
        self.navigationBar.frame = frame

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        print(item)
    }

}
