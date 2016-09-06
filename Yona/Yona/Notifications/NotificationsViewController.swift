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
    var messages = [[Message]]() {
        didSet{
            //everytime savedarticles is added to or deleted from table is refreshed
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
        }
    }
    
    
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
        nib = UINib(nibName: "CustomDeleteCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "CustomDeleteCell")
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
       loadMessages(self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.destinationViewController is YonaNotificationAcceptFriendRequestViewController {
            let controller = segue.destinationViewController as! YonaNotificationAcceptFriendRequestViewController
            controller.aMessage = self.aMessage //self.messages[(self.selectedIndex?.section)!][(self.selectedIndex?.row)!]
            controller.aBuddy = self.buddyData
            self.selectedIndex = nil
            self.tableView.reloadData()
        }
        
        if segue.destinationViewController is MeWeekDetailWeekViewController {
            let controller = segue.destinationViewController as! MeWeekDetailWeekViewController
            controller.initialObjectLink = self.aMessage!.weekDetailsLink!

        }
        
        if segue.destinationViewController is MeDayDetailViewController {
            let controller = segue.destinationViewController as! MeDayDetailViewController
            controller.initialObjectLink = self.aMessage!.dayDetailsLink!
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
//        Loader.Show()
        BuddyRequestManager.sharedInstance.getBuddy(aMessage!.selfLink, onCompletion: { (success, message, code, buddy, buddies) in
            //success so get the user?
            if success {
//                Loader.Hide()
                self.buddyData = buddy
                if let aMessage = self.aMessage {
                    switch aMessage.messageType {
                    case .ActivityCommentMessage:
//                        if aMessage.dayDetailsLink != nil {
//                            self.performSegueWithIdentifier(R.segue.notificationsViewController.showDayDetailMessage, sender: self)
//                        } else if aMessage.weekDetailsLink != nil {
//                            self.performSegueWithIdentifier(R.segue.notificationsViewController.showWeekDetailMessage, sender: self)
//                        }
                        break
                    case .BuddyConnectRequestMessage:
                        if aMessage.status == buddyRequestStatus.REQUESTED {
//                            self.performSegueWithIdentifier(R.segue.notificationsViewController.showAcceptFriend, sender: self)
                        }
                    case .BuddyDisconnectMessage:
                        break
                    case .BuddyConnectResponseMessage:
                        break
                    case .GoalConflictMessage:
                        break
                    case .GoalChangeMessage:
//                        self.performSegueWithIdentifier(R.segue.notificationsViewController.showFriendDayView, sender: self)
                        break
                    case .DisclosureResponseMessage:
                        //not implemented yet
                        break
                    case .DisclosureRequestMessage:
                        //not implemented yet
                        break
                    case .NoValue:
                        break
                        
                    }
                }
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
            } else {
                //response from request failed
//                Loader.Hide()
            }
        })

        if let aMessage = self.aMessage {
            switch aMessage.messageType {
            case .ActivityCommentMessage:
                if aMessage.dayDetailsLink != nil {
                    self.performSegueWithIdentifier(R.segue.notificationsViewController.showDayDetailMessage, sender: self)
                } else if aMessage.weekDetailsLink != nil {
                    self.performSegueWithIdentifier(R.segue.notificationsViewController.showWeekDetailMessage, sender: self)
                }
            case .BuddyConnectRequestMessage:
                if aMessage.status == buddyRequestStatus.REQUESTED {
                    self.performSegueWithIdentifier(R.segue.notificationsViewController.showAcceptFriend, sender: self)
                }
            case .BuddyDisconnectMessage:
                break
            case .BuddyConnectResponseMessage:
                break
            case .GoalConflictMessage:
                let storyboard = UIStoryboard(name: "Friends", bundle: nil)
                let vc = storyboard.instantiateViewControllerWithIdentifier("FriendsDayDetailViewController") as! FriendsDayDetailViewController
                vc.buddy = self.buddyData
                vc.goalType = GoalType.NoGoGoalString.rawValue
                vc.currentDate = aMessage.creationTime
                vc.initialObjectLink = aMessage.dayDetailsLink
                
                vc.navbarColor1 = self.navigationController?.navigationBar.backgroundColor
                self.navigationController?.navigationBar.backgroundColor = UIColor.yiWindowsBlueColor()
                let navbar = navigationController?.navigationBar as! GradientNavBar
                
                vc.navbarColor = navbar.gradientColor
                navbar.gradientColor = UIColor.yiMidBlueColor()
                
                self.navigationController?.pushViewController(vc, animated: true)
                break
            case .GoalChangeMessage:
                let storyboard = UIStoryboard(name: "Friends", bundle: nil)
                let vc = storyboard.instantiateViewControllerWithIdentifier("FriendsDayViewController") as! FriendsDayViewController
                vc.buddyToShow = self.buddyData
                
                vc.navbarColor1 = self.navigationController?.navigationBar.backgroundColor
                self.navigationController?.navigationBar.backgroundColor = UIColor.yiWindowsBlueColor()
                let navbar = navigationController?.navigationBar as! GradientNavBar
                
                vc.navbarColor = navbar.gradientColor
                navbar.gradientColor = UIColor.yiMidBlueColor()
                
                self.navigationController?.pushViewController(vc, animated: true)
                break
            case .DisclosureResponseMessage:
                //not implemented yet
                break
            case .DisclosureRequestMessage:
                //not implemented yet
                break
            case .NoValue:
                break
                
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: YonaUserTableViewCell = tableView.dequeueReusableCellWithIdentifier("YonaUserTableViewCell", forIndexPath: indexPath) as! YonaUserTableViewCell
        cell.setMessage(messages[indexPath.section][indexPath.row])
        
        let currentMessage = messages[indexPath.section][indexPath.row] as Message
        //turn off/on delete messages by disabling the pan gesture on our custom delete cell
        //cannot swithc on a optional type so have
        switch currentMessage.messageType {
        case .ActivityCommentMessage:
            cell.allowsSwipeAction = false
        case .BuddyConnectRequestMessage:
            cell.allowsSwipeAction = true
        case .BuddyDisconnectMessage:
            cell.allowsSwipeAction = true
        case .BuddyConnectResponseMessage:
            cell.allowsSwipeAction = true
        case .GoalConflictMessage:
            cell.allowsSwipeAction = true
        case .GoalChangeMessage:
            cell.allowsSwipeAction = true
        case .DisclosureResponseMessage:
            cell.allowsSwipeAction = true
        case .DisclosureRequestMessage:
            cell.allowsSwipeAction = true
        case .NoValue:
            cell.allowsSwipeAction = true
        }

        cell.yonaUserSwipeDelegate = self
        return cell
    }

    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell: YonaDefaultTableHeaderView = tableView.dequeueReusableHeaderFooterViewWithIdentifier("YonaDefaultTableHeaderView") as! YonaDefaultTableHeaderView
        let dateTodate = NSDate()
        let yesterDate = dateTodate.dateByAddingTimeInterval(-60*60*24)
        let dateFormatter : NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "eeee, d MMMM, YYYY "
        
        if messages[section].first!.creationTime.isSameDayAs(dateTodate) {
            cell.headerTextLabel.text = NSLocalizedString("Today", comment: "")
        } else if messages[section].first!.creationTime.isSameDayAs(yesterDate) {
            cell.headerTextLabel.text =  NSLocalizedString("Yesterday", comment: "")
        } else {
            cell.headerTextLabel.text =  dateFormatter.stringFromDate(messages[section].first!.creationTime)
        }
        return cell
        
    }
    
//    // Override to support editing the table view.
//    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//        if editingStyle == .Delete {
//            selectedIndex = indexPath
//            let aMessage = messages[(selectedIndex?.section)!][(selectedIndex?.row)!] as Message
//            MessageRequestManager.sharedInstance.deleteMessage(aMessage, onCompletion: { (success, message, code) in
//                if success {
//                    self.loadMessages(self)
//                } else {
//                    self.displayAlertMessage(message!, alertDescription: "")
//                }
//            })
//        }
//    }
//    
//    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//        selectedIndex = indexPath
//
//        let aMessage = messages[(selectedIndex?.section)!][(selectedIndex?.row)!] as Message
//        //we can only delete a buddy request if it has been accepted or rejected
//        if aMessage.status == buddyRequestStatus.ACCEPTED || aMessage.status == buddyRequestStatus.REJECTED {
//            return true
//        } else {
//            return false
//        }
//
//    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if messages[indexPath.section].count > 0{
            print(indexPath.row)
            print(indexPath.section)
            print(messages[indexPath.section].count)

            if indexPath.row == page * size - 1 && page < self.totalPages {
                page = page + 1
                self.loadMessages(self)

//                    if let commentsLink = self.dayData?.messageLink {
//                        Loader.Show()
//                        CommentRequestManager.sharedInstance.getComments(commentsLink, size: size, page: page) { (success, comment, comments, serverMessage, serverCode) in
//                            Loader.Hide()
//                            if success {
//                                if let comments = comments {
//                                    for comment in comments {
//                                        self.comments.append(comment)
//                                    }
//                                }
//                            }
//                        }
//                    }
            }
        }
    }
    
    // MARK: - YonaUserCellDelegate
    func messageNeedToBeDeleted(cell: YonaUserTableViewCell, message: Message) {
        let aMessage = message as Message
        MessageRequestManager.sharedInstance.deleteMessage(aMessage, onCompletion: { (success, message, code) in
            if success {
                self.loadMessages(self)
            } else {
                self.displayAlertMessage(message!, alertDescription: "")
            }
        })
    }
    
    // MARK: - server methods
    func loadMessages(sender:AnyObject) {
        Loader.Show()
        MessageRequestManager.sharedInstance.getMessages(size, page: page - 1, onCompletion: {
        (success, message, code, text, theMessages) in
            if success {
                self.totalPages = MessageRequestManager.sharedInstance.totalPages!
                self.totalSize = MessageRequestManager.sharedInstance.totalSize!

                var allLoadedMessage : [[Message]] = []
                var tmpArray: [Message] = []
                //success so sort by date... and create sub arrays
                if let data = theMessages   {
                    
                    if data.count > 0 {
                        let sortedArray  = data.sort({ $0.creationTime.compare( $1.creationTime) == .OrderedDescending })
                        for aMessage in sortedArray {
                            MessageRequestManager.sharedInstance.postProcessLink(aMessage, onCompletion: { (success, message, code) in
                                if success {
                                    self.loadMessages(self)
                                }
                                //so not every link will have one, so what now?
                                print(message)
                            })
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
                        allLoadedMessage.append(tmpArray)
                        self.messages = allLoadedMessage
                    } else {
                        self.messages = []
                    }
                } else {
                    self.messages = []
                }
                
            } else {
                //response from request failed
            }
            Loader.Hide()
        })
        
     }

}