//
//  CustomSegue.swift
//  Yona
//
//  Created by Alessio Roberto on 16/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

class TabBarSegue: UIStoryboardSegue {
    
    override func perform() {
        let tabBarController = self.sourceViewController as! DashboardTabBarController
        
        
        let storyboard = UIStoryboard(name: self.identifier!, bundle: nil)
        let destinationViewController = storyboard.instantiateViewControllerWithIdentifier(self.identifier! + "Storyboard")
        
        for view in tabBarController.containerView.subviews as [UIView] {
            view.removeFromSuperview();
        }
        
        tabBarController.currentViewController = destinationViewController
        tabBarController.containerView.addSubview(destinationViewController.view)
        
        tabBarController.containerView.translatesAutoresizingMaskIntoConstraints = false
        destinationViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        let horizontalConstraint = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[v1]-0-|", options: .AlignAllTop, metrics: nil, views: ["v1": destinationViewController.view])
        tabBarController.containerView.addConstraints(horizontalConstraint)
        
        let verticalConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[v1]-0-|", options: .AlignAllTop, metrics: nil, views: ["v1": destinationViewController.view])
        tabBarController.containerView.addConstraints(verticalConstraint)
        tabBarController.containerView.layoutIfNeeded()
        destinationViewController.didMoveToParentViewController(tabBarController)
    }
    
}