//
//  LoginViewController.swift
//  Yona
//
//  Created by Chandan on 05/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

class LoginViewController: LoginSignupValidationMasterView {
    @IBOutlet var errorLabel: UILabel!
    
    var loginAttempts:Int = 1
    private var totalAttempts : Int = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Nav bar Back button.
        self.navigationItem.hidesBackButton = true
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        dispatch_async(dispatch_get_main_queue(), {
            if NSUserDefaults.standardUserDefaults().boolForKey(YonaConstants.nsUserDefaultsKeys.isBlocked) {
                if let pinResetButton = self.pinResetButton{
                    pinResetButton.hidden = false
                }
            } else {
                if let pinResetButton = self.pinResetButton{
                    pinResetButton.hidden = true
                }            }
            self.gradientView.colors = [UIColor.yiGrapeTwoColor(), UIColor.yiGrapeTwoColor()]
        })
        
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        codeInputView.delegate = self
        codeInputView.secure = true
        codeView.addSubview(codeInputView)
        
        codeInputView.becomeFirstResponder()
        
        if NSUserDefaults.standardUserDefaults().boolForKey(YonaConstants.nsUserDefaultsKeys.isBlocked) {
            if let pinResetButton = self.pinResetButton{
                pinResetButton.hidden = false
            }
            self.displayAlertMessage("Login", alertDescription: NSLocalizedString("login.user.errorinfoText", comment: ""))
            errorLabel.hidden = false
            errorLabel.text = NSLocalizedString("login.user.errorinfoText", comment: "")
            return;
        }
        
        //keyboard functions
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: Selector.keyboardWasShown, name: UIKeyboardDidShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: Selector.keyboardWillBeHidden, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    }

extension LoginViewController: CodeInputViewDelegate {
    func codeInputView(codeInputView: CodeInputView, didFinishWithCode code: String) {
        let passcode = KeychainManager.sharedInstance.getPINCode()
        if code ==  passcode {
            codeInputView.resignFirstResponder()
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setBool(false, forKey: YonaConstants.nsUserDefaultsKeys.isBlocked)
            if let dashboardStoryboard = R.storyboard.dashboard.dashboardStoryboard {
                navigationController?.pushViewController(dashboardStoryboard, animated: true)
            }
        } else {
            errorLabel.hidden = false
            codeInputView.clear()
            if loginAttempts == totalAttempts {
                if let pinResetButton = self.pinResetButton{
                    pinResetButton.hidden = false
                }
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setBool(true, forKey: YonaConstants.nsUserDefaultsKeys.isBlocked)
                defaults.synchronize()
                self.displayAlertMessage("Login", alertDescription: NSLocalizedString("login.user.errorinfoText", comment: ""))
                errorLabel.hidden = false
                errorLabel.text = NSLocalizedString("login.user.errorinfoText", comment: "")
            }
            else {
                loginAttempts += 1
            }
        }
    }
    
    @IBAction func pinResetTapped(sender: UIButton) {
        self.pinResetTapped()
    }
}
