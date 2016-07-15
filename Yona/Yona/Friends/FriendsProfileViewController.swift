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

class FriendsProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, YonaUserHeaderTabProtocol, YonaButtonTableViewCellProtocol {
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var topCell : YonaUserHeaderWithTwoTabTableViewCell?
    
    var aUser : Buddies?
    var isShowingProfile = true
    var rightSideButtonItems : [UIBarButtonItem]?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = false
        registreTableViewCells()
        dataLoading()
    }
    
    func registreTableViewCells () {
        var nib = UINib(nibName: "YonaUserDisplayTableViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "YonaUserDisplayTableViewCell")
        nib = UINib(nibName: "YonaUserHeaderWithTwoTabTableViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "YonaUserHeaderWithTwoTabTableViewCell")

        nib = UINib(nibName: "YonaButtonTableViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "YonaButtonTableViewCell")
}
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func dataLoading () {
        self.tableView.reloadData()
        
        
    }
    
    // MARK: - Actions
    
    func didSelectProfileTab() {
        isShowingProfile = true
        tableView.reloadData()
    }
    
    func didSelectBadgesTab() {
        isShowingProfile = false
        tableView.reloadData()
    }
    
    
    // MARK: - tableView methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
            return 3
        } else {
            return 0
        }

    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == FriendsProfileTableViewOrder.header.rawValue {
            if topCell == nil {
                topCell = (tableView.dequeueReusableCellWithIdentifier("YonaUserHeaderWithTwoTabTableViewCell", forIndexPath: indexPath) as! YonaUserHeaderWithTwoTabTableViewCell)
                topCell?.delegate = self
            }
            if let theBuddie = aUser {
                topCell!.setBuddy(theBuddie)
            }
            return topCell!
            
        }
        
        if indexPath.section == FriendsProfileTableViewOrder.button.rawValue {
        
            let cell: YonaButtonTableViewCell = tableView.dequeueReusableCellWithIdentifier("YonaButtonTableViewCell", forIndexPath: indexPath) as! YonaButtonTableViewCell
            cell.delegate = self
            return cell
          
            
        }
        if isShowingProfile {
            let cell: YonaUserDisplayTableViewCell = tableView.dequeueReusableCellWithIdentifier("YonaUserDisplayTableViewCell", forIndexPath: indexPath) as! YonaUserDisplayTableViewCell
                cell.setBuddyData(delegate: self, cellType: FriendsProfileCategoryHeader(rawValue: indexPath.row)!)
            return cell
        } else {
            // must be changed to show badges
            let cell: YonaUserDisplayTableViewCell = tableView.dequeueReusableCellWithIdentifier("YonaUserDisplayTableViewCell", forIndexPath: indexPath) as! YonaUserDisplayTableViewCell
//            cell.setData(delegate: self, cellType: ProfileCategoryHeader(rawValue: indexPath.row)!)
            return cell
            
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == FriendsProfileTableViewOrder.header.rawValue {
            return 221
        }
        if indexPath.section == FriendsProfileTableViewOrder.button.rawValue {
            return 60
        }
        return 87
    }
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.None
    }
    func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    
 
    
    func didSelectButton(button: UIButton) {
        Loader.Show()
        BuddyRequestManager.sharedInstance.deleteBuddy(aUser, onCompletion: {(succes, ServerMessage, ServerCode, theBuddy, buddies) in
            
            Loader.Hide()
            self.navigationController?.popToRootViewControllerAnimated(true)
            
        })
    
    }
}