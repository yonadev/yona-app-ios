//
//  NotificationsViewController.swift
//  Yona
//
//  Created by Ben Smith on 19/05/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

class NotificationsViewController: UITableViewController, YonaUserSwipeCellDelegate {
    
    @IBOutlet weak var tableHeaderView: UIView!
    
    
    var selectedIndex : NSIndexPath?
    var buddyData : Buddies?
    
    
    var page : Int = 1
    var size : Int = 20
    
    //paging
    var totalSize: Int = 0
    var totalPages : Int = 0
    var aMessage: Message?
    
    //MARK: searchResultMovies hold the movie search results
    var messages = [[Message]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = false
        registreTableViewCells()
    }
    
    func registreTableViewCells () {
        var nib = UINib(nibName: "YonaUserTableViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "YonaUserTableViewCell")
        nib = UINib(nibName: "YonaDefaultTableHeaderView", bundle: nil)
        tableView.registerNib(nib, forHeaderFooterViewReuseIdentifier: "YonaDefaultTableHeaderView")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "NotificationsViewController")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
        
        self.navigationController?.navigationBar.backgroundColor = UIColor.yiGrapeColor()
        let navbar = navigationController?.navigationBar as! GradientNavBar
        navbar.gradientColor = UIColor.yiGrapeTwoColor()
        
        messages = []
        page = 1
        
        loadMessages()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.destinationViewController is YonaNotificationAcceptFriendRequestViewController {
            let controller = segue.destinationViewController as! YonaNotificationAcceptFriendRequestViewController
            controller.aMessage = self.aMessage
            controller.aBuddy = self.buddyData
            self.selectedIndex = nil
            self.tableView.reloadData()
        } else if segue.destinationViewController is MeWeekDetailWeekViewController {
            let controller = segue.destinationViewController as! MeWeekDetailWeekViewController
            controller.initialObjectLink = self.aMessage!.weekDetailsLink!
            
        } else if segue.destinationViewController is MeDayDetailViewController {
            let controller = segue.destinationViewController as! MeDayDetailViewController
            controller.initialObjectLink = self.aMessage!.dayDetailsLink!
        } else if segue.destinationViewController is NotificationDetailViewController {
            let controller = segue.destinationViewController as! NotificationDetailViewController
            controller.aMessage = self.aMessage
        }
        
    }
    
    //MARK: - tableview methods
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return messages.count
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if messages.count == 0 {
            return 0
        }
        return messages[section].count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedIndex = indexPath
        aMessage = messages[(selectedIndex?.section)!][(selectedIndex?.row)!] as Message
        
        if !(aMessage?.isRead)! {
            aMessage?.isRead = true
            messages[(selectedIndex?.section)!][(selectedIndex?.row)!] = aMessage!
            MessageRequestManager.sharedInstance.postReadMessage(aMessage! ,onCompletion:{(succes, serverMessage, serverCode) in
            })
            
        }
        //this gets the buddy that matches the link in hte message for daily activity reports, so we can pass VC the correct buddy data
        if let buddies = UserRequestManager.sharedInstance.newUser?.buddies {
            for each in buddies {
                if let dailyActivityLink = each.dailyActivityReports {
                    if dailyActivityLink == aMessage?.dayDetailsLink {
                        self.buddyData = each
                    }
                }
            }
        }
        
