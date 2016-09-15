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

    @IBOutlet weak var leftBarItem  : UIBarButtonItem!
    var leftTabData : [DayActivityOverview] = []
    var rightTabData : [WeekActivityGoal] = []
    var weekDayDetailLink : String?
    
    var animatedCells : [String] = []
    var corretcToday : NSDate = NSDate()
    var leftPage : Int = 0
    var rightPage : Int = 0

    var size : Int = 3
    var loading = false
    var scrolling = false
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        registreTableViewCells()
        setupUI()
        self.navigationController?.navigationBarHidden = false
        navigationItem.title = NSLocalizedString("DASHBOARD", comment: "")
        configureCorrectToday()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //make sure we set the nav bar to correct purple colours
        if let navbar = navigationController?.navigationBar as? GradientNavBar{
            navbar.backgroundColor = UIColor.yiGrapeColor()
            navbar.gradientColor = UIColor.yiGrapeTwoColor()
        }
        configurProfileBarItem()
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
    
    @IBAction func backAction(sender : AnyObject) {
        dispatch_async(dispatch_get_main_queue(), {
            self.navigationController?.popViewControllerAnimated(true)
        })
        
    }
    
    func configurProfileBarItem()  {
        
        
        UserRequestManager.sharedInstance.getUser(GetUserRequest.allowed) { (success, message, code, user) in
           if let name = user?.firstName {
                if name.characters.count > 0 {//&& user?.characters.count > 0{
                    let btnName = UIButton()
                    let txt = "\(name.capitalizedString.characters.first!)"
                    btnName.setTitle(txt, forState: .Normal)
                    btnName.frame = CGRectMake(0, 0, 35, 35)
                    btnName.addTarget(self, action: #selector(self.showUserProfile(_:)), forControlEvents: .TouchUpInside)
                    
                    btnName.backgroundColor = UIColor.clearColor()
                    btnName.layer.cornerRadius = btnName.frame.size.width/2
                    btnName.layer.borderWidth = 1
                    btnName.layer.borderColor = UIColor.whiteColor().CGColor
                    
                    let rightBarButton = UIBarButtonItem()
                    rightBarButton.customView = btnName
                    self.navigationItem.leftBarButtonItem = rightBarButton

                    
                    
//                    self.leftBarItem.title = "\(name.capitalizedString.characters.first!)"
//                    self.leftBarItem.addCircle()
                }
            }            
        }
    }
    
    func configureCorrectToday() {
        let userCalendar = NSCalendar.init(calendarIdentifier: NSISO8601Calendar)
        userCalendar?.minimumDaysInFirstWeek = 5
        userCalendar?.firstWeekday = 1
        let formatter = NSDateFormatter()
        formatter.dateFormat = "YYYY-ww"
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        //formatter.locale = NSLocale.currentLocale()
        formatter.calendar = userCalendar;
//        let startdate = formatter.stringFromDate(NSDate().dateByAddingTimeInterval(60*60*24))
        let startdate = formatter.stringFromDate(NSDate())
        if let aDate = formatter.dateFromString(startdate)  {
            corretcToday = aDate
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        leftPage = 0
        rightPage = 0
        if selectedTab == .left {
            showLeftTab(leftTabMainView)
        } else {
            showRightTab(rightTabMainView)
        }
        
    }    // MARK: - private functions
    private func setupUI() {
         //  configureLeftBarItem()
        //showLeftTab(leftTabMainView)
        //theTableView.alwaysBounceVertical = false
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

    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        let bounds = scrollView.bounds
        let size = scrollView.contentSize
        let inset = scrollView.contentInset
        let y = CGFloat(offset.y + bounds.size.height - inset.bottom)
        let h = CGFloat(size.height)
        
        let reload_distance = CGFloat(80)  // MUST find right distance ....
        if(y > (h + reload_distance)) {
            
            if !scrolling {
                scrolling = true
                loadMoreRows()
            }
        } else if y == 0 {
            scrolling = false
        }
    }
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        scrolling = false
    }
    
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
        cell.delegate = self
        return cell
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if selectedTab == .left {
            return heigthForDayCell(indexPath)
        }
        return 126
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 53.0
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
    
    
    //MARK: - week delegate methods
    func didSelectDayInWeek(goal: SingleDayActivityGoal, aDate : NSDate) {
    
        weekDayDetailLink = goal.yonadayDetails
        performSegueWithIdentifier(R.segue.meDashBoardMainViewController.showDayDetail, sender: self)
    }
    
    //MARK: - implementations metods
    override func actionsAfterLeftButtonPush() {
        loadActivitiesForDay(leftPage)
        // The subController must override this to have any action after the tabe selection
  
    }
    
    override func actionsAfterRightButtonPush() {
        // The subController must override this to have any action after the tabe selection
        loadActivitiesForWeek(rightPage)
    }

    @IBAction func showUserProfile(sender : AnyObject) {
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
                return 165
            } else if goaltype == "NoGoGoal" && activityGoal.maxDurationMinutes == 0  {
                // NoGo Control
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

            else if goaltype == "TimeZoneGoal" {
                let cell: TimeZoneControlCell = theTableView.dequeueReusableCellWithIdentifier("TimeZoneControlCell", forIndexPath: indexPath) as! TimeZoneControlCell
                cell.setDataForView(activityGoal, animated: true)
                return cell
            }
            // NoGo Control
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
    
    func loadMoreRows() {
        if selectedTab == .left {
            loadActivitiesForDay(leftPage)
        
        }
        if selectedTab == .right {
            loadActivitiesForWeek(rightPage)
            
        }
    }
    
    func loadActivitiesForDay(page : Int = 0) {
        if loading {
            return
        }
        loading = true
        print("Entering day loader :\(leftPage) ")
        Loader.Show()
        ActivitiesRequestManager.sharedInstance.getActivityPrDay(size, page:page, onCompletion: { (success, serverMessage, serverCode, activitygoals, err) in
            if success {
                
                if let data = activitygoals {
                    if data.count > 0  {
                        self.animatedCells.removeAll()
                        if self.leftPage == 0 {
                            self.leftTabData = data
                        } else {
                            self.leftTabData.appendContentsOf(data)
                        }
                        self.leftPage += 1
                    }
                }
                Loader.Hide()
                self.theTableView.reloadData()
                self.loading = false
            } else {
                Loader.Hide()
                self.loading = false
            }
            })
        
    }
    func loadActivitiesForWeek(page : Int = 0) {
        if loading {
            return
        }

        print("Entering day loader :\(leftPage) ")
        Loader.Show()
        ActivitiesRequestManager.sharedInstance.getActivityPrWeek(size, page:page, onCompletion: { (success, serverMessage, serverCode, activitygoals, err) in
            if success {
                
                if let data = activitygoals {
                    if data.count > 0  {
                        if self.rightPage == 0 {
                            self.rightTabData = data
                        } else {
                            self.rightTabData.appendContentsOf(data)
                        }
                        self.rightPage += 1
                    }
                }
           
            Loader.Hide()
            self.theTableView.reloadData()
            self.loading = false
            } else {
                Loader.Hide()
                self.loading = false
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
            if let path = weekDayDetailLink {
                controller.initialObjectLink = path
                weekDayDetailLink = nil
                
            } else  if let section : Int = theTableView.indexPathForSelectedRow!.section {
                let data = leftTabData[section].activites[theTableView.indexPathForSelectedRow!.row]
                controller.activityGoal = data
            }
            
        }
    }
    
}