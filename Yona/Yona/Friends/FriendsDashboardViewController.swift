//
//  FriendsDayViewController.swift
//  Yona
//
//  Created by Anders Liebl on 07/07/2016.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

class FriendsDashboardViewController: MeDashBoardMainViewController {
    
    var buddyToShow :Buddies?
    var navbarColor1 : UIColor?
    var navbarColor : UIColor?
    
    @IBOutlet weak var rightNavBarItem : UIBarButtonItem!
    
    //MARK: - View life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("", comment: "")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let _ = navbarColor1,
            let _ = navbarColor {
            self.navigationController?.navigationBar.backgroundColor = UIColor.yiWindowsBlueColor()
            let navbar = navigationController?.navigationBar as! GradientNavBar
            navbar.gradientColor = UIColor.yiMidBlueColor()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "FriendsDayViewController")
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as? [AnyHashable: Any])
        if buddyToShow != nil {
            navbarColor1 = self.navigationController?.navigationBar.backgroundColor
            self.navigationController?.navigationBar.backgroundColor = UIColor.yiWindowsBlueColor()
            let navbar = self.navigationController?.navigationBar as! GradientNavBar
            navbarColor = navbar.gradientColor
            navbar.gradientColor = UIColor.yiMidBlueColor()
        }
        navigationItem.rightBarButtonItems = nil
        navigationItem.rightBarButtonItem = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configurProfileBarItem()
    }
    
    //MARK: - implementations metods
    override func actionsAfterLeftButtonPush() {
        loadActivitiesForDay(leftPage)
        // The subController must override this to have any action after the tabe selection

    }
    //MARK: - week delegate methods
    override func didSelectDayInWeek(_ goal: SingleDayActivityGoal, aDate : Date) {
        weekDayDetailLink = goal.yonadayDetails
        performSegue(withIdentifier: R.segue.friendsDashboardViewController.showFriendsDetailDay, sender: self)
    }
    
    override func actionsAfterRightButtonPush() {
        // The subController must override this to have any action after the tabe selection
        loadActivitiesForWeek(rightPage)
    }
    
    override func configurProfileBarItem () {
        if let name = buddyToShow?.UserRequestfirstName {
            navigationItem.title = name
            if name.count > 0 {//&& user?.characters.count > 0{
                let btnName = UIButton()
                let txt = "\(name.capitalized.first!)"
                btnName.setTitle(txt, for: UIControl.State())
                btnName.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
                btnName.addTarget(self, action: #selector(self.didChooseUserProfile(_:)), for: .touchUpInside)
                btnName.backgroundColor = UIColor.clear
                btnName.layer.cornerRadius = btnName.frame.size.width/2
                btnName.layer.borderWidth = 1
                btnName.layer.borderColor = UIColor.white.cgColor
                let rightBarButton = UIBarButtonItem()
                rightBarButton.customView = btnName
                navigationItem.rightBarButtonItems = [rightBarButton]
            }
        }
    }
    
    // MARK: - ACTION
    @IBAction func didChooseUserProfile(_ sender : AnyObject) {
        weak var tracker = GAI.sharedInstance().defaultTracker
        tracker!.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action", action: "UserProfilePressed", label: "Choose to look at user profile", value: nil).build() as? [AnyHashable: Any])
        performSegue(withIdentifier: R.segue.friendsDashboardViewController.showFriendProfile, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is FriendsProfileViewController {
            let controller = segue.destination as! FriendsProfileViewController
            controller.aUser = buddyToShow
        }
        if segue.destination is FriendsDayDetailViewController {
            let controller = segue.destination as! FriendsDayDetailViewController
            if let path = weekDayDetailLink {
                controller.initialObjectLink = path
                weekDayDetailLink = nil
                controller.buddy = buddyToShow
            } else if let section : Int = theTableView.indexPathForSelectedRow?.section {
                let data = leftTabData[section].activites[theTableView.indexPathForSelectedRow!.row]
                controller.activityGoal = data
                controller.buddy = buddyToShow
            }
        }
        if segue.destination is FriendsWeekDetailWeekController {
            let controller = segue.destination as! FriendsWeekDetailWeekController
            if let section : Int = theTableView.indexPathForSelectedRow?.section {
                let data = rightTabData[section].activity[theTableView.indexPathForSelectedRow!.row]
                controller.initialObject = data
                controller.buddy = buddyToShow
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        if selectedTab == .left {
            performSegue(withIdentifier: R.segue.friendsDashboardViewController.showFriendsDetailDay, sender: self)
        }
    }
    
    // MARK: - Data loaders
    fileprivate func handleBuddyPerDayActivity(_ activitygoals: [DayActivityOverview]?) {
        if let data = activitygoals {
            if data.count > 0  {
                self.animatedCells.removeAll()
                if self.leftPage == 0 {
                    self.leftTabData = data
                } else {
                    self.leftTabData.append(contentsOf: data)
                }
                self.leftPage += 1
            }
        }
        Loader.Hide()
        self.loading = false
        DispatchQueue.main.async(execute: {
            self.theTableView.reloadData()
        })
    }
    
    override func loadActivitiesForDay(_ page : Int = 0) {
        if loading {
            return
        }
        loading = true
        Loader.Show()
        if let buddy = buddyToShow  {
            ActivitiesRequestManager.sharedInstance.getBuddieActivityPrDay(buddy, size: size, page:page, onCompletion: { (success, serverMessage, serverCode, activitygoals, err) in
                if success {
                    self.handleBuddyPerDayActivity(activitygoals)
                } else {
                    Loader.Hide()
                    self.loading = false
                    DispatchQueue.main.async(execute: {
                        let alert = UIAlertView.init(title: NSLocalizedString("dashboard.error.title", comment: ""), message: err?.localizedDescription, delegate: nil, cancelButtonTitle: NSLocalizedString("dashboard.error.button", comment: ""))
                        alert.show()
                    })
                }
            })
        }
    }
    
    fileprivate func handleBuddyPerWeekActivity(_ activitygoals: [WeekActivityGoal]?) {
        if let data = activitygoals {
            if data.count > 0  {
                if self.rightPage == 0 {
                    self.rightTabData = data
                } else {
                    self.rightTabData.append(contentsOf: data)
                }
                self.rightPage += 1
            }
        }
        Loader.Hide()
        self.loading = false
        DispatchQueue.main.async(execute: {
            self.theTableView.reloadData()
        })
    }
    
    override func loadActivitiesForWeek(_ page : Int = 0) {
        if loading {
            return
        }
        loading = true
        Loader.Show()
        if let buddy = buddyToShow  {
            ActivitiesRequestManager.sharedInstance.getBuddieActivityPrWeek(buddy, size:3, page:page, onCompletion: { (success, serverMessage, serverCode, activitygoals, err) in
                if success {
                    self.handleBuddyPerWeekActivity(activitygoals)
                } else {
                    Loader.Hide()
                    self.loading = false
                    DispatchQueue.main.async(execute: {
                        let alert = UIAlertView.init(title: NSLocalizedString("dashboard.error.title", comment: ""), message: err?.localizedDescription, delegate: nil, cancelButtonTitle: NSLocalizedString("dashboard.error.button", comment: ""))
                        alert.show()
                    })
                }
            })
        }
    }
}
