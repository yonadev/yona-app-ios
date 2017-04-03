//
//  SettingsViewController.swift
//  Yona
//
//  Created by Chandan on 28/03/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit
import Messages
import MessageUI

enum  settingsOptions : Int {
    case changepin = 0
    case privacy
    case adddevice
    case unsubscribe
    case emailSupport
    case configreste
    case lastrow
    
    func simpleDescription() -> String {
        switch self {
        case .changepin:
            return NSLocalizedString("change-pin-settings", comment: "")
        case .privacy:
            return NSLocalizedString("privacy", comment: "")
        case .adddevice:
            return NSLocalizedString("add-device", comment: "")
        case .unsubscribe:
            return NSLocalizedString("delete-user", comment: "")
        case .configreste:
            return NSLocalizedString("RESET", comment: "")
        case .emailSupport:
            return NSLocalizedString("Contact Support", comment: "")
        default:
            return NSLocalizedString("no option", comment: "")
        }
    }

}


class SettingsViewController: UIViewController, MFMailComposeViewControllerDelegate {
    var settingsArray:NSArray!
    @IBOutlet var tableView:UITableView!
    var gradientView: GradientSmooth!

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
                NSUserDefaults.standardUserDefaults().setBool(false, forKey: YonaConstants.nsUserDefaultsKeys.vpncompleted)
                NSUserDefaults.standardUserDefaults().setInteger(VPNSetupStatus.openVPNAppInstalledStep3.rawValue, forKey: YonaConstants.nsUserDefaultsKeys.vpnSetupStatus)
                AppDelegate.firstTime = true
                
                if let welcome = R.storyboard.welcome.initialViewController {
                    self.view.window?.rootViewController?.presentViewController(welcome, animated: true) {
                        let viewController = welcome.viewControllers.first as? WelcomeViewController
                        viewController?.turnOffVPN()
                    }
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
//        #if DEBUG
//            return settingsOptions.lastrow.rawValue
//        #else            
            return (settingsOptions.lastrow.rawValue - 1)
//        #endif
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.textLabel?.text = settingsOptions(rawValue: indexPath.row)?.simpleDescription()
        cell.textLabel?.backgroundColor = UIColor.clearColor()

        gradientView = GradientSmooth.init(frame: cell.frame)
        gradientView.setGradientSmooth(UIColor.yiBgGradientTwoColor(), color2: UIColor.yiBgGradientOneColor())
        cell.backgroundView = gradientView
        
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
        
        case settingsOptions.emailSupport.rawValue:
            showAlertForEmailForUser()

        default:
            return
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
     }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70.0
    }
    
    //MARK: email thing
    
    
//    "emailsupport.no.email.client" = "You dont have an email configured on this device";
    
    func showAlertForEmailForUser() {
        
        let errorAlert = UIAlertController( title: NSLocalizedString("emailsupport.title", comment: ""), message:  NSLocalizedString("emailsupport.text", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
        let OKAction = UIAlertAction(title: NSLocalizedString("emailsupport.accept", comment: ""), style: .Default) { (action) in
            self.sendMail(true)
            return
        }
        errorAlert.addAction(OKAction)
        
        let CANCELAction = UIAlertAction(title: NSLocalizedString("emailsupport.decline", comment: ""), style: .Default) { (action) in
            self.sendMail(false)
            return
            }
        errorAlert.addAction(CANCELAction)
        
        
        
        self.presentViewController(errorAlert, animated: true) {
            return
        }

        
        
        self.displayAlertOption(NSLocalizedString("emailsupport.title", comment: ""),cancelButton: true, alertDescription: NSLocalizedString("emailsupport.text", comment: ""), onCompletion: { (buttonPressed) in
            switch buttonPressed {
            case alertButtonType.OK:
                self.sendMail(true)
            case alertButtonType.cancel:
                break
                //do nothing or send back to start of signup?
            }
        })

    
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        dismissViewControllerAnimated(true, completion: nil)
        
        UINavigationBar.appearance().tintColor = UIColor.yiWhiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.yiWhiteColor(),
                                                            NSFontAttributeName: UIFont(name: "SFUIDisplay-Bold", size: 14)!]
        UIBarButtonItem.appearance().tintColor = UIColor.yiMidBlueColor()

        
        if result == .Sent {
            let sendMailErrorAlert = UIAlertView(title: NSLocalizedString("emailsupport.finished.title", comment: ""), message: NSLocalizedString("emailsupport.finished.text", comment: ""), delegate: self, cancelButtonTitle: NSLocalizedString("OK", comment: ""))
            sendMailErrorAlert.show()
        } else  if result == .Failed {
            let sendMailErrorAlert = UIAlertView(title: NSLocalizedString("emailsupport.error.title", comment: ""), message: NSLocalizedString("emailsupport.error.text", comment: ""), delegate: self, cancelButtonTitle: NSLocalizedString("OK", comment: ""))
            sendMailErrorAlert.show()
        
        }
    }
    
    func sendMail(showPassword : Bool) {
        if !MFMailComposeViewController.canSendMail() {
            showSendMailErrorAlert()
            return
        }
        
        if let yonaPassword =  KeychainManager.sharedInstance.getYonaPassword(),
            let userlink = UserRequestManager.sharedInstance.newUser?.getSelfLink {
        
            
            
            let subject = NSLocalizedString("emailsupport.subject", comment: "")
            var body = ""
            if (showPassword) {
                
                 body = userlink + "\n\n" + "Password: '" + yonaPassword + "'"
            }
            let email = "app@yona.nu"
        
        
            UINavigationBar.appearance().tintColor = UIColor.yiMidBlueColor()
            UIBarButtonItem.appearance().tintColor = UIColor.yiMidBlueColor()
            
            
            let picker = MFMailComposeViewController()
  
            picker.mailComposeDelegate = self
            picker.setSubject(subject)
            picker.setToRecipients([email])
            picker.setMessageBody(body, isHTML: false)
        


            
            
            presentViewController(picker, animated: true, completion: nil)
        }
    }
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: NSLocalizedString("emailsupport.error.title", comment: ""), message: NSLocalizedString("emailsupport.error.text", comment: ""), delegate: self, cancelButtonTitle: NSLocalizedString("OK", comment: ""))
        sendMailErrorAlert.show()
    }

}
