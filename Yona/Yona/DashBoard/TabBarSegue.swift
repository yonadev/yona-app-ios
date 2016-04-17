//
//  CustomSegue.swift
//  Yona
//
//  Created by Alessio Roberto on 16/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

class TabBarSegue: UIStoryboardSegue {
    
    enum SegueId: String {
        case Profile
        case Challenges
        case Friends
        case Settings
    }
    
    override func perform() {
        let tabBarController = self.sourceViewController as! DashboardTabBarController
        
        
        let storyboard = UIStoryboard(name: self.identifier!, bundle: nil)
        var destinationViewController = storyboard.instantiateViewControllerWithIdentifier(self.identifier! + "Storyboard")
        
        switch self.identifier! {
        case SegueId.Challenges.rawValue:
            if let vc = tabBarController.currentViewControllers.challengesViewController {
                destinationViewController = vc
            } else {
                tabBarController.currentViewControllers.challengesViewController = destinationViewController as? ChallengesFirstStepViewController
            }
        default:()
        }
        
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