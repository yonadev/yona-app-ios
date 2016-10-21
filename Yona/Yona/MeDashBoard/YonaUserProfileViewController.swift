//
//  ProfileViewController.swift
//  Yona
//
//  Created by Chandan on 23/03/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

enum validateError {
    case firstname
    case lastname
    case nickname
    case phone
    case none
}

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
    
    override func viewWillAppear(animated: Bool) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "YonaUserProfileViewController")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
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
        weak var tracker = GAI.sharedInstance().defaultTracker
        tracker!.send(GAIDictionaryBuilder.createEventWithCategory("ui_action", action: "userDidSelectEditUserProfile", label: "Edit user profile button selected", value: nil).build() as [NSObject : AnyObject])
        
        if tableView.editing {
            let result = isUserDataValid()
            if  result == .none {
                rightSideButton.image = UIImage.init(named: "icnEdit")
                tableView.setEditing(false, animated: true)
                topCell?.setTopViewInNormalMode()
                updateUser()
            } else {
                switch result {
                case .firstname:
                    let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1)) as! YonaUserDisplayTableViewCell
                    cell.setActive()
                case .lastname:
                    let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 1)) as! YonaUserDisplayTableViewCell
                    cell.setActive()
                case .nickname:
                    let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 1)) as! YonaUserDisplayTableViewCell
                    cell.setActive()
                case .phone:
                    let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 1)) as! YonaUserDisplayTableViewCell
                    cell.setActive()
                default:
                    return
                }
            
            }
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
//            var gradientView = GradientSmooth.init(frame: cell.frame)
//            gradientView.setGradientSmooth(UIColor.yiGrapeColor(), color2: UIColor.yiBgGradientTwoColor())
//            cell.addSubview(gradientView)
//            cell.sendSubviewToBack(gradientView)
            return cell
        } else {
        // must be changed to show badges
            let cell: YonaUserDisplayTableViewCell = tableView.dequeueReusableCellWithIdentifier("YonaUserDisplayTableViewCell", forIndexPath: indexPath) as! YonaUserDisplayTableViewCell
            cell.setData(delegate: self, cellType: ProfileCategoryHeader(rawValue: indexPath.row)!)
//            var gradientView = GradientSmooth.init(frame: cell.frame)
//            gradientView.setGradientSmooth(UIColor.yiGrapeColor(), color2: UIColor.yiBgGradientTwoColor())
//            cell.addSubview(gradientView)
//            cell.sendSubviewToBack(gradientView)
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
        
        if isUserDataValid() != .none {
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
    
    func isUserDataValid() -> validateError {
        if aUser?.firstName.characters.count == 0 {
            self.displayAlertMessage("", alertDescription:
                NSLocalizedString("enter-first-name-validation", comment: ""))
            return .firstname
        }
        else if aUser?.lastName.characters.count == 0 {
            self.displayAlertMessage("", alertDescription:
                NSLocalizedString("enter-last-name-validation", comment: ""))
            return .lastname
        } else if aUser?.mobileNumber.characters.count == 0 {
            self.displayAlertMessage("", alertDescription:
                NSLocalizedString("enter-number-validation", comment: ""))
            return .phone
        } else if aUser?.nickname.characters.count == 0 {
            self.displayAlertMessage("", alertDescription:
                NSLocalizedString("enter-nickname-validation", comment: ""))
            return .nickname
        } else {
            var number = ""
            if let mobilenum = aUser?.mobileNumber {
                number =  mobilenum
                
                let trimmedWhiteSpaceString = number.removeWhitespace()
                let trimmedString = trimmedWhiteSpaceString.removeBrackets()
                
                if trimmedString.validateMobileNumber() == false {
                    self.displayAlertMessage("", alertDescription:
                        NSLocalizedString("enter-number-validation", comment: ""))
                    return .phone
                } else {
                aUser?.mobileNumber = trimmedString.stringByReplacingOccurrencesOfString("310", withString: "+31")
                }
                
            }
        }

    
        return .none
    }
}
