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
    @IBOutlet var screenTitle: UILabel!
    @IBOutlet var tableView: UITableView!
    var isFromFriends: Bool?
    var buddiesOverviewArray = [Buddies]()
    @IBOutlet var addBuddyButton: UIBarButtonItem!
    var section = [NSLocalizedString("accepted", comment: ""),NSLocalizedString("requested", comment: "")]
    
    var AcceptedBuddy = [Buddies]()
    var RequestedBuddy = [Buddies]()
}

extension FriendsProfileMasterView {
    // MARK: - Table view data source
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isFromFriends == true {
           self.section = [NSLocalizedString("accepted", comment: ""),NSLocalizedString("requested", comment: "")]
        }
        else {
           self.section = [NSLocalizedString("today", comment: ""),NSLocalizedString("yesterday", comment: "")]
        }
        return self.section[section]
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.yiWhiteThreeColor()

        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "SFUIDisplay-Bold", size: 11.0)
        header.textLabel?.textAlignment = NSTextAlignment.Center
        header.textLabel?.textColor = UIColor.yiBlackColor()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFromFriends == true {
            
            if section == 0 {
                return AcceptedBuddy.count
            } else {
                return RequestedBuddy.count
            }

        }
        else {
            //TODO: return profile notifications counts
            return self.buddiesOverviewArray.count
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        if indexPath.section == 0 {
            cell.textLabel?.text = self.AcceptedBuddy[indexPath.row].UserRequestfirstName! + self.AcceptedBuddy[indexPath.row].UserRequestlastName!
        } else if indexPath.section == 1 {
            cell.textLabel?.text = self.RequestedBuddy[indexPath.row].UserRequestfirstName! + self.RequestedBuddy[indexPath.row].UserRequestlastName!
        }

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
        self.navigationItem.rightBarButtonItem = nil
    }
    
    @IBAction func OverviewTabAction(sender: AnyObject) {
        timelineTabView.alpha = 0.5
        timelineTabBottomBorder.hidden = true
        overviewTabView.alpha = 1.0
        overviewTabBottomBorder.hidden = false
        self.navigationItem.rightBarButtonItem = self.addBuddyButton
        self.callAllBuddyList()
    }
    
    func callAllBuddyList() {
        
        Loader.Show()
        BuddyRequestManager.sharedInstance.getAllbuddies { (success, serverMessage, ServerCode, Buddies, buddies) in
            
            Loader.Hide()
            if success{
                if (buddies?.count ?? 0) > 0 {
                    self.buddiesOverviewArray = buddies!

                    if let buddies = buddies {
                    
                        self.RequestedBuddy = buddies.filter() { $0.sendingStatus == buddyRequestStatus.REQUESTED }
                    self.AcceptedBuddy = buddies.filter() { $0.sendingStatus == buddyRequestStatus.ACCEPTED }
                    
                    }
                    print(self.AcceptedBuddy)
                    print(self.RequestedBuddy)
                    self.tableView.reloadData()
                } else {
                    print("No buddies")
                }
            } else {
                if let serverMessage = serverMessage {
                    self.displayAlertMessage(serverMessage, alertDescription: "")
                }
            }
        }
    }
}