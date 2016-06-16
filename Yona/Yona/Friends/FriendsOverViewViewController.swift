//
//  FriendsOverViewViewController.swift
//  Yona
//
//  Created by Chandan on 23/03/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

class FriendsOverViewViewController: FriendsProfileMasterView {
    

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        OverviewTabAction(overviewTabView)
        self.setupUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        isFromFriends = true
    }
    
    // MARK: - private functions
    private func setupUI() {
        //Nav bar Back button.
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
}

// MARK: Touch Event of Custom Segment
extension FriendsOverViewViewController {
    @IBAction func unwindToFriendsOverview(segue: UIStoryboardSegue) {
        print(segue.sourceViewController)
    }
}