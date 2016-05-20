//
//  NotificationsOverviewController.swift
//  Yona
//
//  Created by Ben Smith on 19/05/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

class ProfileViewController: FriendsProfileMasterView {
    @IBOutlet var tableView: UITableView!

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        OverviewTabAction(overviewTabView)
        self.setupUI()
        dispatch_async(dispatch_get_main_queue(), {
            self.gradientView.colors = [UIColor.yiGrapeColor(), UIColor.yiGrapeColor()]
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: - private functions
    private func setupUI() {
        //Nav bar Back button.
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
}

// MARK: Touch Event of Custom Segment
extension FriendsProfileMasterView {
    @IBAction func showUserDetails(sender: AnyObject) {
        performSegueWithIdentifier(R.segue.profileViewController.userDetails , sender: self)
    }
    
    @IBAction func showNotificationsScreen(sender: AnyObject) {
        performSegueWithIdentifier(R.segue.profileViewController.notificationsSegue , sender: self)
    }
}