        if let aMessage = self.aMessage {
            switch aMessage.messageType {
            case .ActivityCommentMessage:
                if aMessage.dayDetailsLink != nil {
                    self.performSegueWithIdentifier(R.segue.notificationsViewController.showDayDetailMessage, sender: self)
                    return
                } else if aMessage.weekDetailsLink != nil {
                    self.performSegueWithIdentifier(R.segue.notificationsViewController.showWeekDetailMessage, sender: self)
                    return
                }
            case .BuddyConnectRequestMessage:
                if aMessage.status == buddyRequestStatus.REQUESTED {
                    self.performSegueWithIdentifier(R.segue.notificationsViewController.showAcceptFriend, sender: self)
                    return
                }
                if aMessage.status == buddyRequestStatus.ACCEPTED {
                    showBuddyProfile(aMessage)
                    return
                }
                
                
            case .BuddyDisconnectMessage:
                break
            case .BuddyConnectResponseMessage:
                break
            case .GoalConflictMessage:
                var selflink = "hg"
                var userid = ""
                if let aUserid = UserRequestManager.sharedInstance.newUser?.userID,
                    let aSelfLink = aMessage.selfLink
                {
                    userid = aUserid
                    selflink = aSelfLink
                }
                if selflink.rangeOfString(userid) != nil{
                    
                    let storyboard = UIStoryboard(name: "MeDashBoard", bundle: nil)
                    let vc = storyboard.instantiateViewControllerWithIdentifier("MeDayDetailViewController") as! MeDayDetailViewController
                    vc.goalType = GoalType.NoGoGoalString.rawValue
                    vc.currentDate = aMessage.creationTime
                    vc.initialObjectLink = aMessage.dayDetailsLink
                    
                    vc.violationStartTime = aMessage.violationStartTime
                    vc.violationEndTime = aMessage.violationEndTime
                    vc.violationLinkURL = aMessage.violationLinkURL
                    
                    self.navigationController?.pushViewController(vc, animated: true)
                    return
                    
                }  else {
                    
                    
                    let storyboard = UIStoryboard(name: "Friends", bundle: nil)
                    let vc = storyboard.instantiateViewControllerWithIdentifier("FriendsDayDetailViewController") as! FriendsDayDetailViewController
                    vc.buddy = self.buddyData
                    vc.goalType = GoalType.NoGoGoalString.rawValue
                    vc.currentDate = aMessage.creationTime
                    vc.initialObjectLink = aMessage.dayDetailsLink
                    
                    vc.navbarColor1 = self.navigationController?.navigationBar.backgroundColor
                    self.navigationController?.navigationBar.backgroundColor = UIColor.yiWindowsBlueColor()
                    let navbar = self.navigationController?.navigationBar as! GradientNavBar
                    
                    vc.navbarColor = navbar.gradientColor
                    navbar.gradientColor = UIColor.yiMidBlueColor()
                    
                    self.navigationController?.pushViewController(vc, animated: true)
                    return
                }
            case .GoalChangeMessage:
                break
                // DISABLED AS REQUEST in APPDEV-817
                //                let storyboard = UIStoryboard(name: "Friends", bundle: nil)
                //                let vc = storyboard.instantiateViewControllerWithIdentifier("FriendsDayViewController") as! FriendsDayViewController
                //                vc.buddyToShow = self.buddyData
                //
                //                vc.navbarColor1 = self.navigationController?.navigationBar.backgroundColor
                //                self.navigationController?.navigationBar.backgroundColor = UIColor.yiWindowsBlueColor()
                //                let navbar = self.navigationController?.navigationBar as! GradientNavBar
                //
                //                vc.navbarColor = navbar.gradientColor
                //                navbar.gradientColor = UIColor.yiMidBlueColor()
                //
                //                self.navigationController?.pushViewController(vc, animated: true)
                //                return
            //                break
            case .DisclosureResponseMessage:
                //not implemented yet
                break
            case .DisclosureRequestMessage:
                //not implemented yet
                break
            case .BuddyInfoChangeMessage:
                // not implemented yet
                break
            case .SystemMessage:
                // not implemented yet
                self.performSegueWithIdentifier(R.segue.notificationsViewController.notificationDetailSegue, sender: self)
                break
            case .NoValue:
                break
                
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        tableView.reloadData()
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: YonaUserTableViewCell = tableView.dequeueReusableCellWithIdentifier("YonaUserTableViewCell", forIndexPath: indexPath) as! YonaUserTableViewCell
        if messages.count == 0 { return cell }
        
        cell.resetCellState()

        cell.setMessage(messages[indexPath.section][indexPath.row])
        
        let currentMessage = messages[indexPath.section][indexPath.row] as Message
        //turn off/on delete messages by disabling the pan gesture on our custom delete cell
        //cannot swithc on a optional type so have
        switch currentMessage.messageType {
        case .ActivityCommentMessage:
            cell.isPanEnabled = false
        case .BuddyConnectRequestMessage,
             .BuddyDisconnectMessage,
             .BuddyConnectResponseMessage,
             .GoalConflictMessage,
             .GoalChangeMessage,
             .DisclosureResponseMessage,
             .DisclosureRequestMessage,
             .BuddyInfoChangeMessage,
             .SystemMessage,
             .NoValue:
            cell.isPanEnabled = true
        }
        
        cell.yonaUserSwipeDelegate = self
        
        if indexPath.section == self.messages.count - 1 {
            if indexPath.row == self.messages[indexPath.section].count - 1 {
                if page < self.totalPages {
                    page = page + 1
                    loadMessages()
                }
            }
        }
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell: YonaDefaultTableHeaderView = tableView.dequeueReusableHeaderFooterViewWithIdentifier("YonaDefaultTableHeaderView") as! YonaDefaultTableHeaderView
        let dateTodate = NSDate()
        let yesterDate = dateTodate.dateByAddingTimeInterval(-60*60*24)
        
        if messages[section].first!.creationTime.isSameDayAs(dateTodate) {
            cell.headerTextLabel.text = NSLocalizedString("today", comment: "")
        } else if messages[section].first!.creationTime.isSameDayAs(yesterDate) {
            cell.headerTextLabel.text =  NSLocalizedString("yesterday", comment: "")
        } else {
            cell.headerTextLabel.text =  messages[section].first!.creationTime.fullDayMonthDateString()
        }
        return cell
        
    }
    
    // MARK: - YonaUserCellDelegate
    func messageNeedToBeDeleted(cell: YonaUserTableViewCell, message: Message) {
        let aMessage = message as Message
        MessageRequestManager.sharedInstance.deleteMessage(aMessage, onCompletion: { (success, message, code) in
            if success {
                self.messages.removeAll()
                self.loadMessages()
            } else {
                self.displayAlertMessage(message!, alertDescription: "")
            }
        })
    }
    
    // MARK: - server methods
    func loadMessages() {
        Loader.Show()
        MessageRequestManager.sharedInstance.getMessages(size, page: page - 1, onCompletion: { [weak self]
            (success, message, code, text, theMessages) in
            if success {
                self?.totalPages = MessageRequestManager.sharedInstance.totalPages!
                self?.totalSize = MessageRequestManager.sharedInstance.totalSize!
                
                var allLoadedMessage : [[Message]] = []
                var oldMessages: [Message] = []
                if  ((self?.messages.count) > 0) {
                    for sectionArray in (self?.messages)! {
                        for mainArray in sectionArray {
                            oldMessages.append(mainArray)
                        }
                    }
                    self?.messages.removeAll()
                }
                var tmpArray: [Message] = []
                
                //success so sort by date... and create sub arrays
                if let data = theMessages   {
                    
                    if data.count > 0 {
                        let allMessages = oldMessages + data
                        let sortedArray  = allMessages.sort({ $0.creationTime.compare( $1.creationTime) == .OrderedDescending })
                        for aMessage in sortedArray {
                            MessageRequestManager.sharedInstance.postProcessLink(aMessage, onCompletion: { (success, message, code) in
                                if success {
                                    self?.loadMessages()
                                }
                                //so not every link will have one, so what now?
                                print(message)
                            })
                            if  aMessage.checkIfMessageTypeSupported() == true {
                                if tmpArray.count == 0 {
                                    tmpArray.append(aMessage)
                                } else if tmpArray[0].creationTime.isSameDayAs(aMessage.creationTime) {
                                    tmpArray.append(aMessage)
                                } else {
                                    allLoadedMessage.append(tmpArray)
                                    tmpArray.removeAll()
                                    tmpArray.append(aMessage)
                                }
                            }
                        }
                        if tmpArray.count > 0 {
                            allLoadedMessage.append(tmpArray)
                        }

                        allLoadedMessage.forEach{self?.messages.append($0)}
 
                        dispatch_async(dispatch_get_main_queue()) {
                            self?.tableView.reloadData()
                        }
                    } else {
                        self?.messages = []
                        dispatch_async(dispatch_get_main_queue()) {
                            self?.tableView.reloadData()
                        }
                    }
                } else {
                    self?.messages = []
                    dispatch_async(dispatch_get_main_queue()) {
                        self?.tableView.reloadData()
                    }
                }
                
            } else {
                //response from request failed
            }
            Loader.Hide()
            })
        
    }
    
    @IBAction func unwindToNotificationView(segue: UIStoryboardSegue) {
        print(segue.sourceViewController)
    }
    func showBuddyProfile(theMessage : Message) {
        
        UserRequestManager.sharedInstance.getUser(GetUserRequest.notAllowed, onCompletion: {(succes, serverMessage, serverCode, aUser) in
            var countPush = 0
            if succes {
                if let user = aUser {
                    for aBuddies in user.buddies {
                        if aBuddies.UserRequestSelfLink == theMessage.UserRequestSelfLink {
                            let storyBoard: UIStoryboard = UIStoryboard(name:"Friends", bundle: NSBundle.mainBundle())
                            let controller = storyBoard.instantiateViewControllerWithIdentifier("FriendsProfileViewController") as! FriendsProfileViewController
                            controller.aUser = aBuddies
                            //Make sure it only pushes once!
                            if countPush <= 0 {
                                self.navigationController?.pushViewController(controller, animated: true)
                            }
                            countPush += 1
                        }
                    }
                }
            }
        })
        
        
    }
    
    
}
