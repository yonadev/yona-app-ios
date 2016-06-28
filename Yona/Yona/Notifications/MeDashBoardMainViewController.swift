//
//  NotificationsOverviewController.swift
//  Yona
//
//  Created by Ben Smith on 19/05/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

class MeDashBoardMainViewController: YonaTwoButtonsTableViewController {
    
    @IBOutlet var userDetailButton: UIBarButtonItem!
    @IBOutlet var notificationsButton: UIButton?

    var leftTabData : [ActivitiesGoal] = []
    var rightTabData : [ActivitiesGoal] = []
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        //OverviewTabAction(overviewTabView)
        setupUI()
        self.navigationController?.navigationBarHidden = false
        navigationItem.title = NSLocalizedString("DASHBOARD", comment: "")
    }
    
    
    
    
    // MARK: - private functions
    private func setupUI() {
        showLeftTab(leftTabMainView)
        
    }
    
    @IBAction func unwindToProfileView(segue: UIStoryboardSegue) {
        print(segue.sourceViewController)
    }
    
    // MARK: - tableview Override

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if selectedTab == .left {
            return 1
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if selectedTab == .left {
            return leftTabData.count
        }
        return rightTabData.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        return cell
    }


    //MARK: - implementations metods
    override func actionsAfterLeftButtonPush() {
        loadActivitiesForDay()
        // The subController must override this to have any action after the tabe selection
  
    }
    
    override func actionsAfterRightButtonPush() {
        // The subController must override this to have any action after the tabe selection
    
    }

    
    
    // MARK: - Data loaders
    
    func loadActivitiesForDay(page : Int = 0) {
    
        ActivitiesRequestManager.sharedInstance.getActivityPrDay(3, page:0, onCompletion: { (success, serverMessage, serverCode, activitygoals, err) in
            if success {
                
                if let data = activitygoals {
                    self.leftTabData = data
                }
                self.tableView.reloadData()
            }
            })
        
    }
    
}