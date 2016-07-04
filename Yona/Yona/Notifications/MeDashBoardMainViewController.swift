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
    var rightTabData : [WeekActivityGoal] = []
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        registreTableViewCells()
        setupUI()
        self.navigationController?.navigationBarHidden = false
        navigationItem.title = NSLocalizedString("DASHBOARD", comment: "")
    }
    
    func registreTableViewCells () {
        var nib = UINib(nibName: "TimeBucketControlCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "TimeBucketControlCell")
        
        nib = UINib(nibName: "WeekScoreControlCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "WeekScoreControlCell")
        
        nib = UINib(nibName: "YonaDefaultTableHeaderView", bundle: nil)
        tableView.registerNib(nib, forHeaderFooterViewReuseIdentifier: "YonaDefaultTableHeaderView")
        
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
        return rightTabData.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if selectedTab == .left {
            return leftTabData.count
        }
        return rightTabData[section].activity.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if selectedTab == .left {
//todo: REPLACE THIS WITH THE CELLS FOR DAY VIEW
//            let cell: WeekScoreControlCell = tableView.dequeueReusableCellWithIdentifier("WeekScoreControlCell", forIndexPath: indexPath) as! WeekScoreControlCell
//            return cell
////
            let cell: TimeBucketControlCell = tableView.dequeueReusableCellWithIdentifier("TimeBucketControlCell", forIndexPath: indexPath) as! TimeBucketControlCell
            cell.setUpView(leftTabData[indexPath.row])
            return cell

        }
        
        
        let cell: WeekScoreControlCell = tableView.dequeueReusableCellWithIdentifier("WeekScoreControlCell", forIndexPath: indexPath) as! WeekScoreControlCell
        cell.setSingleActivity(rightTabData[indexPath.section].activity[indexPath.row])
        return cell
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 126
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if selectedTab == .left {
            return 0
        }
        return 44.0
    }

    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if selectedTab == .left {
            return nil
        }
        
        let cell : YonaDefaultTableHeaderView = tableView.dequeueReusableHeaderFooterViewWithIdentifier("YonaDefaultTableHeaderView") as! YonaDefaultTableHeaderView
        
        let dateTodate = NSDate()
        let yesterDate = dateTodate.dateByAddingTimeInterval(-60*60*24)
        let dateFormatter : NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "eeee, d MMMM, YYYY "
        
        if rightTabData[section].date.isSameDayAs(dateTodate) {
            cell.headerTextLabel.text = NSLocalizedString("Today", comment: "")
        } else if rightTabData[section].date.isSameDayAs(yesterDate) {
            cell.headerTextLabel.text =  NSLocalizedString("Yesterday", comment: "")
        } else {
            cell.headerTextLabel.text =  dateFormatter.stringFromDate(rightTabData[section].date)
        }
        return cell
        
    }
    

    //MARK: - implementations metods
    override func actionsAfterLeftButtonPush() {
        loadActivitiesForDay()
        // The subController must override this to have any action after the tabe selection
  
    }
    
    override func actionsAfterRightButtonPush() {
        // The subController must override this to have any action after the tabe selection
        loadActivitiesForWeek()
    }

    
    
    // MARK: - Data loaders
    
    func loadActivitiesForDay(page : Int = 0) {
        Loader.Show()
        ActivitiesRequestManager.sharedInstance.getActivityPrDay(3, page:page, onCompletion: { (success, serverMessage, serverCode, activitygoals, err) in
            if success {
                
                if let data = activitygoals {
                    self.leftTabData = data
                }
                self.tableView.reloadData()
                Loader.Hide()
            } else {
                Loader.Hide()
            }
            })
        
    }
    func loadActivitiesForWeek(page : Int = 0) {
        Loader.Show()
        ActivitiesRequestManager.sharedInstance.getActivityPrWeek(0, page:page, onCompletion: { (success, serverMessage, serverCode, activitygoals, err) in
            if success {
                
                if let data = activitygoals {
                    self.rightTabData = data
                }
                self.tableView.reloadData()
                Loader.Hide()
            } else {
                Loader.Hide()
            }
        })
        
    }
    
}