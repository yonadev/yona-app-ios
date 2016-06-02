//
//  FriendsNotificationMasterView.swift
//  Yona
//
//  Created by Ben Smith on 19/05/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

class FriendsProfileMasterView: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet var gradientView: GradientView!
    @IBOutlet var timelineTabView: UIView!
    @IBOutlet var overviewTabView: UIView!
    @IBOutlet var timelineTabBottomBorder: UIView!
    @IBOutlet var overviewTabBottomBorder: UIView!
    @IBOutlet var addFriendbutton: UIButton?
    @IBOutlet var notificationsButton: UIButton?
    @IBOutlet var userDetailsButton: UIButton?
    @IBOutlet var screenTitle: UILabel!
}

extension FriendsProfileMasterView {
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        return cell
    }
}

// MARK: Touch Event of Custom Segment

extension FriendsProfileMasterView {
    @IBAction func TimeLineTabAction(sender: AnyObject) {
        overviewTabView.alpha = 0.5
        overviewTabBottomBorder.hidden = true
        timelineTabView.alpha = 1.0
        timelineTabBottomBorder.hidden = false
        if let addFriendbutton = self.addFriendbutton {
            addFriendbutton.hidden = true
        }
    }
    
    @IBAction func OverviewTabAction(sender: AnyObject) {
        timelineTabView.alpha = 0.5
        timelineTabBottomBorder.hidden = true
        overviewTabView.alpha = 1.0
        overviewTabBottomBorder.hidden = false
        if let addFriendbutton = self.addFriendbutton {
            addFriendbutton.hidden = false
        }
        if let userDetailsButton = self.userDetailsButton {
            userDetailsButton.hidden = false
        }
        if let notificationsButton = self.notificationsButton {
            notificationsButton.hidden = false
        }
    }
}