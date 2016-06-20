//
//  NotificationsViewController.swift
//  Yona
//
//  Created by Ben Smith on 19/05/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

class NotificationsViewController: UITableViewController {
    
    @IBOutlet weak var tableHeaderView: UIView!
    var selectedIndex : NSIndexPath?
    
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
        
        
    }

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loadMessages()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController is YonaNotificationAcceptFriendRequestViewController {
            let controller = segue.destinationViewController as! YonaNotificationAcceptFriendRequestViewController
            controller.aMessage = messages[(selectedIndex?.section)!][(selectedIndex?.row)!]
            selectedIndex = nil
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
        performSegueWithIdentifier(R.segue.notificationsViewController.showAcceptFriend, sender: self)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let cell: YonaUserTableViewCell = tableView.dequeueReusableCellWithIdentifier("YonaUserTableViewCell", forIndexPath: indexPath) as! YonaUserTableViewCell
        cell.setMessage(messages[indexPath.section][indexPath.row])
                
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
    
    // MARK: - server methods
    
    func loadMessages() {
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
                }
                
            } else {
                //response from request failed
            }
            Loader.Hide()
        })
        
     }

}