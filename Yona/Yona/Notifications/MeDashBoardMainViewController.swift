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

    var leftTabData : [DayActivityOverview] = []
    var rightTabData : [WeekActivityGoal] = []
    
    var animatedCells : [Int] = []
    
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
            return leftTabData.count
        }
        return rightTabData.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if selectedTab == .left {
            if leftTabData.count == 0 {
                return 0
            }
            return leftTabData[section].activites.count
        }
        return rightTabData[section].activity.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if selectedTab == .left {
            return getCellForDayTableRow(indexPath)
        }
        
        
        let cell: WeekScoreControlCell = tableView.dequeueReusableCellWithIdentifier("WeekScoreControlCell", forIndexPath: indexPath) as! WeekScoreControlCell
        cell.setSingleActivity(rightTabData[indexPath.section].activity[indexPath.row])
        return cell
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if selectedTab == .left {
            return heigthForDayCell(indexPath)
        }
        return 126
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }

    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cell : YonaDefaultTableHeaderView = tableView.dequeueReusableHeaderFooterViewWithIdentifier("YonaDefaultTableHeaderView") as! YonaDefaultTableHeaderView
        if selectedTab == .left {
            
            let dateTodate = NSDate()
            let yesterDate = dateTodate.dateByAddingTimeInterval(-60*60*24)
            let dateFormatter : NSDateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "eeee, d MMMM, YYYY "
            
            if leftTabData[section].date.isSameDayAs(dateTodate) {
                cell.headerTextLabel.text = NSLocalizedString("Today", comment: "")
            } else if leftTabData[section].date.isSameDayAs(yesterDate) {
                cell.headerTextLabel.text =  NSLocalizedString("Yesterday", comment: "")
            } else {
                cell.headerTextLabel.text =  dateFormatter.stringFromDate(leftTabData[section].date)
            }
            return cell
       }
        
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

    //MARK:  ME DAY Cell methods
    func heigthForDayCell (indexPath : NSIndexPath) -> CGFloat{
    
        let activityGoal = leftTabData[indexPath.section].activites[indexPath.row]
        if let goaltype = activityGoal.goalType {

            if goaltype == "BudgetGoal" && activityGoal.maxDurationMinutes > 0 {
                
                return 165
            } else if goaltype == "TimeZoneGoal" {
                // Time Frame Control
                // TODO:  Changes this once the cell has been created
                return 165
            } else if goaltype == "BudgetGoal" && activityGoal.maxDurationMinutes > 0  {
                // NoGo Control
                // TODO:  Changes this once the cell has been created
                return 0
            }
        }
        return 0
    }
    
    
    func getCellForDayTableRow(indexPath : NSIndexPath) -> UITableViewCell {
        //
        
        let activityGoal = leftTabData[indexPath.section].activites[indexPath.row]
        if let goaltype = activityGoal.goalType {
            // TIMEBUCKETCELL
            if goaltype == "BudgetGoal" && activityGoal.maxDurationMinutes > 0 {
                let cell: TimeBucketControlCell = tableView.dequeueReusableCellWithIdentifier("TimeBucketControlCell", forIndexPath: indexPath) as! TimeBucketControlCell
                
                animateCell(cell, row: indexPath.row)
                cell.setUpView(activityGoal)
                animatedCells.append(indexPath.row)
                return cell
            }
            // Time Frame Control
                // TODO:  Changes this once the cell has been created
            else if goaltype == "TimeZoneGoal" {
                let cell: TimeBucketControlCell = tableView.dequeueReusableCellWithIdentifier("TimeBucketControlCell", forIndexPath: indexPath) as! TimeBucketControlCell

                animateCell(cell, row: indexPath.row)
                cell.setUpView(activityGoal)
                animatedCells.append(indexPath.row)
                return cell
            }
            // NoGo Control
            // TODO:  Changes this once the cell has been created
            else if goaltype == "BudgetGoal" && activityGoal.maxDurationMinutes == 0  {
                let cell: TimeBucketControlCell = tableView.dequeueReusableCellWithIdentifier("TimeBucketControlCell", forIndexPath: indexPath) as! TimeBucketControlCell

                animateCell(cell, row: indexPath.row)
                cell.setUpView(activityGoal)
                animatedCells.append(indexPath.row)
                return cell
            }
        }
        // WE SHOULD NEVER END HERE ....
        return UITableViewCell(frame: CGRectZero)
    }
    
    func animateCell(cell: TimeBucketControlCell, row:Int){
        if animatedCells.contains(row) {
            cell.animate = false
        } else {
            cell.animate = true
        }
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