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
        guard let identifier = self.identifier else {
            return
        }
        
        guard let tabBarController = self.sourceViewController as? DashboardTabBarController else {
            return
        }
        
        let storyboard = UIStoryboard(name: identifier, bundle: nil)
        var destinationViewController = storyboard.instantiateViewControllerWithIdentifier(self.identifier! + "Storyboard")
        
        switch identifier {
        case SegueId.Challenges.rawValue:
            if let vc = tabBarController.currentViewControllers.challengesViewController {
                destinationViewController = vc
            } else {
                tabBarController.currentViewControllers.challengesViewController = destinationViewController as? TimeBucketChallenges
            }
        case SegueId.Settings.rawValue:
            if let vc = tabBarController.currentViewControllers.settingsViewController {
                destinationViewController = vc
            } else {
                tabBarController.currentViewControllers.settingsViewController = destinationViewController as? SettingsViewController
            }
        case SegueId.Friends.rawValue:
            if let vc = tabBarController.currentViewControllers.friendsOverViewViewController {
                destinationViewController = vc
            } else {
                tabBarController.currentViewControllers.friendsOverViewViewController = destinationViewController as? FriendsOverViewViewController
            }
        case SegueId.Profile.rawValue:
            if let vc = tabBarController.currentViewControllers.profileViewController {
                destinationViewController = vc
            } else {
                tabBarController.currentViewControllers.profileViewController = destinationViewController as? ProfileViewController
            }
        default:()
        }
        
        tabBarController.containerView.subviews.forEach{ $0.removeFromSuperview() }
        
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