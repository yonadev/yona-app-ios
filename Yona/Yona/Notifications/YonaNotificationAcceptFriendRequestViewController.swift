//
//  YonaNotificationAcceptFriendRequestViewController.swift
//  Yona
//
//  Created by Anders Liebl on 19/06/2016.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation
import UIKit

enum acceptFriendRequest : Int {
    case profile
    case type
    case message
    case number
    case buttons
}

class YonaNotificationAcceptFriendRequestViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var aMessage : Message?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("notifications.accept.title", comment: "") 
        registreTableViewCells()
    }
    
    func registreTableViewCells () {
        let nib = UINib(nibName: "YonaUserHeaderWithTwoTabTableViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "YonaUserHeaderWithTwoTabTableViewCell")
    
    
    }

    
// MARK: - Actions
    @IBAction func backAction (sender : AnyObject) {
        navigationController?.popViewControllerAnimated(true)
        
    }
    
    //MARK: - tableview methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4 // must be 5
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        return
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case acceptFriendRequest.profile.rawValue:

            let cell: YonaUserHeaderWithTwoTabTableViewCell = tableView.dequeueReusableCellWithIdentifier("YonaUserHeaderWithTwoTabTableViewCell", forIndexPath: indexPath) as! YonaUserHeaderWithTwoTabTableViewCell
            cell.setAcceptFriendsMode()
            if let msg = aMessage {
                cell.setMessage(msg)
            }
            return cell
        
        
        case acceptFriendRequest.type.rawValue:
            let cell: YonaNotificationsAccessTypeTableViewCell = tableView.dequeueReusableCellWithIdentifier("YonaNotificationsAccessTypeTableViewCell", forIndexPath: indexPath) as! YonaNotificationsAccessTypeTableViewCell
            cell.typeTextLable.text = NSLocalizedString("notifications.accept.type", comment: "")
            return cell
        
        case acceptFriendRequest.message.rawValue:
            let cell: YonaNotificationsAccessTextTableViewCell = tableView.dequeueReusableCellWithIdentifier("YonaNotificationsAccessTextTableViewCell", forIndexPath: indexPath) as! YonaNotificationsAccessTextTableViewCell
            if let msg = aMessage {
                cell.aTextLabel.text = msg.message
            }
            return cell
        case acceptFriendRequest.number.rawValue:
            let cell: YonaNotificationsAccessTextTableViewCell = tableView.dequeueReusableCellWithIdentifier("YonaNotificationsAccessTextTableViewCell", forIndexPath: indexPath) as! YonaNotificationsAccessTextTableViewCell
            if let msg = aMessage {
                let num = msg.UserRequestmobileNumber
                let text = String(format:  NSLocalizedString("notifications.accept.number", comment: ""), num)
            cell.aTextLabel.text = text
            }

            return cell
        
            
            
        default:
            return UITableViewCell(frame: CGRectZero)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.row {
        case acceptFriendRequest.profile.rawValue:
            return 221
        default:
            return 44
        }
    }
    
    // MARK : Utility methods
    
    func calculateHeightForCell(aText: String) -> CGFloat{
    
        return 100
    }
    
}