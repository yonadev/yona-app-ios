//
//  FriendsNotificationMasterView.swift
//  Yona
//
//  Created by Ben Smith on 19/05/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

enum  friendsSections : Int {
    case connected = 0
    case pending
    case lastrow
    
    func simpleDescription() -> String {
        switch self {
        case .connected:
            return NSLocalizedString("accepted", comment: "")
        case .pending:
            return NSLocalizedString("requested", comment: "")
        default:
            return NSLocalizedString("no option", comment: "")
        }
    }
    
}


class FriendsProfileMasterView: YonaTwoButtonsTableViewController {
    

    
    var buddiesOverviewArray = [Buddies]()
    @IBOutlet var addBuddyButton: UIBarButtonItem!
    
    
    var AcceptedBuddy = [Buddies]()
    var RequestedBuddy = [Buddies]()


    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        registreTableViewCells()
    }
    
    
    func setupUI() {
        showRightTab(rightTabMainView)
        
        //Nav bar Back button.
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        tableView.tableFooterView = UIView(frame: CGRectZero)
    }

    func registreTableViewCells () {
        let nib = UINib(nibName: "YonaUserTableViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "YonaUserTableViewCell")
    }


    
    // MARK: - Table view data source
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if selectedTab == .left {
            return nil
        } else {
            if friendsSections.connected.rawValue == section && AcceptedBuddy.count == 0 {
                return nil
            } else if friendsSections.pending.rawValue == section && RequestedBuddy.count == 0 {
                return nil
            }
            return friendsSections(rawValue: section)?.simpleDescription()
        }
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.yiWhiteThreeColor()

        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "SFUIDisplay-Bold", size: 11.0)
        header.textLabel?.textAlignment = NSTextAlignment.Center
        header.textLabel?.textColor = UIColor.yiBlackColor()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if selectedTab == .left {
            return 1
        } else {
            return 2
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedTab == .left {
            return 0
        } else {
            if section == 0 {
                return AcceptedBuddy.count
            } else {
                return RequestedBuddy.count
            }
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if selectedTab == .left {
            let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
            return cell
        } else {
        
            let cell: YonaUserTableViewCell = tableView.dequeueReusableCellWithIdentifier("YonaUserTableViewCell", forIndexPath: indexPath) as! YonaUserTableViewCell
            if indexPath.section == friendsSections.connected.rawValue {
                cell.setBuddie(AcceptedBuddy[indexPath.row])
                
            } else if indexPath.section == friendsSections.pending.rawValue {
                cell.setBuddie(RequestedBuddy[indexPath.row])
            }
            
            return cell
        }
    }

// MARK: Touch Event of Custom Segment

    override func actionsAfterLeftButtonPush() {
        self.navigationItem.rightBarButtonItem = nil
        self.tableView.reloadData()
    
        
    }
    override func actionsAfterRightButtonPush() {
        self.navigationItem.rightBarButtonItem = self.addBuddyButton
        self.callAllBuddyList()
    }
    
    func callAllBuddyList() {
        
        Loader.Show()
        BuddyRequestManager.sharedInstance.getAllbuddies { (success, serverMessage, ServerCode, Buddies, buddies) in
            
            Loader.Hide()
            if success{
                self.buddiesOverviewArray.removeAll()
                self.RequestedBuddy.removeAll()
                self.AcceptedBuddy.removeAll()
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
    
    @IBAction func unwindToFriendsOverview(segue: UIStoryboardSegue) {
        print(segue.sourceViewController)
    }

}