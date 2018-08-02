//
//  NotificationsOverviewController.swift
//  Yona
//
//  Created by Ben Smith on 19/05/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation
import Kingfisher

class MeDashBoardMainViewController: YonaTwoButtonsTableViewController {
    
    @IBOutlet var userDetailButton: UIBarButtonItem!
    @IBOutlet weak var leftBarItem  : UIBarButtonItem!

    var notificationsButton: MIBadgeButton?
    var leftTabData : [DayActivityOverview] = []
    var rightTabData : [WeekActivityGoal] = []
    var weekDayDetailLink : String?
    
    var animatedCells : [String] = []
    var corretcToday : Date = Date()
    var leftPage : Int = 0
    var rightPage : Int = 0

    var size : Int = 3
    var loading = false
    var scrolling = false
    var avtarImg : UIImageView = UIImageView()
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        registreTableViewCells()

        self.navigationController?.isNavigationBarHidden = false
        let title = NSLocalizedString("DASHBOARD", comment: "")
        navigationItem.title = title.uppercased()
        configureCorrectToday()
        isFromfriends = false
        if let navbar = navigationController?.navigationBar as? GradientNavBar{
            navbar.backgroundColor = UIColor.yiGrapeColor()
            navbar.gradientColor = UIColor.yiGrapeTwoColor()
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loading = false
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "MeDashBoardMainViewController")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as! [AnyHashable: Any])
        
        
        configurProfileBarItem()
        if !isFromfriends {
            configureRightTabBar()
        } else {
            self.navigationItem.rightBarButtonItems = nil
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    
    func registreTableViewCells () {
        var nib = UINib(nibName: "TimeBucketControlCell", bundle: nil)
        theTableView.register(nib, forCellReuseIdentifier: "TimeBucketControlCell")
        
        nib = UINib(nibName: "NoGoCell", bundle: nil)
        theTableView.register(nib, forCellReuseIdentifier: "NoGoCell")
        
        nib = UINib(nibName: "TimeZoneControlCell", bundle: nil)
        theTableView.register(nib, forCellReuseIdentifier: "TimeZoneControlCell")
        
        nib = UINib(nibName: "WeekScoreControlCell", bundle: nil)
        theTableView.register(nib, forCellReuseIdentifier: "WeekScoreControlCell")
        
        nib = UINib(nibName: "YonaDefaultTableHeaderView", bundle: nil)
        theTableView.register(nib, forHeaderFooterViewReuseIdentifier: "YonaDefaultTableHeaderView")
        
    }
    
    @IBAction func backAction(_ sender : AnyObject) {
        
        weak var tracker = GAI.sharedInstance().defaultTracker
        tracker!.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action", action: "backAction", label: "MeDashboard", value: nil).build() as! [AnyHashable: Any])

        DispatchQueue.main.async(execute: {
            self.navigationController?.popViewController(animated: true)
        })
        
    }
    
    func configurProfileBarItem()  {
        UserRequestManager.sharedInstance.getUser(GetUserRequest.allowed) { (success, message, code, user) in
            if let link = user?.userAvatarLink,
                let URL = URL(string: link) {
                
                self.avtarImg.kf.setImage(with: URL, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, imageURL) -> () in
                    let btnName = UIButton()
                    btnName.frame = CGRect(x:0, y:0, width:32, height:32)
                    btnName.setImage(image?.resizeTo(newWidth: 32, newHeight: 32), for: .normal)
                    btnName.addTarget(self, action: #selector(self.showUserProfile(_:)), for: .touchUpInside)
                    
                    btnName.backgroundColor = UIColor.clear
                    btnName.layer.cornerRadius = btnName.frame.size.width/2
                    btnName.layer.borderWidth = 1
                    btnName.layer.borderColor = UIColor.white.cgColor
                    btnName.clipsToBounds = true
                    let rightBarButton = UIBarButtonItem()
                    rightBarButton.customView = btnName
                    self.navigationItem.leftBarButtonItem = rightBarButton
                    
                })
                
//                self.avtarImg.kf_setImageWithURL(URL, placeholderImage: nil,
//                                            optionsInfo: nil,
//                                            progressBlock: nil,
//                                            completionHandler: { (image, error, cacheType, imageURL) -> () in
//                                                    let btnName = UIButton()
//                                                    btnName.frame = CGRectMake(0, 0, 32, 32)
//                                                    btnName.setImage(image, forState: UIControlState.Normal)
//                                                    btnName.addTarget(self, action: #selector(self.showUserProfile(_:)), forControlEvents: .TouchUpInside)
//
//                                                    btnName.backgroundColor = UIColor.clearColor()
//                                                    btnName.layer.cornerRadius = btnName.frame.size.width/2
//                                                    btnName.layer.borderWidth = 1
//                                                    btnName.layer.borderColor = UIColor.whiteColor().CGColor
//                                                    btnName.clipsToBounds = true
//                                                    let rightBarButton = UIBarButtonItem()
//                                                    rightBarButton.customView = btnName
//                                                    self.navigationItem.leftBarButtonItem = rightBarButton
//
//                    }
//                )
            } else if let name = user?.firstName {
                if name.characters.count > 0 {//&& user?.characters.count > 0{
                    let btnName = UIButton()
                    let txt = "\(name.capitalized.characters.first!)"
                    btnName.setTitle(txt, for: UIControlState())
                    btnName.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
                    btnName.addTarget(self, action: #selector(self.showUserProfile(_:)), for: .touchUpInside)
                    
                    btnName.backgroundColor = UIColor.clear
                    btnName.layer.cornerRadius = btnName.frame.size.width/2
                    btnName.layer.borderWidth = 1
                    btnName.layer.borderColor = UIColor.white.cgColor
                    
                    let rightBarButton = UIBarButtonItem()
                    rightBarButton.customView = btnName
                    self.navigationItem.leftBarButtonItem = rightBarButton
                }
            }
            
        }
    }

    func configureRightTabBar() {
        MessageRequestManager.sharedInstance.getUnReadMessages({
            (success, message, code, text, theMessages) in
            if let allMessages = theMessages {
                for aMessage in allMessages {
                    MessageRequestManager.sharedInstance.postProcessLink(aMessage, onCompletion: { (success, message, code) in
                        if success {
                                print ("Did process message" )
                        }
                        //so not every link will have one, so what now?
                        print(message)
                    })
                }
            }
            if let count = MessageRequestManager.sharedInstance.totalSize {
                let txt = "\(count)"
                let rightBarButton = UIBarButtonItem()
                self.notificationsButton = MIBadgeButton.init(frame: CGRect(x: 0, y: 0, width: (UIImage(named: "icnNotifications")?.size.width)!, height: (UIImage(named: "icnNotifications")?.size.height)!))
                self.notificationsButton?.badgeString = txt
                self.notificationsButton?.hideWhenZero = true
                self.notificationsButton?.badgeTextColor = UIColor.yiWhiteColor()
                self.notificationsButton?.badgeBackgroundColor = UIColor.yiDarkishPinkColor()
                self.notificationsButton?.setImage(UIImage(named: "icnNotifications"), for: UIControlState())
                self.notificationsButton?.addTarget(self, action: #selector(self.showNotifications(_:)), for: .touchUpInside)
                self.notificationsButton?.badgeEdgeInsets = UIEdgeInsetsMake(17, 0, 0, 32)
                rightBarButton.customView = self.notificationsButton
                self.navigationItem.rightBarButtonItems = [rightBarButton]

            }
        })
    
    }
    
    func configureCorrectToday() {
        var userCalendar = Calendar.init(identifier: Calendar.Identifier.iso8601)
        userCalendar.minimumDaysInFirstWeek = 5
        userCalendar.firstWeekday = 1
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-ww"
        formatter.locale = Locale(identifier: "en_US")
        formatter.calendar = userCalendar;
        let startdate = formatter.string(from: Date())
        if let aDate = formatter.date(from: startdate)  {
            corretcToday = aDate
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        leftPage = 0
        rightPage = 0
        if selectedTab == .left {
            showLeftTab(leftTabMainView)
        } else {
            showRightTab(rightTabMainView)
        }
        
    }
    
    @IBAction func unwindToProfileView(_ segue: UIStoryboardSegue) {
        print(segue.source)
    }
    
    // MARK: - private functions
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
    // MARK: - tableview Override

    
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if selectedTab == .left {
            return leftTabData.count
        }
        return rightTabData.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
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
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if selectedTab == .left {
            return getCellForDayTableRow(indexPath)
        }
        
        let cell: WeekScoreControlCell = tableView.dequeueReusableCell(withIdentifier: "WeekScoreControlCell", for: indexPath) as! WeekScoreControlCell
        cell.setSingleActivity(rightTabData[indexPath.section].activity[indexPath.row])
        cell.delegate = self
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        if selectedTab == .left {
            return heigthForDayCell(indexPath)
        }
        return 126
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 53.0
    }

    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cell : YonaDefaultTableHeaderView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "YonaDefaultTableHeaderView") as! YonaDefaultTableHeaderView
        let date: String
        if selectedTab == .left {
            if leftTabData[section].date.isToday() {
                date = NSLocalizedString("today", comment: "")
            } else if leftTabData[section].date.isYesterday() {
                date =  NSLocalizedString("yesterday", comment: "")
            } else {
                date =  leftTabData[section].date.fullDayMonthDateString()
            }
        } else {
            // NSDATE has monday as first day
            let other = rightTabData[section].date.yearWeek
            
            let otherDateStart = corretcToday.addingTimeInterval(-60*60*24*7)
            let otherDate = otherDateStart.yearWeek
            
            if corretcToday.yearWeek == other {
                date = NSLocalizedString("this_week", comment: "")
            } else if other == otherDate {
                date =  NSLocalizedString("last_week", comment: "")
            } else {
                date = "\(otherDateStart.shortDayMonthDateString()) - \(otherDateStart.addingTimeInterval(7*60*60*24).shortDayMonthDateString())"
            }
        }
        cell.headerTextLabel.text = date.uppercased()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        if selectedTab == .right {
            performSegue(withIdentifier: R.segue.meDashBoardMainViewController.showWeekDetail, sender: self)
        }
        
        if selectedTab == .left {
            performSegue(withIdentifier: R.segue.meDashBoardMainViewController.showDayDetail, sender: self)
        }
    }
    
    
    //MARK: - week delegate methods
    func didSelectDayInWeek(_ goal: SingleDayActivityGoal, aDate : Date) {
    
        weekDayDetailLink = goal.yonadayDetails
        performSegue(withIdentifier: R.segue.meDashBoardMainViewController.showDayDetail, sender: self)
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

    @IBAction func showUserProfile(_ sender : AnyObject) {
        weak var tracker = GAI.sharedInstance().defaultTracker
        tracker!.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action", action: "showUserProfileFromDashboard", label: "Show user profile from dashboard", value: nil).build() as! [AnyHashable: Any])

        performSegue(withIdentifier: R.segue.meDashBoardMainViewController.showProfile, sender: self)
        
    }

    @IBAction func showNotifications(_ sender : AnyObject) {
        weak var tracker = GAI.sharedInstance().defaultTracker
        tracker!.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action", action: "showNotifications", label: "Show Notifications button pressed", value: nil).build() as! [AnyHashable: Any])
        
        performSegue(withIdentifier: R.segue.meDashBoardMainViewController.showNotifications, sender: self)
    }

    
    //MARK:  ME DAY Cell methods
    func heigthForDayCell (_ indexPath : IndexPath) -> CGFloat{
    
        let activityGoal = leftTabData[indexPath.section].activites[indexPath.row]
        if let goaltype = activityGoal.goalType {

            if goaltype == "BudgetGoal" && activityGoal.maxDurationMinutes > 0 {
                return 135
            } else if goaltype == "TimeZoneGoal" {
                return 135
            } else if goaltype == "NoGoGoal" && activityGoal.maxDurationMinutes == 0  {
                // NoGo Control
                return 86
            }
        }
        return 0
    }
    
    
    func getCellForDayTableRow(_ indexPath : IndexPath) -> UITableViewCell {
        //
        
        let activityGoal = leftTabData[indexPath.section].activites[indexPath.row]
        if let goaltype = activityGoal.goalType {
            // TIMEBUCKETCELL
            if goaltype == "BudgetGoal" && activityGoal.maxDurationMinutes > 0 {
                let cell: TimeBucketControlCell = theTableView.dequeueReusableCell(withIdentifier: "TimeBucketControlCell", for: indexPath) as! TimeBucketControlCell
                cell.setDataForView(activityGoal, animated: shouldAnimate(indexPath))
                return cell
            }
            // Time Frame Control

            else if goaltype == "TimeZoneGoal" {
                let cell: TimeZoneControlCell = theTableView.dequeueReusableCell(withIdentifier: "TimeZoneControlCell", for: indexPath) as! TimeZoneControlCell
                cell.setDataForView(activityGoal, animated: true)
                return cell
            }
            // NoGo Control
            else if goaltype == "NoGoGoal" && activityGoal.maxDurationMinutes == 0  {
                let cell: NoGoCell = theTableView.dequeueReusableCell(withIdentifier: "NoGoCell", for: indexPath) as! NoGoCell
                cell.setDataForView(activityGoal)
                return cell
            }
        }
        // WE SHOULD NEVER END HERE ....
        return UITableViewCell(frame: CGRect.zero)
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
    
    func loadActivitiesForDay(_ page : Int = 0) {
//        NSLog("loadActivitiesForDay %f", loading)
        if loading {
            return
        }
        loading = true

        Loader.Show()
        ActivitiesRequestManager.sharedInstance.getActivityPrDay(size, page:page, onCompletion: { (success, serverMessage, serverCode, activitygoals, err) in
            if success {
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
            } else {
                Loader.Hide()
                self.loading = false
                
                DispatchQueue.main.async(execute: {
                    let alert = UIAlertView.init(title: NSLocalizedString("dashboard.error.title", comment: ""),
                        message: err?.localizedDescription,
                        delegate: nil,
                        cancelButtonTitle: NSLocalizedString("dashboard.error.button", comment: ""))
                    alert.show()
                })
            }
        })
        
    }
    
    func loadActivitiesForWeek(_ page : Int = 0) {
        if loading {
            return
        }
        loading = true

        Loader.Show()
        ActivitiesRequestManager.sharedInstance.getActivityPrWeek(size, page:page, onCompletion: { (success, serverMessage, serverCode, activitygoals, err) in
            if success {
                
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
            } else {
                Loader.Hide()
                self.loading = false
                
                DispatchQueue.main.async(execute: {
                    let alert = UIAlertView.init(title: NSLocalizedString("dashboard.error.title", comment: ""),
                        message: err?.localizedDescription,
                        delegate: nil,
                        cancelButtonTitle: NSLocalizedString("dashboard.error.button", comment: ""))
                    alert.show()
                })
            }
        })
        
    }
    
    
    // MARK: Action methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is MeWeekDetailWeekViewController {
            let controller = segue.destination as! MeWeekDetailWeekViewController
            if let section : Int = theTableView.indexPathForSelectedRow!.section {
                let data = rightTabData[section].activity[theTableView.indexPathForSelectedRow!.row]
                controller.title = data.goalName?.uppercased()
                controller.initialObject = data
                
            }
        }
        
        if segue.destination is MeDayDetailViewController {
            let controller = segue.destination as! MeDayDetailViewController
            if let path = weekDayDetailLink {
                controller.initialObjectLink = path
                weekDayDetailLink = nil
                
            } else  if let section : Int = theTableView.indexPathForSelectedRow!.section {
                let data = leftTabData[section].activites[theTableView.indexPathForSelectedRow!.row]
                controller.title = data.goalName?.uppercased()
                controller.activityGoal = data
            }
            
        }
    }
    
}

extension UIImage {
    func resizeTo(newWidth: CGFloat, newHeight: CGFloat ) -> UIImage? {
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
