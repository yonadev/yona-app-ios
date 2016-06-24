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

class YonaNotificationAcceptFriendRequestViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, YonaTwoButtonTableViewCellProtocol {
    
    @IBOutlet weak var tableView: UITableView!
    
    var aMessage : Message?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("notifications.accept.title", comment: "") 
        registreTableViewCells()
    }
    
    func registreTableViewCells () {
        var nib = UINib(nibName: "YonaUserHeaderWithTwoTabTableViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "YonaUserHeaderWithTwoTabTableViewCell")
        nib = UINib(nibName: "YonaTwoButtonTableViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "YonaTwoButtonTableViewCell")
    
    
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
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
        return 5
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row {
        case acceptFriendRequest.number.rawValue:
            if let msg = aMessage {
                if let aURL = NSURL(string: "telprompt://\(msg.UserRequestmobileNumber)") {
                    UIApplication.sharedApplication().openURL(aURL)
                }
                
            }
           return
        default:
            return
        }
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
                cell.setMessageFromPoster( msg)
            }
            return cell
        case acceptFriendRequest.number.rawValue:
            let cell: YonaNotificationsAccessTextTableViewCell = tableView.dequeueReusableCellWithIdentifier("YonaNotificationsAccessTextTableViewCell", forIndexPath: indexPath) as! YonaNotificationsAccessTextTableViewCell
            if let msg = aMessage {
                cell.setPhoneNumber(msg)
            }

            return cell
        case acceptFriendRequest.buttons.rawValue:
            let cell: YonaTwoButtonTableViewCell = tableView.dequeueReusableCellWithIdentifier("YonaTwoButtonTableViewCell", forIndexPath: indexPath) as! YonaTwoButtonTableViewCell
            cell.delegate = self
            return cell
    
            
        default:
            return UITableViewCell(frame: CGRectZero)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.row {
        case acceptFriendRequest.profile.rawValue:
            return 221
        case acceptFriendRequest.message.rawValue:
            return calculateHeightForCell(acceptFriendRequest.message)
        case acceptFriendRequest.number.rawValue:
            return calculateHeightForCell(acceptFriendRequest.number)
        case acceptFriendRequest.buttons.rawValue:
            return 60
        
        default:
            return 40
        }
    }
    
    
    
    // MARK : Utility methods
    
    func calculateHeightForCell(row :acceptFriendRequest) -> CGFloat{
        var text = ""
        if let msg = aMessage {
            switch row {
            case acceptFriendRequest.message:
                let num = msg.UserRequestmobileNumber
                text = String(format:  NSLocalizedString("notifications.accept.number", comment: ""), num)
                
            case acceptFriendRequest.number:
                text = msg.message
            default:
                text = ""
            }
            let font = UIFont(name: "HelveticaNeue", size: 14)!
            let heigth = text.heightForWithFont(font, width: tableView.frame.size.width, insets: UIEdgeInsetsMake(10, 20, 10, 20))
            return heigth+15
        }
       

        return 10
    }
    
    // MARK - YonaTowButtonCellProtocol
    
    func didSelectLeftButton(button: UIButton) {
    
        view.userInteractionEnabled = false
        Loader.Show()
        if let mes = aMessage {
            MessageRequestManager.sharedInstance.postRejectMessage(mes, onCompletion: { (success, message, code) in
                Loader.Hide()
                if success {
                    // TODO:  add the reject server method
                    self.view.userInteractionEnabled = true
                    self.navigationController?.popViewControllerAnimated(true)
                }
            })
        }


        
    }
    func didSelectRightButton(button: UIButton) {
        view.userInteractionEnabled = false
        Loader.Show()
        if let mes = aMessage {
            MessageRequestManager.sharedInstance.postAcceptMessage(mes, onCompletion:  {success, json, error in
                Loader.Hide()
                if success {
                    self.view.userInteractionEnabled = true
                    self.navigationController?.popViewControllerAnimated(true)
                }
            })
        }

    }
}

