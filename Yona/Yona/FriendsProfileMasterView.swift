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
    
    @IBOutlet var addBuddyButton: UIBarButtonItem!

    var buddiesOverviewArray = [Buddies]()
    var AcceptedBuddy = [Buddies]()
    var RequestedBuddy = [Buddies]()
    var timeLineData : [TimeLineDayActivityOverview] = []
    var animatedCells : [String] = []
    var scrolling = false
    var leftPage : Int = 0
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        isFromfriends = true
        registreTableViewCells()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "FriendsProfileMasterView")
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as? [AnyHashable: Any])
        setupUI()
        leftPage = 0
        if selectedTab == .left  {
            showLeftTab(leftTabMainView)
        }else{
            showRightTab(rightTabMainView)
        }
    }
    
    func setupUI() {
        //Nav bar Back button.
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: false)
        theTableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    func registreTableViewCells () {
        var nib = UINib(nibName: "YonaUserTableViewCell", bundle: nil)
        theTableView.register(nib, forCellReuseIdentifier: "YonaUserTableViewCell")
        nib = UINib(nibName: "TimeLineHeaderCell", bundle: nil)
        theTableView.register(nib, forCellReuseIdentifier: "TimeLineHeaderCell")
        nib = UINib(nibName: "TimeLineTimeBucketCell", bundle: nil)
        theTableView.register(nib, forCellReuseIdentifier: "TimeLineTimeBucketCell")
        nib = UINib(nibName: "TimeLineTimeZoneCell", bundle: nil)
        theTableView.register(nib, forCellReuseIdentifier: "TimeLineTimeZoneCell")
        nib = UINib(nibName: "TimeLineNoGoCell", bundle: nil)
        theTableView.register(nib, forCellReuseIdentifier: "TimeLineNoGoCell")
        nib = UINib(nibName: "YonaDefaultTableHeaderView", bundle: nil)
        theTableView.register(nib, forHeaderFooterViewReuseIdentifier: "YonaDefaultTableHeaderView")
    }
    
    fileprivate func shouldAnimate(_ cell : IndexPath) -> Bool {
        let txt = "\(cell.section)-\(cell.row)"
        if animatedCells.index(of: txt) == nil {
            print("Animated \(txt)")
            animatedCells.append(txt)
            return true
        }
        print("NO animated \(txt)")
        return false
    }
    
    // MARK: - Scroll view delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrolling = false
    }
    
    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell : YonaDefaultTableHeaderView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "YonaDefaultTableHeaderView") as! YonaDefaultTableHeaderView
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
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        if selectedTab == .left {
            return heightForTimeLineCell(indexPath)
        } else {
            return 88
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if selectedTab == .left {
            return timeLineData.count
        } else {
            return 2
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedTab == .left {
            return timeLineData[section].tableViewCells.count
        } else {
            if section == 0 {
                return AcceptedBuddy.count
            } else {
                return RequestedBuddy.count
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if selectedTab == .left {
            return cellForTimeLineView(indexPath)
        } else {
            let cell: YonaUserTableViewCell = tableView.dequeueReusableCell(withIdentifier: "YonaUserTableViewCell", for: indexPath) as! YonaUserTableViewCell
            cell.isPanEnabled = false
            if indexPath.section == friendsSections.connected.rawValue {
                cell.setBuddie(AcceptedBuddy[indexPath.row])
            } else if indexPath.section == friendsSections.pending.rawValue {
                cell.setBuddie(RequestedBuddy[indexPath.row])
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        if selectedTab == .right {
            if indexPath.section == friendsSections.connected.rawValue {
                performSegue(withIdentifier: R.segue.friendsProfileMasterView.showFriendDetails, sender: self)
            } else {
                tableView.deselectRow(at: indexPath, animated: false)
            }
        } else {
            if timeLineData[indexPath.section].tableViewCells[indexPath.row] is TimeLinedayActivitiesForUsers {
                let obj = timeLineData[indexPath.section].tableViewCells[indexPath.row] as! TimeLinedayActivitiesForUsers
                if obj.buddyLink != nil {
                    performSegue(withIdentifier: R.segue.friendsProfileMasterView.showFriendsDetailDay, sender: self)
                } else {
                    let storyboard = UIStoryboard(name: "MeDashBoard", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "MeDayDetailViewController") as! MeDayDetailViewController
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is FriendsDashboardViewController {
            let controller = segue.destination as! FriendsDashboardViewController
            if let indexpath = theTableView.indexPathForSelectedRow {
                if indexpath.section == friendsSections.connected.rawValue {
                    controller.buddyToShow = AcceptedBuddy[indexpath.row]
                } else if indexpath.section == friendsSections.pending.rawValue {
                    controller.buddyToShow = AcceptedBuddy[indexpath.row]
                }
                theTableView.deselectRow(at: indexpath, animated: false)
            }
        }
        if segue.destination is FriendsDayDetailViewController {
            let controller = segue.destination as! FriendsDayDetailViewController
            if let section : Int = theTableView.indexPathForSelectedRow?.section {
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
        loadDataForTimeLine(leftPage)
    }
    
    func loadMoreRows() {
        if selectedTab == .left {
            loadDataForTimeLine(leftPage)
        }
    }
    
    func loadDataForTimeLine(_ page : Int) {
        Loader.Show()
        //Not sure why but the completion block is called twice
        // Once empty and once filled, So taking the boolean to reload table and hide loader,
        // So that nothing is broken by this change
        var isFirstCompletionCall: Bool = false
        ActivitiesRequestManager.sharedInstance.getTimeLineActivity (3,page: page,onCompletion: {(succes, serverMessage, serverCode, timeLineDayActivityOverview, error) in
            if succes {
                print("Success \(succes)")
                isFirstCompletionCall = !isFirstCompletionCall
                if timeLineDayActivityOverview != nil {
                    if self.leftPage == 0 {
                        self.timeLineData = timeLineDayActivityOverview!
                    } else {
                        self.timeLineData.append(contentsOf: timeLineDayActivityOverview!)
                    }
                    self.leftPage += 1
                }
                if self.leftPage == 0 && timeLineDayActivityOverview == nil { // NO DATA
                    self.timeLineData = []
                }
            } else {
                Loader.Hide()
                if  let msg = serverMessage {
                    let alert = UIAlertController(title: NSLocalizedString("WARNING", comment: ""), message: msg, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
            DispatchQueue.main.async(execute: {
                if  isFirstCompletionCall == false {
                    self.theTableView.reloadData()
                    Loader.Hide()
                }
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
    
    func loadAllBuddyList(_ sender:AnyObject) {
        Loader.Show()
        BuddyRequestManager.sharedInstance.getAllbuddies { (success, serverMessage, ServerCode, Buddies, buddies) in
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
                    DispatchQueue.main.async(execute: {
                        self.theTableView.reloadData()
                        Loader.Hide()
                    })
                } else {
                    print("No buddies")
                    DispatchQueue.main.async(execute: {
                        self.theTableView.reloadData()
                        Loader.Hide()
                    })
                }
            } else {
                if let serverMessage = serverMessage {
                    self.displayAlertMessage(serverMessage, alertDescription: "")
                }
                Loader.Hide()
            }
        }
    }
    
    @IBAction func unwindToFriendsOverview(_ segue: UIStoryboardSegue) {
        weak var tracker = GAI.sharedInstance().defaultTracker
        tracker!.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action", action: "unwindToFriendsOverview", label: "Back from friends profile to overview", value: nil).build() as? [AnyHashable: Any])
        print(segue.source)
    }
    
    //MARK: - timeline cells
    func heightForTimeLineCell(_ indexPath :IndexPath) -> CGFloat {
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
    
    func cellForTimeLineView (_ indexPath :IndexPath) -> UITableViewCell {
        let obj = timeLineData[indexPath.section].tableViewCells[indexPath.row]
        if obj  is String {
            let cell: TimeLineHeaderCell = theTableView.dequeueReusableCell(withIdentifier: "TimeLineHeaderCell", for: indexPath) as! TimeLineHeaderCell
            cell.setCellTitle(timeLineData[indexPath.section].tableViewCells[indexPath.row] as! String)
            return cell
        } else if obj is TimeLinedayActivitiesForUsers {
            let theObj = obj as! TimeLinedayActivitiesForUsers
            if theObj.goalType == "BudgetGoal" {
                let cell: TimeLineTimeBucketCell = theTableView.dequeueReusableCell(withIdentifier: "TimeLineTimeBucketCell", for: indexPath) as! TimeLineTimeBucketCell
                cell.setData(theObj, animated: shouldAnimate(indexPath))
                return cell
            }
            if theObj.goalType == "TimeZoneGoal" {
                let cell: TimeLineTimeZoneCell = theTableView.dequeueReusableCell(withIdentifier: "TimeLineTimeZoneCell", for: indexPath) as! TimeLineTimeZoneCell
                cell.setTimeLineData(theObj, animated: shouldAnimate(indexPath))
                return cell
            }
            if theObj.goalType == "NoGoGoal" {
                let cell: TimeLineNoGoCell = theTableView.dequeueReusableCell(withIdentifier: "TimeLineNoGoCell", for: indexPath) as! TimeLineNoGoCell
                cell.setData(theObj)
                return cell
            }
        }
        return UITableViewCell(frame: CGRect.zero)
    }
}
