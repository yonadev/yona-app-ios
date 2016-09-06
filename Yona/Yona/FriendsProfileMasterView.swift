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
        setupUI()
        leftPage = 0
        if selectedTab == .left  {
            showLeftTab(leftTabMainView)
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

    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cell : YonaDefaultTableHeaderView = tableView.dequeueReusableHeaderFooterViewWithIdentifier("YonaDefaultTableHeaderView") as! YonaDefaultTableHeaderView
        if selectedTab == .left {
            let dateFormatter : NSDateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "eeee, d MMMM, YYYY "
            
            if timeLineData[section].date.isToday() {
                cell.headerTextLabel.text = NSLocalizedString("Today", comment: "")
            } else if timeLineData[section].date.isYesterday() {
                cell.headerTextLabel.text =  NSLocalizedString("Yesterday", comment: "")
            } else {
                cell.headerTextLabel.text =  dateFormatter.stringFromDate(timeLineData[section].date)
            }
            
        } else {
            if friendsSections.connected.rawValue == section && AcceptedBuddy.count == 0 {
                cell.headerTextLabel.text = nil
            } else if friendsSections.pending.rawValue == section && RequestedBuddy.count == 0 {
                cell.headerTextLabel.text = nil
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
            cell.isPanEnabled = false
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
                performSegueWithIdentifier(R.segue.friendsProfileMasterView.showFriendsDetailDay, sender: self)
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
        self.navigationItem.rightBarButtonItem = nil
        loadDataForTimeLine(leftPage)
        
    }
    
    func loadMoreRows() {
        if selectedTab == .left {
            loadDataForTimeLine(leftPage)
            
        }
    }

    
    func loadDataForTimeLine(page : Int) {
    
//        if timeLineData.count > 0 {
//            theTableView.reloadData()
//            return
//        }
        Loader.Show()
        ActivitiesRequestManager.sharedInstance.getTimeLineActivity (3,page: page,onCompletion: {(succes, serverMessage, serverCode, timeLineDayActivityOverview, error) in
            
            print("Success \(succes)")
            if timeLineDayActivityOverview != nil {
                if self.leftPage == 0 {
                    self.timeLineData = timeLineDayActivityOverview!
                } else {
                    self.timeLineData.appendContentsOf(timeLineDayActivityOverview!)
                }
                self.leftPage += 1

                
            }
            
            Loader.Hide()
            self.theTableView.reloadData()
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
                    self.theTableView.reloadData()
                } else {
                    print("No buddies")
                    self.theTableView.reloadData()
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
        print(segue.sourceViewController)
    }

    
    //MARK: - timeline cells
    func heightForTimeLineCell(indexPath :NSIndexPath) -> CGFloat {
        if timeLineData[indexPath.section].tableViewCells[indexPath.row] is String {
            
            return 30
        }

        if timeLineData[indexPath.section].tableViewCells[indexPath.row] is TimeLinedayActivitiesForUsers {
            let obj = timeLineData[indexPath.section].tableViewCells[indexPath.row] as!
TimeLinedayActivitiesForUsers
            if obj.goalType == "BudgetGoal" {
                return 70
            }
            if obj.goalType == "TimeZoneGoal" {
                return 80
                
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