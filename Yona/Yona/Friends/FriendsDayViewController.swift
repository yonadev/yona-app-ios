//
//  FriendsDayViewController.swift
//  Yona
//
//  Created by Anders Liebl on 07/07/2016.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

class FriendsDayViewController: MeDashBoardMainViewController {
    
    var buddyToShow :Buddies! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("", comment: "")
    }


    override func viewWillAppear(animated: Bool) {
        var tmpFirst = ""
        var tmpLast = ""
        if let txt = buddyToShow?.UserRequestfirstName {
            tmpFirst = txt
        }
        if let txt = buddyToShow?.UserRequestlastName {
            tmpLast = txt
        }

        navigationItem.title = NSLocalizedString("\(tmpFirst) \(tmpLast)", comment: "")
    }
    
    //MARK: - implementations metods
    override func actionsAfterLeftButtonPush() {
        loadActivitiesForDay()
        // The subController must override this to have any action after the tabe selection
        
    }
    
    override func actionsAfterRightButtonPush() {
        // The subController must override this to have any action after the tabe selection
        
        // loadActivitiesForWeek()
        tableView.reloadData()
    }

    
    
    // MARK: - ACTIONS
    
    @IBAction func didChooseUserProfile(sender : AnyObject) {
    
        performSegueWithIdentifier(R.segue.friendsDayViewController.showFriendProfile, sender: self)
    
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController is FriendsProfileViewController {}
        let controller = segue.destinationViewController as! FriendsProfileViewController
        controller.aUser = buddyToShow
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if selectedTab == .right {
            //performSegueWithIdentifier(R.segue.meDashBoardMainViewController.showWeekDetail, sender: self)
        }
        
        if selectedTab == .left {
            //performSegueWithIdentifier(R.segue.meDashBoardMainViewController.showDayDetail, sender: self)
        }
    }

    
    // MARK: - Data loaders
    
    override func loadActivitiesForDay(page : Int = 0) {
        print("Entering day loader")
        Loader.Show()
        if let buddy = buddyToShow  {
            ActivitiesRequestManager.sharedInstance.getBuddieActivityPrDay(buddy, size: 3, page:0, onCompletion: { (success, serverMessage, serverCode, activitygoals, err) in
                if success {
                    
                    if let data = activitygoals {
                        self.animatedCells.removeAll()
                        self.leftTabData = data
                    }
                    Loader.Hide()
                    self.tableView.reloadData()
                } else {
                    self.leftTabData = []
                    Loader.Hide()
                }
            })
        }
    }

}