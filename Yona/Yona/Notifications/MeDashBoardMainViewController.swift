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
    
    var animatedCells : [String] = []
    var corretcToday : NSDate = NSDate()
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        registreTableViewCells()
        setupUI()
        self.navigationController?.navigationBarHidden = false
        navigationItem.title = NSLocalizedString("DASHBOARD", comment: "")
        configureCorrectToday()
    }
    
    func registreTableViewCells () {
        var nib = UINib(nibName: "TimeBucketControlCell", bundle: nil)
        theTableView.registerNib(nib, forCellReuseIdentifier: "TimeBucketControlCell")
        
        nib = UINib(nibName: "NoGoCell", bundle: nil)
        theTableView.registerNib(nib, forCellReuseIdentifier: "NoGoCell")
        
        nib = UINib(nibName: "TimeZoneControlCell", bundle: nil)
        theTableView.registerNib(nib, forCellReuseIdentifier: "TimeZoneControlCell")
        
        nib = UINib(nibName: "WeekScoreControlCell", bundle: nil)
        theTableView.registerNib(nib, forCellReuseIdentifier: "WeekScoreControlCell")
        
        nib = UINib(nibName: "YonaDefaultTableHeaderView", bundle: nil)
        theTableView.registerNib(nib, forHeaderFooterViewReuseIdentifier: "YonaDefaultTableHeaderView")
        
    }
    
    func configureLeftBarItem () {
        UserRequestManager.sharedInstance.getUser(GetUserRequest.notAllowed) { (success, message, code, user) in
        
            let containView = UIView(frame: CGRectMake(0, 0,40, 40))
            
            let imageview = UIImageView(frame: CGRectMake(2, 2,36 , 36))
            imageview.layer.borderColor = UIColor.whiteColor().CGColor
            imageview.layer.borderWidth = 1
            imageview.layer.masksToBounds = true
            imageview.layer.cornerRadius = imageview.frame.size.width/2
            imageview.backgroundColor = UIColor.clearColor()
            
            
            containView.addSubview(imageview)
            
            let label = UILabel(frame: CGRectMake(0, 0, 40, 40))
            if let name = user?.firstName {
                if name.characters.count > 0 {//&& user?.characters.count > 0{
                    label.text =  "\(name.capitalizedString.characters.first!)"
                }
            }

            
            label.textAlignment = NSTextAlignment.Center
            label.textColor = UIColor.whiteColor()
            containView.addSubview(label)
            
            let barBut = UIBarButtonItem(customView: containView)
            barBut.action = #selector(MeDashBoardMainViewController.showUserProfile)
            barBut.target = self
            self.navigationItem.leftBarButtonItem = barBut
        }
    }
    
    func configureCorrectToday() {

        
        let userCalendar = NSCalendar.init(calendarIdentifier: NSISO8601Calendar)
        userCalendar?.minimumDaysInFirstWeek = 5
        userCalendar?.firstWeekday = 6
        let formatter = NSDateFormatter()
        formatter.dateFormat = "YYYY-ww"
        formatter.locale = NSLocale.currentLocale()
        formatter.calendar = userCalendar;
        let startdate = formatter.stringFromDate(NSDate().dateByAddingTimeInterval(60*60*24))
        if let aDate = formatter.dateFromString(startdate)  {
            corretcToday = aDate
        }
        

    }
    
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if selectedTab == .left {
            showLeftTab(leftTabMainView)
        } else {
            showRightTab(rightTabMainView)
        }
        
    }    // MARK: - private functions
    private func setupUI() {
           configureLeftBarItem()
        //showLeftTab(leftTabMainView)
        
    }
    
    @IBAction func unwindToProfileView(segue: UIStoryboardSegue) {
        print(segue.sourceViewController)
    }
    
    
    private func shouldAnimate(cell : NSIndexPath) -> Bool {
        let txt = "\(cell.section)-\(cell.row)"
        
        if animatedCells.indexOf(txt) == nil {
            print("Animated \(txt)")
            animatedCells.append(txt)
            return true
        }
        print("NO animated \(txt)")
        return false
    
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
        if rightTabData.count == 0 {
            return 0
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
            
            let dateFormatter : NSDateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "eeee, d MMMM, YYYY "
            
            if leftTabData[section].date.isToday() {
                cell.headerTextLabel.text = NSLocalizedString("Today", comment: "")
            } else if leftTabData[section].date.isYesterday() {
                cell.headerTextLabel.text =  NSLocalizedString("Yesterday", comment: "")
            } else {
                cell.headerTextLabel.text =  dateFormatter.stringFromDate(leftTabData[section].date)
            }
            return cell
       }
        // NSDATE has monday as first da
        let other = rightTabData[section].date.yearWeek
        
        let otherDateStart = corretcToday.dateByAddingTimeInterval(-60*60*24*7)
        let otherDate = otherDateStart.yearWeek
        
        if corretcToday.yearWeek == other {
            cell.headerTextLabel.text = NSLocalizedString("This week", comment: "")
        } else if other == otherDate {
            cell.headerTextLabel.text =  NSLocalizedString("Last week", comment: "")
        } else {
            let dateFormatter : NSDateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "dd MMM"
            cell.headerTextLabel.text = "\(dateFormatter.stringFromDate(otherDateStart)) - \(dateFormatter.stringFromDate(otherDateStart.dateByAddingTimeInterval(7*60*60*24)))"
        }
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if selectedTab == .right {
              performSegueWithIdentifier(R.segue.meDashBoardMainViewController.showWeekDetail, sender: self)
        }
        
        if selectedTab == .left {
            performSegueWithIdentifier(R.segue.meDashBoardMainViewController.showDayDetail, sender: self)
        }
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

    func showUserProfile() {
        performSegueWithIdentifier(R.segue.meDashBoardMainViewController.showProfile, sender: self)
        //showProfile
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
            } else if goaltype == "NoGoGoal" && activityGoal.maxDurationMinutes == 0  {
                // NoGo Control
                // TODO:  Changes this once the cell has been created
                return 86
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
                let cell: TimeBucketControlCell = theTableView.dequeueReusableCellWithIdentifier("TimeBucketControlCell", forIndexPath: indexPath) as! TimeBucketControlCell
                cell.setDataForView(activityGoal, animated: shouldAnimate(indexPath))
                return cell
            }
            // Time Frame Control
            // TODO:  Changes this once the cell has been created
            else if goaltype == "TimeZoneGoal" {
                let cell: TimeZoneControlCell = theTableView.dequeueReusableCellWithIdentifier("TimeZoneControlCell", forIndexPath: indexPath) as! TimeZoneControlCell
                cell.setDataForView(activityGoal, animated: true)
                return cell
            }
            // NoGo Control
            // TODO:  Changes this once the cell has been created
            else if goaltype == "NoGoGoal" && activityGoal.maxDurationMinutes == 0  {
                let cell: NoGoCell = theTableView.dequeueReusableCellWithIdentifier("NoGoCell", forIndexPath: indexPath) as! NoGoCell
                cell.setDataForView(activityGoal)
                return cell
            }
        }
        // WE SHOULD NEVER END HERE ....
        return UITableViewCell(frame: CGRectZero)
    }
    
    // MARK: - Data loaders
    
    func loadActivitiesForDay(page : Int = 0) {
        print("Entering day loader")
        Loader.Show()
        ActivitiesRequestManager.sharedInstance.getActivityPrDay(3, page:page, onCompletion: { (success, serverMessage, serverCode, activitygoals, err) in
            if success {
                
                if let data = activitygoals {
                    self.animatedCells.removeAll()
                    self.leftTabData = data
                }
                Loader.Hide()
                self.theTableView.reloadData()
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
           
            Loader.Hide()
            self.theTableView.reloadData()
                
            } else {
                Loader.Hide()
            }
        })
        
    }
    
    
    // MARK: Action methods
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController is MeWeekDetailWeekViewController {
            let controller = segue.destinationViewController as! MeWeekDetailWeekViewController
            if let section : Int = theTableView.indexPathForSelectedRow!.section {
                let data = rightTabData[section].activity[theTableView.indexPathForSelectedRow!.row]
                controller.initialObject = data
                
            }
        }
        
        if segue.destinationViewController is MeDayDetailViewController {
            let controller = segue.destinationViewController as! MeDayDetailViewController
            if let section : Int = theTableView.indexPathForSelectedRow!.section {
                let data = leftTabData[section].activites[theTableView.indexPathForSelectedRow!.row]
                controller.activityGoal = data
            }
        }
    }
    
}