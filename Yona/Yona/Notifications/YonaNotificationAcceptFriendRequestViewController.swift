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
    
    override func viewWillAppear(_ animated: Bool) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "YonaNotificationAcceptFriendRequestViewController")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as! [AnyHashable: Any])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.backgroundColor = navbarColor1
        let navbar = navigationController?.navigationBar as! GradientNavBar
        navbar.gradientColor = navbarColor
        
    }
    
    func registreTableViewCells () {
        var nib = UINib(nibName: "YonaUserHeaderWithTwoTabTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "YonaUserHeaderWithTwoTabTableViewCell")
        nib = UINib(nibName: "YonaTwoButtonTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "YonaTwoButtonTableViewCell")
    
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    // MARK: - Actions
    @IBAction func backAction (_ sender : AnyObject) {
        weak var tracker = GAI.sharedInstance().defaultTracker
        tracker!.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action", action: "backAction", label: "YonaNotificationAcceptFriendRequestViewController", value: nil).build() as! [AnyHashable: Any])
        navigationController?.popViewController(animated: true)
        
    }
    
    // MARK: - tableview methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case acceptFriendRequest.profile.rawValue:

            let cell: YonaUserHeaderWithTwoTabTableViewCell = tableView.dequeueReusableCell(withIdentifier: "YonaUserHeaderWithTwoTabTableViewCell", for: indexPath) as! YonaUserHeaderWithTwoTabTableViewCell
            cell.setAcceptFriendsMode()
            if let aBuddy = aBuddy {
                cell.setBuddy(aBuddy)
            }
            if let msg = aMessage {
                cell.setMessage(msg)
            }
            return cell
        case acceptFriendRequest.buttons.rawValue:
            let cell: YonaTwoButtonTableViewCell = tableView.dequeueReusableCell(withIdentifier: "YonaTwoButtonTableViewCell", for: indexPath) as! YonaTwoButtonTableViewCell
            cell.delegate = self
            if let msg = aMessage {
                cell.setNumber(msg)
            }
            return cell
    
            
        default:
            return UITableViewCell(frame: CGRect.zero)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
    
    func didSelectLeftButton(_ button: UIButton) {
    
        view.isUserInteractionEnabled = false
        Loader.Show()
        if let mes = aMessage {
            MessageRequestManager.sharedInstance.postRejectMessage(mes, onCompletion: { (success, message, code) in
                Loader.Hide()
                if success {
                    // TODO:  add the reject server method
                    self.view.isUserInteractionEnabled = true
                    self.navigationController?.popViewController(animated: true)
                }
            })
        }


        
    }
    func didSelectRightButton(_ button: UIButton) {
        view.isUserInteractionEnabled = false
        Loader.Show()
        if let mes = aMessage {
            MessageRequestManager.sharedInstance.postAcceptMessage(mes, onCompletion:  {success, json, error in
                Loader.Hide()
                if success {
                    self.view.isUserInteractionEnabled = true
                    self.navigationController?.popViewController(animated: true)
                }
            })
        }

    }
}

