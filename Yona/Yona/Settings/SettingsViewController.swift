//
//  SettingsViewController.swift
//  Yona
//
//  Created by Chandan on 28/03/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

enum  settingsOptions : Int {
    case changepin = 0
    case privacy
    case adddevice
    case unsubscribe
    case configreste
    case lastrow
    
    func simpleDescription() -> String {
        switch self {
        case .changepin:
            return NSLocalizedString("change-pin", comment: "")
        case .privacy:
            return NSLocalizedString("privacy", comment: "")
        case .adddevice:
            return NSLocalizedString("add-device", comment: "")
        case .unsubscribe:
            return NSLocalizedString("delete-user", comment: "")
        case .configreste:
            return NSLocalizedString("RESET", comment: "")
        default:
            return NSLocalizedString("no option", comment: "")
        }
    }

}


class SettingsViewController: UIViewController {
    var settingsArray:NSArray!
    @IBOutlet var tableView:UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.backgroundColor = UIColor.yiTableBGGreyColor()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "SettingsViewController")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidLayoutSubviews()
    {
        var tableViewInsets = UIEdgeInsetsZero
        tableViewInsets.top = 0
        tableView.contentInset = tableViewInsets
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
                                    if success == false {
                                        if let message = message {
                                            self.displayAlertMessage("", alertDescription: message)
                                        }
                                    }
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

        
        // Getting the Navcontroller on tab 2 (goals), and setting to initial controller
        
        let tabbar = (UIApplication.sharedApplication().delegate as! AppDelegate).window?.rootViewController as! BaseTabViewController
        
        if let views = tabbar.viewControllers {
            if  views.count > 2 {
                if let nav = views[2] as? UINavigationController {
                    nav.popToRootViewControllerAnimated(false)
                }
            }
            
        }
        
        UserRequestManager.sharedInstance.deleteUser({ (success, serverMessage, serverCode) in
            if success {
                NSUserDefaults.standardUserDefaults().setBool(false, forKey:  YonaConstants.nsUserDefaultsKeys.isGoalsAdded)
                
                
                if let welcome = R.storyboard.welcome.initialViewController {
                    self.view.window?.rootViewController?.presentViewController(welcome, animated: true, completion: nil)
                }
            }
            else {
                if let message = serverMessage {
                    self.displayAlertMessage("", alertDescription: message)
                }
            }
        })
    }
    
    @IBAction func unwindToSettingsView(segue: UIStoryboardSegue) {
        print(segue.sourceViewController)
    }
}

extension SettingsViewController:UITableViewDelegate {
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        #if DEBUG
            return settingsOptions.lastrow.rawValue
        #else            
            return (settingsOptions.lastrow.rawValue - 1)
        #endif
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.textLabel?.text = settingsOptions(rawValue: indexPath.row)?.simpleDescription()
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row {
        case settingsOptions.changepin.rawValue:
            //change pin
            if let loginVC = R.storyboard.login.loginViewController { //root view
                loginVC.isFromSettings = true
                //make sure the change password is presented as a nav controller else we run into issues when backgrounding the app
                let navController = R.storyboard.login.initialViewController
                navController?.pushViewController(loginVC, animated: false)
                self.view.window?.rootViewController?.presentViewController(navController!, animated: false, completion: nil)
                
            }

        case settingsOptions.privacy.rawValue:
             performSegueWithIdentifier(R.segue.settingsViewController.privacyStatementSegue, sender: self)
        case settingsOptions.adddevice.rawValue:
            callAddDeviceMethod()
        case settingsOptions.unsubscribe.rawValue:
            self.displayAlertOption(NSLocalizedString("delete-user", comment: ""),cancelButton: true, alertDescription: NSLocalizedString("deleteusermessage", comment: ""), onCompletion: { (buttonPressed) in
                switch buttonPressed {
                    case alertButtonType.OK:
                        self.callUnSubscribeMethod()
                    case alertButtonType.cancel:
                    break
                    //do nothing or send back to start of signup?
                    }
                })
            
        case settingsOptions.configreste.rawValue:
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: YonaConstants.nsUserDefaultsKeys.vpncompleted)
            NSUserDefaults.standardUserDefaults().setInteger(0, forKey: YonaConstants.nsUserDefaultsKeys.vpnSetupStatus)
            NSUserDefaults.standardUserDefaults().setBool(false,   forKey: "SIMULATOR_OPENVPN")
            
        default:
            return
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
     }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70.0
    }
}
