//
//  FriendsDayViewController.swift
//  Yona
//
//  Created by Anders Liebl on 07/07/2016.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

class FriendsDayViewController: MeDashBoardMainViewController {
    
    var buddyToShow :Buddies?
    var navbarColor1 : UIColor?
    var navbarColor : UIColor?
    
    @IBOutlet weak var rightNavBarItem : UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("", comment: "")
    }
    
    override func viewWillDisappear(animated: Bool) {
        if let navbarColor1 = navbarColor1,
            let navbarColor = navbarColor {
            self.navigationController?.navigationBar.backgroundColor = navbarColor1
            let navbar = navigationController?.navigationBar as! GradientNavBar
            navbar.gradientColor = navbarColor
        }
        
    }

    override func viewWillAppear(animated: Bool) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "FriendsDayViewController")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
        
        navigationItem.title = NSLocalizedString("friends", comment: "")
        configurProfileBarItem()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        rightNavBarItem.addCircle()
    }
    
    //MARK: - implementations metods
    override func actionsAfterLeftButtonPush() {
        loadActivitiesForDay()
        // The subController must override this to have any action after the tabe selection
        
    }
    //MARK: - week delegate methods
    override func didSelectDayInWeek(goal: SingleDayActivityGoal, aDate : NSDate) {
        
        weekDayDetailLink = goal.yonadayDetails
        performSegueWithIdentifier(R.segue.friendsDayViewController.showFriendsDetailDay, sender: self)
    }

    override func actionsAfterRightButtonPush() {
        // The subController must override this to have any action after the tabe selection
        loadActivitiesForWeek()
    }

    override func configurProfileBarItem () {
        if let name = buddyToShow?.UserRequestfirstName {
            if name.characters.count > 0 {//&& user?.characters.count > 0{
                self.rightNavBarItem.title = "\(name.capitalizedString.characters.first!)"
                self.rightNavBarItem.addCircle()
            }
        }
    }

    
    // MARK: - ACTION
    @IBAction func didChooseUserProfile(sender : AnyObject) {
        weak var tracker = GAI.sharedInstance().defaultTracker
        tracker!.send(GAIDictionaryBuilder.createEventWithCategory("ui_action", action: "UserProfilePressed", label: "Choose to look at user profile", value: nil).build() as [NSObject : AnyObject])
        performSegueWithIdentifier(R.segue.friendsDayViewController.showFriendProfile, sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController is FriendsProfileViewController {
            let controller = segue.destinationViewController as! FriendsProfileViewController
            controller.aUser = buddyToShow
        }
        if segue.destinationViewController is FriendsDayDetailViewController {
            let controller = segue.destinationViewController as! FriendsDayDetailViewController
            
            if let path = weekDayDetailLink {
                controller.initialObjectLink = path
                weekDayDetailLink = nil
                
            } else if let section : Int = theTableView.indexPathForSelectedRow!.section {
                let data = leftTabData[section].activites[theTableView.indexPathForSelectedRow!.row]
                controller.activityGoal = data
                controller.buddy = buddyToShow
            }
        }
        if segue.destinationViewController is FriendsWeekDetailWeekController {
            let controller = segue.destinationViewController as! FriendsWeekDetailWeekController
            if let section : Int = theTableView.indexPathForSelectedRow!.section {
                let data = rightTabData[section].activity[theTableView.indexPathForSelectedRow!.row]
                controller.initialObject = data
                controller.buddy = buddyToShow
                
            }
        }

    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if selectedTab == .right {
            performSegueWithIdentifier(R.segue.friendsDayViewController.showFriendsDetailWeek, sender: self)
        }
        
        if selectedTab == .left {
            performSegueWithIdentifier(R.segue.friendsDayViewController.showFriendsDetailDay, sender: self)
        }
    }

    
    // MARK: - Data loaders
    
    override func loadActivitiesForDay(page : Int = 0) {
        print("Entering day loader")
        if let buddy = buddyToShow  {
            Loader.Show()
            ActivitiesRequestManager.sharedInstance.getBuddieActivityPrDay(buddy, size: 3, page:0, onCompletion: { (success, serverMessage, serverCode, activitygoals, err) in
                if success {
                    
                    if let data = activitygoals {
                        self.animatedCells.removeAll()
                        self.leftTabData = data
                    }
                    Loader.Hide()
                    self.theTableView.reloadData()
                } else {
                    self.leftTabData = []
                    Loader.Hide()
                }
            })
        }
    }

    override func loadActivitiesForWeek(page : Int = 0) {
        if let buddy = buddyToShow  {
            Loader.Show()
            ActivitiesRequestManager.sharedInstance.getBuddieActivityPrWeek(buddy, size:3, page:page, onCompletion: { (success, serverMessage, serverCode, activitygoals, err) in
                if success {
                    
                    if let data = activitygoals {
                        self.rightTabData = data
                    }
                    
                    Loader.Hide()
                    self.theTableView.reloadData()
                    
                } else {
                    Loader.Hide()
                }
            })
        }
    }

}