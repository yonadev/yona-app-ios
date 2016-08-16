//
//  NotificationsViewController.swift
//  Yona
//
//  Created by Ben Smith on 19/05/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

class NotificationsViewController: UITableViewController, YonaUserCellDelegate {
    
    @IBOutlet weak var tableHeaderView: UIView!
    var selectedIndex : NSIndexPath?
//    var buddyData : Buddies?

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
        
//        self.refreshControl = UIRefreshControl()
//        self.refreshControl!.attributedTitle = NSAttributedString(string: "Pull to refresh")
//        self.refreshControl!.addTarget(self, action: #selector(loadMessages(_:)), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func registreTableViewCells () {
        var nib = UINib(nibName: "YonaUserTableViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "YonaUserTableViewCell")
        nib = UINib(nibName: "YonaDefaultTableHeaderView", bundle: nil)
        tableView.registerNib(nib, forHeaderFooterViewReuseIdentifier: "YonaDefaultTableHeaderView")

    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
       loadMessages(self)
    }
    
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        return false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showAcceptFriend") {
            let aMessage = messages[(selectedIndex?.section)!][(selectedIndex?.row)!] as Message
            BuddyRequestManager.sharedInstance.getBuddy(aMessage.selfLink, onCompletion: { (success, message, code, buddy, buddies) in
                //success so get the user?
                if success {
                    //success so get the user
                    //                    self.buddyData = buddy
                    let controller = segue.destinationViewController as! YonaNotificationAcceptFriendRequestViewController
                    controller.aMessage = self.messages[(self.selectedIndex?.section)!][(self.selectedIndex?.row)!]
                    controller.aBuddy = buddy
                    self.selectedIndex = nil
                    self.tableView.reloadData()
                } else {
                    //response from request failed
                }
            })
        }
//        if segue.destinationViewController is YonaNotificationAcceptFriendRequestViewController {
//        }
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
        let aMessage = messages[(selectedIndex?.section)!][(selectedIndex?.row)!] as Message
        
        if aMessage.status == buddyRequestStatus.REQUESTED {
            performSegueWithIdentifier(R.segue.notificationsViewController.showAcceptFriend, sender: self)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: YonaUserTableViewCell = tableView.dequeueReusableCellWithIdentifier("YonaUserTableViewCell", forIndexPath: indexPath) as! YonaUserTableViewCell
        cell.setMessage(messages[indexPath.section][indexPath.row])
        cell.yonaUserDelegate = self
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
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            selectedIndex = indexPath
            let aMessage = messages[(selectedIndex?.section)!][(selectedIndex?.row)!] as Message
            MessageRequestManager.sharedInstance.deleteMessage(aMessage, onCompletion: { (success, message, code) in
                if success {
                    self.loadMessages(self)
                } else {
                    self.displayAlertMessage(message!, alertDescription: "")
                }
            })
        }
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        selectedIndex = indexPath

        let aMessage = messages[(selectedIndex?.section)!][(selectedIndex?.row)!] as Message
        //we can only delete a buddy request if it has been accepted or rejected
        if aMessage.status == buddyRequestStatus.ACCEPTED || aMessage.status == buddyRequestStatus.REJECTED {
            return true
        } else {
            return false
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
        MessageRequestManager.sharedInstance.getMessages(10, page: 0, onCompletion: {
        (success, message, code, text, theMessages) in
            if success {
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
//            self.refreshControl!.endRefreshing()
            Loader.Hide()
        })
        
     }

}