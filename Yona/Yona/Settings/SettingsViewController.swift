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
import Device_swift

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
            return NSLocalizedString("Install VPN", comment: "")
        case .emailSupport:
            return NSLocalizedString("Contact Support", comment: "")
        default:
            return NSLocalizedString("no option", comment: "")
        }
    }

}


class SettingsViewController: UIViewController {
    var settingsArray:NSArray!
    @IBOutlet var tableView:UITableView!
    var gradientView: GradientSmooth!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.backgroundColor = UIColor.yiTableBGGreyColor()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "SettingsViewController")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as? [AnyHashable: Any])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidLayoutSubviews()
    {
        var tableViewInsets = UIEdgeInsets.zero
        tableViewInsets.top = 0
        tableView.contentInset = tableViewInsets
    }
    
    /**
     Will call logout/unsubscribe/ API and removes all the user's data.
     
     - parameter none
     - return none
     */
    fileprivate func callAddDeviceMethod() {
        NewDeviceRequestManager.sharedInstance.putNewDevice({ (success, message, code, addDeviceCode) in
            if success {
                    let localizedString = NSLocalizedString("adddevice.user.AddDevicePasscodeMessage", comment: "")
                    if let addDeviceCode = addDeviceCode {
                        self.displayAlertOption("", cancelButton: false, alertDescription: String(format: localizedString, addDeviceCode), onCompletion: { (buttonPressed) in
                            switch buttonPressed{
                            case alertButtonType.ok:
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
    fileprivate func callUnSubscribeMethod() {
        //TODO: UnSubscribe API InProgress

        
        // Getting the Navcontroller on tab 2 (goals), and setting to initial controller
        
        let tabbar = (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController as! BaseTabViewController
        
        if let views = tabbar.viewControllers {
            if  views.count > 2 {
                if let nav = views[2] as? UINavigationController {
                    nav.popToRootViewController(animated: false)
                }
            }
            
        }
        
        UserRequestManager.sharedInstance.deleteUser({ (success, serverMessage, serverCode) in
            if success {
                UserDefaults.standard.set(false, forKey:  YonaConstants.nsUserDefaultsKeys.isGoalsAdded)
                UserDefaults.standard.set(false, forKey: YonaConstants.nsUserDefaultsKeys.vpncompleted)
                UserDefaults.standard.set(VPNSetupStatus.openVPNAppInstalledStep3.rawValue, forKey: YonaConstants.nsUserDefaultsKeys.vpnSetupStatus)
                UserDefaults.standard.set(nil, forKey: YonaConstants.nsUserDefaultsKeys.userBody)
                AppDelegate.firstTime = true
                UserDefaults.standard.set(false, forKey:  YonaConstants.nsUserDefaultsKeys.isLoggedIn)
                if let welcome = R.storyboard.welcome.instantiateInitialViewController() {
                    self.view.window?.rootViewController?.present(welcome, animated: true) {
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
    
    @IBAction func unwindToSettingsView(_ segue: UIStoryboardSegue) {
        print(segue.source)
    }
}

extension SettingsViewController:UITableViewDelegate {
    // MARK: - Table view data source
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        #if DEBUG
//            return settingsOptions.lastrow.rawValue
//        #else            
            return (settingsOptions.lastrow.rawValue )
//        #endif
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = settingsOptions(rawValue: indexPath.row)?.simpleDescription()
        cell.textLabel?.backgroundColor = UIColor.clear

        gradientView = GradientSmooth.init(frame: cell.frame)
        gradientView.setGradientSmooth(UIColor.yiBgGradientTwoColor(), color2: UIColor.yiBgGradientOneColor())
        cell.backgroundView = gradientView
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case settingsOptions.changepin.rawValue:
            //change pin
            if let loginVC = R.storyboard.login.loginViewController(()) { //root view
                loginVC.isFromSettings = true
                //make sure the change password is presented as a nav controller else we run into issues when backgrounding the app
                let navController = R.storyboard.login.instantiateInitialViewController()
                navController?.pushViewController(loginVC, animated: false)
                self.view.window?.rootViewController?.present(navController!, animated: false, completion: nil)
                
            }

        case settingsOptions.privacy.rawValue:
            performSegue(withIdentifier: R.segue.settingsViewController.privacyStatementSegue, sender: self)
        case settingsOptions.adddevice.rawValue:
            callAddDeviceMethod()
        case settingsOptions.unsubscribe.rawValue:
            self.displayAlertOption(NSLocalizedString("delete-user", comment: ""),cancelButton: true, alertDescription: NSLocalizedString("deleteusermessage", comment: ""), onCompletion: { (buttonPressed) in
                switch buttonPressed {
                    case alertButtonType.ok:
                        self.callUnSubscribeMethod()
                    case alertButtonType.cancel:
                    break
                    //do nothing or send back to start of signup?
                    }
                })
            
        case settingsOptions.configreste.rawValue:
            UserDefaults.standard.set(false, forKey: YonaConstants.nsUserDefaultsKeys.vpncompleted)
            UserDefaults.standard.set(0, forKey: YonaConstants.nsUserDefaultsKeys.vpnSetupStatus)
            UserDefaults.standard.set(false,   forKey: "SIMULATOR_OPENVPN")
        
            if let navController : UINavigationController = R.storyboard.vpnFlow.vpnNavigationController(()) {
                navController.modalPresentationStyle = UIModalPresentationStyle.currentContext
                DispatchQueue.main.async(execute: {
                    self.present(navController, animated: false, completion: nil)
                })
            }
            

            
        case settingsOptions.emailSupport.rawValue:
            showAlertForEmailForUser()

        default:
            return
        }
        tableView.deselectRow(at: indexPath, animated: true)
     }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    //MARK: email thing
    
    
//    "emailsupport.no.email.client" = "You dont have an email configured on this device";
    
    func showAlertForEmailForUser() {
        
        let errorAlert = UIAlertController( title: NSLocalizedString("emailsupport.title", comment: ""), message:  NSLocalizedString("emailsupport.text", comment: ""), preferredStyle: UIAlertController.Style.alert)
        let OKAction = UIAlertAction(title: NSLocalizedString("emailsupport.accept", comment: ""), style: .default) { (action) in
            self.sendMail(true)
            return
        }
        errorAlert.addAction(OKAction)
        
        let CANCELAction = UIAlertAction(title: NSLocalizedString("emailsupport.decline", comment: ""), style: .default) { (action) in
            self.sendMail(false)
            return
            }
        errorAlert.addAction(CANCELAction)
        
        
        
        self.present(errorAlert, animated: true) {
            return
        }

        
        
        self.displayAlertOption(NSLocalizedString("emailsupport.title", comment: ""),cancelButton: true, alertDescription: NSLocalizedString("emailsupport.text", comment: ""), onCompletion: { (buttonPressed) in
            switch buttonPressed {
            case alertButtonType.ok:
                self.sendMail(true)
            case alertButtonType.cancel:
                break
                //do nothing or send back to start of signup?
            }
        })

    
    }

    func sendMail(_ showPassword : Bool) {
        if !MFMailComposeViewController.canSendMail() {
            showSendMailErrorAlert()
            return
        }
        
        if let yonaPassword =  KeychainManager.sharedInstance.getYonaPassword(), let userlink = UserRequestManager.sharedInstance.newUser?.getSelfLink, let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"]  as? String, let appVersionCode = Bundle.main.infoDictionary?["CFBundleVersion"]  as? String  {
            let subject = NSLocalizedString("emailsupport.subject", comment: "")
            var body = ""
            if (showPassword) {
                body = userlink + "\n\n" + "Password: '" + yonaPassword + "'" + "\n\n" + "App version: " + appVersion + "\n" + "App build: " + appVersionCode + "\n" + "iOS Version: " + UIDevice.current.systemVersion + "\n" + "Device: " + UIDevice.current.deviceType.displayName
            }
            UINavigationBar.appearance().tintColor = UIColor.yiMidBlueColor()
            UIBarButtonItem.appearance().tintColor = UIColor.yiMidBlueColor()
            let picker = MFMailComposeViewController()
            picker.mailComposeDelegate = self
            picker.setSubject(subject)
            picker.setToRecipients([YonaConstants.supportEmail])
            picker.setMessageBody(body, isHTML: false)
            present(picker, animated: true, completion: nil)
        }
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: NSLocalizedString("emailsupport.error.title", comment: ""), message: NSLocalizedString("emailsupport.error.text", comment: ""), delegate: self, cancelButtonTitle: NSLocalizedString("OK", comment: ""))
        sendMailErrorAlert.show()
    }
}

    //MARK: MFMailComposeViewControllerDelegate
extension SettingsViewController: MFMailComposeViewControllerDelegate{
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
        
        UINavigationBar.appearance().tintColor = UIColor.yiWhiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.yiWhiteColor(),
                                                            NSAttributedString.Key.font: UIFont(name: "SFUIDisplay-Bold", size: 14)!]
        UIBarButtonItem.appearance().tintColor = UIColor.yiMidBlueColor()
        
        
        if result == .sent {
            let sendMailErrorAlert = UIAlertView(title: NSLocalizedString("emailsupport.finished.title", comment: ""), message: NSLocalizedString("emailsupport.finished.text", comment: ""), delegate: self, cancelButtonTitle: NSLocalizedString("OK", comment: ""))
            sendMailErrorAlert.show()
        } else  if result == .failed {
            let sendMailErrorAlert = UIAlertView(title: NSLocalizedString("emailsupport.error.title", comment: ""), message: NSLocalizedString("emailsupport.error.text", comment: ""), delegate: self, cancelButtonTitle: NSLocalizedString("OK", comment: ""))
            sendMailErrorAlert.show()
            
        }
    }
}
