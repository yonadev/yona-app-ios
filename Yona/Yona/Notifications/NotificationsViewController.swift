//
//  NotificationsViewController.swift
//  Yona
//
//  Created by Ben Smith on 19/05/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}

class NotificationsViewController: UITableViewController, YonaUserSwipeCellDelegate {
    
    @IBOutlet weak var tableHeaderView: UIView!
    
    var selectedIndex : IndexPath?
    var buddyData : Buddies?
    var page : Int = 1
    var size : Int = 20
    
    //paging
    var totalSize: Int = 0
    var totalPages : Int = 0
    var aMessage: Message?
    
    //MARK: searchResultMovies hold the movie search results
    var messages = [[Message]]()
    
    //MARK: view life cycle 
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        registerTableViewCells()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "NotificationsViewController")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as! [AnyHashable: Any])
        self.navigationController?.navigationBar.backgroundColor = UIColor.yiGrapeColor()
        let navbar = navigationController?.navigationBar as! GradientNavBar
        navbar.gradientColor = UIColor.yiGrapeTwoColor()
        messages = []
        page = 1
        loadMessages()
    }
    
    func registerTableViewCells () {
        var nib = UINib(nibName: "YonaUserTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "YonaUserTableViewCell")
        nib = UINib(nibName: "YonaDefaultTableHeaderView", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "YonaDefaultTableHeaderView")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is YonaNotificationAcceptFriendRequestViewController {
            let controller = segue.destination as! YonaNotificationAcceptFriendRequestViewController
            controller.aMessage = self.aMessage
            controller.aBuddy = self.buddyData
            self.selectedIndex = nil
            self.tableView.reloadData()
        } else if segue.destination is MeWeekDetailWeekViewController {
            let controller = segue.destination as! MeWeekDetailWeekViewController
            controller.initialObjectLink = self.aMessage!.weekDetailsLink!
            
        } else if segue.destination is MeDayDetailViewController {
            let controller = segue.destination as! MeDayDetailViewController
            controller.initialObjectLink = self.aMessage!.dayDetailsLink!
        } else if segue.destination is NotificationDetailViewController {
            let controller = segue.destination as! NotificationDetailViewController
            controller.aMessage = self.aMessage
        }
    }
    
    //MARK: - tableview methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if messages.count == 0 {
            return 0
        }
        return messages[section].count
    }
    
    fileprivate func handleActivityCommentMessage(_ aMessage: Message) {
        if aMessage.dayDetailsLink != nil {
            self.performSegue(withIdentifier: R.segue.notificationsViewController.showDayDetailMessage, sender: self)
            return
        } else if aMessage.weekDetailsLink != nil {
            self.performSegue(withIdentifier: R.segue.notificationsViewController.showWeekDetailMessage, sender: self)
            return
        }
    }
    
    fileprivate func handleBuddyConnectRequestMessage(_ aMessage: Message) {
        if aMessage.status == buddyRequestStatus.REQUESTED {
            self.performSegue(withIdentifier: R.segue.notificationsViewController.showAcceptFriend, sender: self)
            return
        }
        if aMessage.status == buddyRequestStatus.ACCEPTED {
            showBuddyProfile(aMessage)
            return
        }
    }
    
    fileprivate func navigateToMeDashBoard(_ aMessage: Message) {
        let storyboard = UIStoryboard(name: "MeDashBoard", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MeDayDetailViewController") as! MeDayDetailViewController
        vc.goalType = GoalType.NoGoGoalString.rawValue
        vc.currentDate = aMessage.creationTime
        vc.initialObjectLink = aMessage.dayDetailsLink
        vc.goalName = aMessage.activityTypeName
        vc.violationStartTime = aMessage.violationStartTime
        vc.violationEndTime = aMessage.violationEndTime
        vc.violationLinkURL = aMessage.violationLinkURL
        self.navigationController?.pushViewController(vc, animated: true)
        return
    }
    
    fileprivate func navigateToFriendsDayDetailView(_ aMessage: Message) {
        let storyboard = UIStoryboard(name: "Friends", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "FriendsDayDetailViewController") as! FriendsDayDetailViewController
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
    
    fileprivate func handleGoalConflictMessage(_ aMessage: Message) {
        var selflink = "hg"
        var userid = ""
        if let aUserid = UserRequestManager.sharedInstance.newUser?.userID, let aSelfLink = aMessage.selfLink {
            userid = aUserid
            selflink = aSelfLink
        }
        if selflink.range(of: userid) != nil{
            return navigateToMeDashBoard(aMessage)
        }  else {
            return navigateToFriendsDayDetailView(aMessage)
        }
    }
    
    fileprivate func postUserReadMessageToServer() {
        if !(aMessage?.isRead)! {
            aMessage?.isRead = true
            messages[(selectedIndex?.section)!][(selectedIndex?.row)!] = aMessage!
            MessageRequestManager.sharedInstance.postReadMessage(aMessage! ,onCompletion:{(succes, serverMessage, serverCode) in
            })
        }
    }
    
    fileprivate func retriveBuddyDataFromDailyActivityLink() {
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
    }
    
    fileprivate func navigateToVCBasedOnMessageType() {
        if let aMessage = self.aMessage {
            switch aMessage.messageType {
            case .ActivityCommentMessage:
                handleActivityCommentMessage(aMessage)
            case .BuddyConnectRequestMessage:
                handleBuddyConnectRequestMessage(aMessage)
            case .BuddyDisconnectMessage:
                break
            case .BuddyConnectResponseMessage:
                break
            case .GoalConflictMessage:
                handleGoalConflictMessage(aMessage)
            case .GoalChangeMessage:
                break
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
                self.performSegue(withIdentifier: R.segue.notificationsViewController.notificationDetailSegue, sender: self)
                break
            case .NoValue:
                break
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath
        aMessage = messages[(selectedIndex?.section)!][(selectedIndex?.row)!] as Message
        postUserReadMessageToServer()
        retriveBuddyDataFromDailyActivityLink()
        navigateToVCBasedOnMessageType()
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: YonaUserTableViewCell = tableView.dequeueReusableCell(withIdentifier: "YonaUserTableViewCell", for: indexPath) as! YonaUserTableViewCell
        if messages.count == 0 {
            return cell
        }
        cell.resetCellState()
        cell.setMessage(messages[indexPath.section][indexPath.row])
        let currentMessage = messages[indexPath.section][indexPath.row] as Message
        switch currentMessage.messageType {
        case .ActivityCommentMessage:
            cell.isPanEnabled = false
        case .BuddyConnectRequestMessage, .BuddyDisconnectMessage, .BuddyConnectResponseMessage, .GoalConflictMessage, .GoalChangeMessage, .DisclosureResponseMessage, .DisclosureRequestMessage,.BuddyInfoChangeMessage, .SystemMessage, .NoValue:
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
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell: YonaDefaultTableHeaderView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "YonaDefaultTableHeaderView") as! YonaDefaultTableHeaderView
        let dateTodate = Date()
        let yesterDate = dateTodate.addingTimeInterval(-60*60*24)
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
    func messageNeedToBeDeleted(_ cell: YonaUserTableViewCell, message: Message) {
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
    
    fileprivate func getOldMessages(_ oldMessages: inout [Message]) {
        if  ((self.messages.count) > 0) {
            for sectionArray in (self.messages) {
                for mainArray in sectionArray {
                    oldMessages.append(mainArray)
                }
            }
            self.messages.removeAll()
        }
    }
    
    fileprivate func checkForMessageTypeSupported(_ aMessage: Message, _ tmpArray: inout [Message], _ allLoadedMessage: inout [Array<Message>]) {
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
    
    fileprivate func sortMessagesByDate(_ data: [Message], _ oldMessages: [Message], _ tmpArray: inout [Message], _ allLoadedMessage: inout [Array<Message>]) {
        if data.count > 0 {
            let allMessages = oldMessages + data
            let sortedArray  = allMessages.sorted(by: { $0.creationTime.compare( $1.creationTime) == .orderedDescending })
            for aMessage in sortedArray {
                MessageRequestManager.sharedInstance.postProcessLink(aMessage, onCompletion: { (success, message, code) in
                    if success {
                        self.loadMessages()
                    }
                })
                checkForMessageTypeSupported(aMessage, &tmpArray, &allLoadedMessage)
            }
            if tmpArray.count > 0 {
                allLoadedMessage.append(tmpArray)
            }
            allLoadedMessage.forEach{self.messages.append($0)}
        } else {
            self.messages = []
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
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
                self?.getOldMessages(&oldMessages)
                var tmpArray: [Message] = []
                //success so sort by date... and create sub arrays
                if let data = theMessages   {
                    self?.sortMessagesByDate(data, oldMessages, &tmpArray, &allLoadedMessage)
                } else {
                    self?.messages = []
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                }
            }
            Loader.Hide()
        })
    }
    
    @IBAction func unwindToNotificationView(_ segue: UIStoryboardSegue) {
        print(segue.source)
    }
    
    func showBuddyProfile(_ theMessage : Message) {
        UserRequestManager.sharedInstance.getUser(GetUserRequest.notAllowed, onCompletion: {(succes, serverMessage, serverCode, aUser) in
            var countPush = 0
            if succes {
                if let user = aUser {
                    for aBuddies in user.buddies {
                        if aBuddies.UserRequestSelfLink == theMessage.UserRequestSelfLink {
                            let storyBoard: UIStoryboard = UIStoryboard(name:"Friends", bundle: Bundle.main)
                            let controller = storyBoard.instantiateViewController(withIdentifier: "FriendsProfileViewController") as! FriendsProfileViewController
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
