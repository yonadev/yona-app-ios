//
//  FriendsOverViewViewController.swift
//  Yona
//
//  Created by Chandan on 23/03/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

class FriendsOverViewViewController: FriendsProfileMasterView {
    @IBOutlet var tableView: UITableView!

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        OverviewTabAction(overviewTabView)
        self.setupUI()
        dispatch_async(dispatch_get_main_queue(), {
            self.gradientView.colors = [UIColor.yiMidBlueColor(), UIColor.yiMidBlueColor()]
        })
    }
    
    // MARK: - private functions
    private func setupUI() {
        //Nav bar Back button.
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
}

// MARK: Touch Event of Custom Segment
extension FriendsOverViewViewController {
    @IBAction func addFriendAction(sender: AnyObject) {
        performSegueWithIdentifier(R.segue.friendsOverViewViewController.addFriendsSegue, sender: self)
    }
}