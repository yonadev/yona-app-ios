//
//  DashboardTabBarController.swift
//  Yona
//
//  Created by Chandan on 23/03/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

class DashboardTabBarController: UIViewController {
    
    var currentViewController: UIViewController?
    @IBOutlet var containerView : UIView!
    @IBOutlet var tabbar: UITabBar!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tabbar.selectedItem = tabbar.items![2]
        
        let storyboard = UIStoryboard(name: tabbar.items![2].title!, bundle: nil)
        let destinationViewController = storyboard.instantiateViewControllerWithIdentifier(tabbar.items![2].title! + "Storyboard")
        
        switchViewController(destinationViewController)
    }
    

    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        
        let storyboard = UIStoryboard(name: item.title!, bundle: nil)
        let destinationViewController = storyboard.instantiateViewControllerWithIdentifier(item.title! + "Storyboard")
        
        switchViewController(destinationViewController)
    }
    
    private func switchViewController(destinationViewController: UIViewController) {
        self.addChildViewController(destinationViewController)
        destinationViewController.view.frame = self.containerView.frame
        self.containerView.addSubview(destinationViewController.view)
        self.currentViewController = destinationViewController
        destinationViewController.didMoveToParentViewController(self)
    }
}
