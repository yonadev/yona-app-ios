//
//  ProfileViewController.swift
//  Yona
//
//  Created by Chandan on 23/03/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

class UserDetails: FriendsProfileMasterView, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var theTableView: UITableView!
    @IBOutlet weak var rightSideButton : UIBarButtonItem!

    var topCell :ProfileDisplayTopTableViewCell?
    //
    
    var aUser : Users?
    var isShowingProfile = true
    var rightSideButtonItems : [UIBarButtonItem]?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = false
      //  profileTabAction(profileTabSelcetionView)
        dataLoading()
        setupUI()
        
    }

    func setupUI() {
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func dataLoading () {
        UserRequestManager.sharedInstance.getUser(GetUserRequest.notAllowed) { (success, message, code, user) in
            //success so get the user?
            if success {
                self.aUser = user
                //success so get the user
              //  self.setData()
                self.theTableView.reloadData()
            } else {
                //response from request failed
                
            }
        }

    
    }
    
    // MARK: - Actions

    @IBAction func profileTabAction(sender: AnyObject) {
        topCell?.showProfileTab()
        isShowingProfile = true
        if let itmes = rightSideButtonItems {
            self.navigationItem.rightBarButtonItems = itmes
        }
        theTableView.reloadData()
    }

    @IBAction func badgesTabAction(sender: AnyObject) {
        topCell?.showBadgesTab()
        isShowingProfile = false
        rightSideButtonItems = self.navigationItem.rightBarButtonItems
        self.navigationItem.rightBarButtonItems = nil
        theTableView.reloadData()
    }

    @IBAction func userDidSelectEdit(sender: AnyObject) {
        if theTableView.editing {
            rightSideButton.image = UIImage.init(named: "icnEdit")
            theTableView.setEditing(false, animated: true)
            topCell?.setTopViewInNormalMode()
            updateUser()
            
        } else {
            rightSideButton.image = UIImage.init(named: "icnCreate")
            theTableView.setEditing(true, animated: true)
            topCell?.setTopViewInEditMode()
            
        }
    }

    func userDidStartEdit() {
        rightSideButtonItems = self.navigationItem.rightBarButtonItems
        self.navigationItem.rightBarButtonItems = nil
        
    }
    
    func userDidEndEdit() {
        self.navigationItem.rightBarButtonItems = rightSideButtonItems
    }
    
    // MARK: - tableView methods
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        
        if isShowingProfile {
            return 4
        } else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if topCell == nil {
                topCell = (theTableView.dequeueReusableCellWithIdentifier("ProfileDisplayTopTableViewCell", forIndexPath: indexPath) as! ProfileDisplayTopTableViewCell)
            }
            if let theUser = aUser {
                topCell!.setData(userModel: theUser)
            }
            return topCell!

        }
        
        if isShowingProfile {
            let cell: ProfileDisplayTableViewCell = theTableView.dequeueReusableCellWithIdentifier("ProfileDisplayTableViewCell", forIndexPath: indexPath) as! ProfileDisplayTableViewCell
            cell.setData(delegate: self, cellType: ProfileCategoryHeader(rawValue: indexPath.row)!)
            return cell
        } else {
        // must be changed to show badges
            let cell: ProfileDisplayTableViewCell = theTableView.dequeueReusableCellWithIdentifier("ProfileDisplayTableViewCell", forIndexPath: indexPath) as! ProfileDisplayTableViewCell
            cell.setData(delegate: self, cellType: ProfileCategoryHeader(rawValue: indexPath.row)!)
            return cell

        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 221
        }
        return 87
    }
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.None
    }
    func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    
    // MARK: - server call
    
    func updateUser() {
        UserRequestManager.sharedInstance.updateUser((aUser?.userDataDictionaryForServer())!, onCompletion: {(success, message, code, user) in
            //success so get the user?
                if success {
                    self.aUser = user
                //success so get the user
                //  self.setData()
                    self.theTableView.reloadData()
                } else {
                //response from request failed
                }
            })
    }
    
}
