//
//  FriendsProfileViewController.swift
//  Yona
//
//  Created by Anders Liebl on 07/07/2016.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation
import UIKit

enum FriendsProfileTableViewOrder : Int{
    case header = 0
    case text
    case button
}

class FriendsProfileViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var topCell : YonaUserHeaderWithTwoTabTableViewCell?
    var navbarColor1 : UIColor?
    var navbarColor : UIColor?

    var aUser : Buddies?
    var isShowingProfile = true
    var rightSideButtonItems : [UIBarButtonItem]?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        
        registreTableViewCells()
        dataLoading()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tableView.backgroundColor = UIColor.yiGraphBarOneColor()
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "FriendsProfileViewController")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as? [AnyHashable: Any])
        
        navbarColor1 = self.navigationController?.navigationBar.backgroundColor
        self.navigationController?.navigationBar.backgroundColor = UIColor.yiWindowsBlueColor()
        let navbar = navigationController?.navigationBar as! GradientNavBar
        
        navbarColor = navbar.gradientColor
        navbar.gradientColor = UIColor.yiMidBlueColor()
        
    }
    
    func registreTableViewCells () {
        var nib = UINib(nibName: "YonaUserDisplayTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "YonaUserDisplayTableViewCell")
        nib = UINib(nibName: "YonaUserHeaderWithTwoTabTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "YonaUserHeaderWithTwoTabTableViewCell")

        nib = UINib(nibName: "YonaButtonTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "YonaButtonTableViewCell")
}
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.navigationBar.backgroundColor = navbarColor1
        if let navbar = navigationController?.navigationBar as? GradientNavBar {
            navbar.gradientColor = UIColor.yiMidBlueColor()
        }
        
    }
    
    func dataLoading () {
        self.tableView.reloadData()
    }
    
    // MARK: - Actions
    @IBAction func backAction(_ sender : AnyObject) {
        weak var tracker = GAI.sharedInstance().defaultTracker
        tracker!.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action", action: "backActionFriendsProfileView", label: "Back from friends profile view page", value: nil).build() as? [AnyHashable: Any])
        
        DispatchQueue.main.async(execute: {
            self.navigationController?.popViewController(animated: true)
        })
    }
}

    // MARK: - UITableViewDelegate and UITableViewDataSource methods
extension FriendsProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == FriendsProfileTableViewOrder.header.rawValue {
            return 1
        }
        if section == FriendsProfileTableViewOrder.button.rawValue {
            if isShowingProfile {
                return 1
            } else {
                return 0
            }
        }
        if isShowingProfile {
            return 4
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == FriendsProfileTableViewOrder.header.rawValue {
            if topCell == nil {
                topCell = (tableView.dequeueReusableCell(withIdentifier: "YonaUserHeaderWithTwoTabTableViewCell", for: indexPath) as! YonaUserHeaderWithTwoTabTableViewCell)
                topCell?.delegate = self
            }
            if let theBuddie = aUser {
                topCell!.setBuddy(theBuddie)
            }
            return topCell!
            
        }
        
        if indexPath.section == FriendsProfileTableViewOrder.button.rawValue {
            
            let cell: YonaButtonTableViewCell = tableView.dequeueReusableCell(withIdentifier: "YonaButtonTableViewCell", for: indexPath) as! YonaButtonTableViewCell
            cell.delegate = self
            cell.backgroundColor = UIColor.yiGraphBarOneColor()
            return cell
            
            
        }
        if isShowingProfile {
            let cell: YonaUserDisplayTableViewCell = tableView.dequeueReusableCell(withIdentifier: "YonaUserDisplayTableViewCell", for: indexPath) as! YonaUserDisplayTableViewCell
            cell.setBuddyData(delegate: self, cellType: FriendsProfileCategoryHeader(rawValue: indexPath.row)!)
            return cell
        } else {
            // must be changed to show badges
            let cell: YonaUserDisplayTableViewCell = tableView.dequeueReusableCell(withIdentifier: "YonaUserDisplayTableViewCell", for: indexPath) as! YonaUserDisplayTableViewCell
            //            cell.setData(delegate: self, cellType: ProfileCategoryHeader(rawValue: indexPath.row)!)
            return cell
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == FriendsProfileTableViewOrder.header.rawValue {
            return 221
        }
        if indexPath.section == FriendsProfileTableViewOrder.button.rawValue {
            return 60
        }
        return 87
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.none
    }
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
//MARK: YonaButtonTableViewCellProtocol
extension FriendsProfileViewController: YonaButtonTableViewCellProtocol{
    func didSelectButton(_ button: UIButton) {
        Loader.Show()
        BuddyRequestManager.sharedInstance.deleteBuddy(aUser, onCompletion: {(succes, ServerMessage, ServerCode, theBuddy, buddies) in
            
            Loader.Hide()
            self.navigationController?.popToRootViewController(animated: true)
            UserRequestManager.sharedInstance.getUser(GetUserRequest.allowed, onCompletion: {(succes, uerverMessage, serverCode, users) in
                print("user refreshed afer delete \(succes)")
            })
        })
    }
}

//MARK: YonaUserHeaderTabProtocol
extension FriendsProfileViewController: YonaUserHeaderTabProtocol {
    func didAskToAddProfileImage() {
    }
    
    func didSelectProfileTab() {
        isShowingProfile = true
        tableView.reloadData()
    }
    
    func didSelectBadgesTab() {
        isShowingProfile = false
        tableView.reloadData()
    }
}
