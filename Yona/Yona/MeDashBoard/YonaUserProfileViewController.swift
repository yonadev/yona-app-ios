//
//  ProfileViewController.swift
//  Yona
//
//  Created by Chandan on 23/03/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

class YonaUserProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, YonaUserHeaderTabProtocol {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var rightSideButton : UIBarButtonItem!

    var topCell : YonaUserHeaderWithTwoTabTableViewCell?
    private let nederlandPhonePrefix = "+31 (0) "
    var aUser : Users?
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
                self.tableView.reloadData()
            } else {
                //response from request failed
                
            }
        }

    
    }
    
    // MARK: - Actions

    func didSelectProfileTab() {
        isShowingProfile = true
        if let itmes = rightSideButtonItems {
            self.navigationItem.rightBarButtonItems = itmes
        }
        tableView.reloadData()
    }

    func didSelectBadgesTab() {
        isShowingProfile = false
        rightSideButtonItems = self.navigationItem.rightBarButtonItems
        self.navigationItem.rightBarButtonItems = nil
        tableView.reloadData()
    }

    @IBAction func userDidSelectEdit(sender: AnyObject) {
        if tableView.editing {
            rightSideButton.image = UIImage.init(named: "icnEdit")
            tableView.setEditing(false, animated: true)
            topCell?.setTopViewInNormalMode()
            updateUser()
            
        } else {
            rightSideButton.image = UIImage.init(named: "icnCreate")
            tableView.setEditing(true, animated: true)
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
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        
        if isShowingProfile {
            return 4
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if topCell == nil {
                topCell = (tableView.dequeueReusableCellWithIdentifier("YonaUserHeaderWithTwoTabTableViewCell", forIndexPath: indexPath) as! YonaUserHeaderWithTwoTabTableViewCell)
                topCell?.delegate = self
            }
            if let theUser = aUser {
                topCell!.setUser(theUser)
            }
            return topCell!

        }
        
        if isShowingProfile {
            let cell: YonaUserDisplayTableViewCell = tableView.dequeueReusableCellWithIdentifier("YonaUserDisplayTableViewCell", forIndexPath: indexPath) as! YonaUserDisplayTableViewCell
            cell.setData(delegate: self, cellType: ProfileCategoryHeader(rawValue: indexPath.row)!)
            return cell
        } else {
        // must be changed to show badges
            let cell: YonaUserDisplayTableViewCell = tableView.dequeueReusableCellWithIdentifier("YonaUserDisplayTableViewCell", forIndexPath: indexPath) as! YonaUserDisplayTableViewCell
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
        
        
        if !isUserDataValid() {
            return
        }
        Loader.Show()
         UserRequestManager.sharedInstance.updateUser((aUser?.userDataDictionaryForServer())!, onCompletion: {(success, message, code, user) in
            //success so get the user?
                if success {
                    Loader.Hide()
                    self.aUser = user
                    if let _ = user?.confirmMobileLink {
                        if let controller : ConfirmMobileValidationVC = R.storyboard.login.confirmPinValidationViewController {
                            controller.isFromUserProfile = true
                        
                            self.navigationController?.pushViewController(controller, animated: true)
                        }
                    }
                    self.tableView.reloadData()
                } else {
                    Loader.Hide()
                    if let alertMessage = message,
                        let code = code {
                        self.displayAlertMessage(code, alertDescription: alertMessage)
                    }
                }
            })
     }
    
    func isUserDataValid() -> Bool {
        if aUser?.firstName.characters.count == 0 {
            self.displayAlertMessage("", alertDescription:
                NSLocalizedString("enter-first-name-validation", comment: ""))
            return false
        }
        else if aUser?.lastName.characters.count == 0 {
            self.displayAlertMessage("", alertDescription:
                NSLocalizedString("enter-last-name-validation", comment: ""))
            return false
        } else if aUser?.mobileNumber.characters.count == 0 {
            self.displayAlertMessage("", alertDescription:
                NSLocalizedString("enter-number-validation", comment: ""))
            return false
        } else {
            var number = ""
            if let mobilenum = aUser?.mobileNumber {
                number =  mobilenum
                
                let trimmedWhiteSpaceString = number.removeWhitespace()
                let trimmedString = trimmedWhiteSpaceString.removeBrackets()
                
                if trimmedString.validateMobileNumber() == false {
                    self.displayAlertMessage("", alertDescription:
                        NSLocalizedString("enter-number-validation", comment: ""))
                    return false
                } else {
                aUser?.mobileNumber = trimmedString.stringByReplacingOccurrencesOfString("310", withString: "+31")
                }
                
            }
        }

    
        return true
    }
}
