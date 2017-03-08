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
    //    var refreshControl: UIRefreshControl!
    
    var timeLineData : [TimeLineDayActivityOverview] = []
    var animatedCells : [String] = []
    var scrolling = false
    var leftPage : Int = 0
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        isFromfriends = true
        
        //        refreshControl = UIRefreshControl()
        //        refreshControl!.attributedTitle = NSAttributedString(string: "Pull to refresh")
        //        refreshControl!.addTarget(self, action: #selector(reloadData), forControlEvents: UIControlEvents.ValueChanged)
        //        theTableView.addSubview(refreshControl)
        //setupUI()
        registreTableViewCells()
        //showLeftTab(leftTabMainView)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "FriendsProfileMasterView")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
        
        setupUI()
        leftPage = 0
        if selectedTab == .left  {
            showLeftTab(leftTabMainView)
        } else {
            showRightTab(rightTabMainView)
        }
        
    }
    
    
    
    func setupUI() {
        //Nav bar Back button.
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        theTableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    func registreTableViewCells () {
        var nib = UINib(nibName: "YonaUserTableViewCell", bundle: nil)
        theTableView.registerNib(nib, forCellReuseIdentifier: "YonaUserTableViewCell")
        nib = UINib(nibName: "TimeLineHeaderCell", bundle: nil)
        theTableView.registerNib(nib, forCellReuseIdentifier: "TimeLineHeaderCell")
        nib = UINib(nibName: "TimeLineTimeBucketCell", bundle: nil)
        theTableView.registerNib(nib, forCellReuseIdentifier: "TimeLineTimeBucketCell")
        nib = UINib(nibName: "TimeLineTimeZoneCell", bundle: nil)
        theTableView.registerNib(nib, forCellReuseIdentifier: "TimeLineTimeZoneCell")
        nib = UINib(nibName: "TimeLineNoGoCell", bundle: nil)
        theTableView.registerNib(nib, forCellReuseIdentifier: "TimeLineNoGoCell")
        nib = UINib(nibName: "YonaDefaultTableHeaderView", bundle: nil)
        theTableView.registerNib(nib, forHeaderFooterViewReuseIdentifier: "YonaDefaultTableHeaderView")
        
        
        
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
    
    // MARK: - Table view data source
    
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
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if selectedTab == .left {
            return 44
        }
        
        if friendsSections.connected.rawValue == section && AcceptedBuddy.count == 0 {
            return 0.0
        } else if friendsSections.pending.rawValue == section && RequestedBuddy.count == 0 {
            return 0.0
        }
        return 44
        
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cell : YonaDefaultTableHeaderView = tableView.dequeueReusableHeaderFooterViewWithIdentifier("YonaDefaultTableHeaderView") as! YonaDefaultTableHeaderView
        if selectedTab == .left {
            if timeLineData[section].date.isToday() {
                cell.headerTextLabel.text = NSLocalizedString("today", comment: "")
            } else if timeLineData[section].date.isYesterday() {
                cell.headerTextLabel.text =  NSLocalizedString("yesterday", comment: "")
            } else {
                
                cell.headerTextLabel.text =  timeLineData[section].date.fullDayMonthDateString()
            }
            
        } else {
            if friendsSections.connected.rawValue == section && AcceptedBuddy.count == 0 {
                return nil//cell.headerTextLabel.text = nil
            } else if friendsSections.pending.rawValue == section && RequestedBuddy.count == 0 {
                return nil//cell.headerTextLabel.text = nil
            }
            cell.headerTextLabel.text = friendsSections(rawValue: section)?.simpleDescription()
        }
        
        return cell
    }
    
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if selectedTab == .left {
            
            return heightForTimeLineCell(indexPath)
        } else {
            return 88
        }
        
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if selectedTab == .left {
            
            return timeLineData.count
        } else {
            return 2
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedTab == .left {
            
            return timeLineData[section].tableViewCells.count
        } else {
            if section == 0 {
                return AcceptedBuddy.count
            } else {
                return RequestedBuddy.count
            }
            if section == 0 {
                return 0
            }
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if selectedTab == .left {
            return cellForTimeLineView(indexPath)
        } else {
            
            let cell: YonaUserTableViewCell = tableView.dequeueReusableCellWithIdentifier("YonaUserTableViewCell", forIndexPath: indexPath) as! YonaUserTableViewCell
            cell.allowsSwipeAction = false
            if indexPath.section == friendsSections.connected.rawValue {
                cell.setBuddie(AcceptedBuddy[indexPath.row])
            } else if indexPath.section == friendsSections.pending.rawValue {
                cell.setBuddie(RequestedBuddy[indexPath.row])
            }
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if selectedTab == .right {
            
            if indexPath.section == friendsSections.connected.rawValue {
                performSegueWithIdentifier(R.segue.friendsProfileMasterView.showFriendDetails, sender: self)
            } else {
                tableView.deselectRowAtIndexPath(indexPath, animated: false)
            }
        } else {
            
            if timeLineData[indexPath.section].tableViewCells[indexPath.row] is TimeLinedayActivitiesForUsers {
                let obj = timeLineData[indexPath.section].tableViewCells[indexPath.row] as! TimeLinedayActivitiesForUsers
                if obj.buddyLink != nil {
                    performSegueWithIdentifier(R.segue.friendsProfileMasterView.showFriendsDetailDay, sender: self)
                } else {
                    
                    let storyboard = UIStoryboard(name: "MeDashBoard", bundle: nil)
                    let vc = storyboard.instantiateViewControllerWithIdentifier("MeDayDetailViewController") as! MeDayDetailViewController
                    vc.goalType = GoalType.NoGoGoalString.rawValue
                    let activitygoal = ActivitiesGoal(timeLinedayActivitiesForUsers: obj)
                    vc.activityGoal = activitygoal
                    
                    vc.navbarColor1 = self.navigationController?.navigationBar.backgroundColor
                    self.navigationController?.navigationBar.backgroundColor = UIColor.yiWindowsBlueColor()
                    let navbar = self.navigationController?.navigationBar as! GradientNavBar
                    
                    vc.navbarColor = navbar.gradientColor
                    navbar.gradientColor = UIColor.yiMidBlueColor()
                    
                    self.navigationController?.pushViewController(vc, animated: true)
                    return
                    
                    
                }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController is FriendsDayViewController {
            let controller = segue.destinationViewController as! FriendsDayViewController
            if let indexpath = theTableView.indexPathForSelectedRow {
                
                if indexpath.section == friendsSections.connected.rawValue {
                    controller.buddyToShow = AcceptedBuddy[indexpath.row]
                    
                } else if indexpath.section == friendsSections.pending.rawValue {
                    controller.buddyToShow = AcceptedBuddy[indexpath.row]
                }
                theTableView.deselectRowAtIndexPath(indexpath, animated: false)
            }
        }
        if segue.destinationViewController is FriendsDayDetailViewController {
            let controller = segue.destinationViewController as! FriendsDayDetailViewController
            if let section : Int = theTableView.indexPathForSelectedRow!.section {
                let data = timeLineData[section].tableViewCells[theTableView.indexPathForSelectedRow!.row] as! TimeLinedayActivitiesForUsers
                if let link = data.dayDetailLink {
                    controller.initialObjectLink = link
                }
                if let buddyToShow =  data.buddy {
                    controller.buddy = buddyToShow
                }
                let activitygoal = ActivitiesGoal(timeLinedayActivitiesForUsers: data)
                controller.activityGoal = activitygoal
            }
        }
        
    }
    
    
    // MARK: Touch Event of Custom Segment
    
    override func actionsAfterLeftButtonPush() {
        self.navigationItem.rightBarButtonItem = self.addBuddyButton
        //self.navigationItem.rightBarButtonItem = nil
        loadDataForTimeLine(leftPage)
        
    }
    
    func loadMoreRows() {
        if selectedTab == .left {
            loadDataForTimeLine(leftPage)
            
        }
    }
    
    
    func loadDataForTimeLine(page : Int) {
        Loader.Show()
        ActivitiesRequestManager.sharedInstance.getTimeLineActivity (3,page: page,onCompletion: {(succes, serverMessage, serverCode, timeLineDayActivityOverview, error) in
            if succes {
                print("Success \(succes)")
                if timeLineDayActivityOverview != nil {
                    if self.leftPage == 0 {
                        self.timeLineData = timeLineDayActivityOverview!
                    } else {
                        self.timeLineData.appendContentsOf(timeLineDayActivityOverview!)
                    }
                    self.leftPage += 1
                }
                if self.leftPage == 0 && timeLineDayActivityOverview == nil { // NO DATA
                    self.timeLineData = []
                }
            } else {
                Loader.Hide()
                if  let msg = serverMessage {
                    let alert = UIAlertController(title: NSLocalizedString("WARNING", comment: ""), message: msg, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                
                
            }
            Loader.Hide()
            
            dispatch_async(dispatch_get_main_queue(), {
                self.theTableView.reloadData()
            })
            
        })
    }
    
    
    override func actionsAfterRightButtonPush() {
        self.navigationItem.rightBarButtonItem = self.addBuddyButton
        loadAllBuddyList(self)
    }
    
    func reloadData() {
        if selectedTab == .left {
            loadDataForTimeLine(leftPage)
            
        } else {
            loadAllBuddyList(self)
        }
    }
    
    func loadAllBuddyList(sender:AnyObject) {
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
                    //print(self.AcceptedBuddy)
                    //print(self.RequestedBuddy)
                    dispatch_async(dispatch_get_main_queue(), {
                        self.theTableView.reloadData()
                    })
                    
                } else {
                    print("No buddies")
                    dispatch_async(dispatch_get_main_queue(), {
                        self.theTableView.reloadData()
                    })
                }
            } else {
                if let serverMessage = serverMessage {
                    self.displayAlertMessage(serverMessage, alertDescription: "")
                }
            }
            // self.refreshControl!.endRefreshing()
        }
    }
    
    @IBAction func unwindToFriendsOverview(segue: UIStoryboardSegue) {
        weak var tracker = GAI.sharedInstance().defaultTracker
        tracker!.send(GAIDictionaryBuilder.createEventWithCategory("ui_action", action: "unwindToFriendsOverview", label: "Back from friends profile to overview", value: nil).build() as [NSObject : AnyObject])
        
        print(segue.sourceViewController)
    }
    
    
    //MARK: - timeline cells
    func heightForTimeLineCell(indexPath :NSIndexPath) -> CGFloat {
        if timeLineData[indexPath.section].tableViewCells[indexPath.row] is String {
            
            return 30
        }
        
        if timeLineData[indexPath.section].tableViewCells[indexPath.row] is TimeLinedayActivitiesForUsers {
            let obj = timeLineData[indexPath.section].tableViewCells[indexPath.row] as! TimeLinedayActivitiesForUsers
            if obj.goalType == "BudgetGoal" {
                return 70
            }
            if obj.goalType == "TimeZoneGoal" {
                return 80
                
            }
            if obj.goalType == "NoGoGoal" {
                return 50
                
            }
            return 30
        }
        
        return 30
    }
    
    
    func cellForTimeLineView (indexPath :NSIndexPath) -> UITableViewCell {
        let obj = timeLineData[indexPath.section].tableViewCells[indexPath.row]
        if obj  is String {
            let cell: TimeLineHeaderCell = theTableView.dequeueReusableCellWithIdentifier("TimeLineHeaderCell", forIndexPath: indexPath) as! TimeLineHeaderCell
            cell.setCellTitle(timeLineData[indexPath.section].tableViewCells[indexPath.row] as! String)
            return cell
        } else if obj is TimeLinedayActivitiesForUsers {
            
            let theObj = obj as! TimeLinedayActivitiesForUsers
            
            if theObj.goalType == "BudgetGoal" {
                let cell: TimeLineTimeBucketCell = theTableView.dequeueReusableCellWithIdentifier("TimeLineTimeBucketCell", forIndexPath: indexPath) as! TimeLineTimeBucketCell
                
                cell.setData(theObj, animated: shouldAnimate(indexPath))
                return cell
            }
            if theObj.goalType == "TimeZoneGoal" {
                let cell: TimeLineTimeZoneCell = theTableView.dequeueReusableCellWithIdentifier("TimeLineTimeZoneCell", forIndexPath: indexPath) as! TimeLineTimeZoneCell
                
                cell.setTimeLineData(theObj, animated: shouldAnimate(indexPath))
                return cell
            }
            if theObj.goalType == "NoGoGoal" {
                let cell: TimeLineNoGoCell = theTableView.dequeueReusableCellWithIdentifier("TimeLineNoGoCell", forIndexPath: indexPath) as! TimeLineNoGoCell
                
                cell.setData(theObj)
                return cell
            }
            
            
        }
        
        return UITableViewCell(frame: CGRectZero)
    }
    
}
