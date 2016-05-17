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
        self.setNavigationBarHidden(true, animated: false)
        let storyboard = UIStoryboard(name: self.title!, bundle: NSBundle.mainBundle())
        self.viewControllers = [storyboard.instantiateInitialViewController()!]
//        print(self.view!.window?.currentViewController()?.tabBarController)
//        self.setViewControllers([storyboard.instantiateInitialViewController()!, animated: false)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        print(item)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
