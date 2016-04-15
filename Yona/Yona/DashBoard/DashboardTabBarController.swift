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
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
    }
    
    override func viewWillAppear(animated: Bool) {
        tabbar.selectedItem = tabbar.items![2]
        
        
        let storyboard = UIStoryboard(name: tabbar.items![2].title!, bundle: nil)
        let destinationViewController = storyboard.instantiateViewControllerWithIdentifier(tabbar.items![2].title! + "Storyboard")
        
        for view in self.containerView.subviews as [UIView] {
            view.removeFromSuperview();
        }
        
        self.switchViewController(destinationViewController)
    }
    
    private func switchViewController(destinationViewController: UIViewController) {
        
        self.addChildViewController(destinationViewController)
        destinationViewController.view.frame = CGRectMake(0, 0, self.containerView.frame.size.width, self.containerView.frame.size.height);
        self.containerView.addSubview(destinationViewController.view)
        self.currentViewController = destinationViewController
        destinationViewController.didMoveToParentViewController(self)
    }
    //    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    //        
    //    }
    
    
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        
        let storyboard = UIStoryboard(name: item.title!, bundle: nil)
        let destinationViewController = storyboard.instantiateViewControllerWithIdentifier(item.title! + "Storyboard")
        
        for view in self.containerView.subviews as [UIView] {
            view.removeFromSuperview();
        }
        
        self.currentViewController = destinationViewController
        self.containerView.addSubview(destinationViewController.view)
        
    }
}
