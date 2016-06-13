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
    @IBOutlet var userDetailButton: UIBarButtonItem!
    @IBOutlet var notificationsButton: UIButton?

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        OverviewTabAction(overviewTabView)
        self.setupUI()
        self.navigationController?.navigationBarHidden = false
    }
    
    // MARK: - private functions
    private func setupUI() {
        tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    @IBAction func unwindToProfileView(segue: UIStoryboardSegue) {
        print(segue.sourceViewController)
    }
}