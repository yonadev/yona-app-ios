//
//  NavigationHideScrollBehavior.swift
//  Behaviors
//
//  Created by Angel Garcia on 09/02/16.
//  Copyright © 2016 angelolloqui.com. All rights reserved.
//

import Foundation
import UIKit

public class NavigationHideScrollBehavior : ScrollingTriggerBehavior {
    @IBInspectable public var navigationBarEnabled: Bool = true
    @IBInspectable public var tabBarEnabled: Bool = false
    
    //MARK: Public actions
    @IBAction public override func touchDragEnter() {
        super.touchDragEnter()
        hideAll()
    }
    
    @IBAction public override func touchDragExit() {
        super.touchDragExit()
        showAll()
    }
    
    @IBAction public func hideAll() {
        hideNavigationBar()
        hideTabBar()
    }

    
    @IBAction public func showAll() {
        showNavigationBar()
        showTabBar()
    }

    @IBAction public func hideNavigationBar() {
        setNavigationBarHidden(true, animated: true)
    }
    
    @IBAction public func showNavigationBar() {
        setNavigationBarHidden(false, animated: true)
    }
    
    @IBAction public func hideTabBar() {
        setTabBarHidden(true, animated: true)
    }
    
    @IBAction public func showTabBar() {
        setTabBarHidden(false, animated: true)
    }
    
    
    public func setNavigationBarHidden(hidden: Bool, animated: Bool = true) {
        if enabled && navigationBarEnabled {
            if let navController = findNavigationController() {
                if navController.navigationBarHidden != hidden {
                    navController.setNavigationBarHidden(hidden, animated: animated)
                    self.sendActionsForControlEvents(.ValueChanged)
                }
            }
        }
    }
    
    
    public func setTabBarHidden(hidden: Bool, animated: Bool = true) {
        if enabled && tabBarEnabled {
            if let tabController = findTabBarController() {
                if tabController.tabBar.hidden != hidden {
                    tabController.tabBar.hidden = false
                    UIView.animateWithDuration(animated ? 0.3 : 0, animations: {
                        if hidden {
                            tabController.tabBar.transform = CGAffineTransformMakeTranslation(0, tabController.tabBar.frame.size.height)
                        }
                        else {
                            tabController.tabBar.transform = CGAffineTransformIdentity
                        }
                        
                        }, completion: { (completed) -> Void in
                            if completed {
                                tabController.tabBar.hidden = hidden
                            }
                    })
                    self.sendActionsForControlEvents(.ValueChanged)
                }
            }
        }
    }
    
    //MARK: Private methods
    var navController: UINavigationController?
    func findNavigationController() -> UINavigationController? {
        guard navController == nil else { return navController }
        var responder = scrollView?.nextResponder()
        while responder != nil {
            if let vc = responder as? UIViewController {
                if vc.navigationController != nil {
                    navController = vc.navigationController
                    return vc.navigationController
                }
            }
            responder = responder?.nextResponder()
        }
        return nil
    }
    
    var tabController: UITabBarController?
    func findTabBarController() -> UITabBarController? {
        guard tabController == nil else { return tabController }
        var responder = scrollView?.nextResponder()
        while responder != nil {
            if let vc = responder as? UIViewController {
                if vc.tabBarController != nil {
                    tabController = vc.tabBarController
                    return vc.tabBarController
                }
            }
            responder = responder?.nextResponder()
        }
        return nil
    }
    
}
