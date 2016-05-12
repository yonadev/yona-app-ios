//
//  SettingsViewController.swift
//  Yona
//
//  Created by Chandan on 28/03/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    var settingsArray:NSArray!
    @IBOutlet var tableView:UITableView!
    @IBOutlet var gradientView: GradientView!
    @IBOutlet var screenName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        UIApplication.sharedApplication().statusBarHidden = true
        settingsArray = [ NSLocalizedString("change-pin", comment: ""), NSLocalizedString("privacy", comment: ""), NSLocalizedString("add-device", comment: ""), NSLocalizedString("delete-user", comment: "")]
        
        
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        self.gradientView.colors = [UIColor.yiMango95Color(), UIColor.yiMangoColor()]
        self.tableView.backgroundColor = UIColor.yiTableBGGreyColor()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     Will call logout/unsubscribe/ API and removes all the user's data.
     
     - parameter none
     - return none
     */
    private func callAddDeviceMethod() {
        NewDeviceRequestManager.sharedInstance.putNewDevice({ (success, message, code, addDeviceCode) in
            if success {
                    let localizedString = NSLocalizedString("adddevice.user.AddDevicePasscodeMessage", comment: "")
                    if let addDeviceCode = addDeviceCode {
                        self.displayAlertOption("", cancelButton: false, alertDescription: String(format: localizedString, addDeviceCode), onCompletion: { (buttonPressed) in
                            switch buttonPressed{
                            case alertButtonType.OK:
                                NewDeviceRequestManager.sharedInstance.deleteNewDevice{ (success, message, code) in
                                    //device request deleted
                                }
                            default:
                                break
                            }
                            
                        })
                }
            } else {
                if let message = message {
                    self.displayAlertMessage("", alertDescription: message)
                }
            }
        })
    }
    
    /**
     Will call logout/unsubscribe API and wipes out all the user's data.
     
     - parameter none
     - return none, redirects user to Welcome screen
     */
    private func callUnSubscribeMethod() {
        //TODO: UnSubscribe API InProgress
        UserRequestManager.sharedInstance.deleteUser({ (success, serverMessage, serverCode) in
            if success {
                if let welcome = R.storyboard.welcome.welcomeStoryboard {
                    UIApplication.sharedApplication().keyWindow?.rootViewController =  UINavigationController(rootViewController: welcome)
                }
            }
            else {
                if let message = serverMessage {
                    self.displayAlertMessage("", alertDescription: message)
                }
            }
        })
    }
}

extension SettingsViewController:UITableViewDelegate {
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.settingsArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.textLabel?.text = settingsArray[indexPath.row] as? String;
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 2 {
            callAddDeviceMethod()
        }
        else if indexPath.row == 3 {
            self.displayAlertOption(NSLocalizedString("delete-user", comment: ""),cancelButton: true, alertDescription: NSLocalizedString("deleteusermessage", comment: ""), onCompletion: { (buttonPressed) in
                switch buttonPressed {
                case alertButtonType.OK:
                    self.callUnSubscribeMethod()
                    
                case alertButtonType.cancel:
                    break
                    //do nothing or send back to start of signup?
                }
            })
        }
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70.0
    }
}