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
    case buttons
}

class YonaNotificationAcceptFriendRequestViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, YonaTwoButtonTableViewCellProtocol {
    
    @IBOutlet weak var tableView: UITableView!
    
    var aMessage : Message?
    var aBuddy : Buddies?
    var navbarColor1 : UIColor?
    var navbarColor : UIColor?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = NSLocalizedString("notifications.accept.title", comment: "")
        registreTableViewCells()
        
        navbarColor1 = self.navigationController?.navigationBar.backgroundColor
        self.navigationController?.navigationBar.backgroundColor = UIColor.yiWindowsBlueColor()
        let navbar = navigationController?.navigationBar as! GradientNavBar
        
        navbarColor = navbar.gradientColor
        navbar.gradientColor = UIColor.yiMidBlueColor()
        
        self.title = ""
        
        tableView.backgroundColor = UIColor.yiTableBGGreyColor()
    }
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.navigationBar.backgroundColor = navbarColor1
        let navbar = navigationController?.navigationBar as! GradientNavBar
        navbar.gradientColor = navbarColor
        
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
    
    // MARK: - tableview methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case acceptFriendRequest.profile.rawValue:

            let cell: YonaUserHeaderWithTwoTabTableViewCell = tableView.dequeueReusableCellWithIdentifier("YonaUserHeaderWithTwoTabTableViewCell", forIndexPath: indexPath) as! YonaUserHeaderWithTwoTabTableViewCell
            cell.setAcceptFriendsMode()
            if let aBuddy = aBuddy {
                cell.setBuddy(aBuddy)
            }
            if let msg = aMessage {
                cell.setMessage(msg)
            }
            return cell
        case acceptFriendRequest.buttons.rawValue:
            let cell: YonaTwoButtonTableViewCell = tableView.dequeueReusableCellWithIdentifier("YonaTwoButtonTableViewCell", forIndexPath: indexPath) as! YonaTwoButtonTableViewCell
            cell.delegate = self
            if let msg = aMessage {
                cell.setNumber(msg)
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
        case acceptFriendRequest.buttons.rawValue:
            return 227
        
        default:
            return 40
        }
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

