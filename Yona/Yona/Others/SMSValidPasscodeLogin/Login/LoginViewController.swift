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
        if NSUserDefaults.standardUserDefaults().boolForKey(YonaConstants.nsUserDefaultsKeys.isBlocked) {
            self.pinResetButton.hidden = false
        } else {
            self.pinResetButton.hidden = true
        }
        self.gradientView.colors = [UIColor.yiGrapeTwoColor(), UIColor.yiGrapeTwoColor()]
        
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        //Get user call
        checkUserExists()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.codeInputView.delegate = self
        self.codeInputView.secure = true
        codeView.addSubview(self.codeInputView)
        
        self.codeInputView.becomeFirstResponder()
        
        if NSUserDefaults.standardUserDefaults().boolForKey(YonaConstants.nsUserDefaultsKeys.isBlocked) {
            self.pinResetButton.hidden = false
            errorLabel.hidden = false
            errorLabel.text = NSLocalizedString("login.user.errorinfoText", comment: "")
            self.codeInputView.resignFirstResponder()
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
            self.codeInputView.resignFirstResponder()
            let defaults = NSUserDefaults.standardUserDefaults()
            UserRequestManager.sharedInstance.getUser(AllowedGetUserRequest.other){ (success, message, code, user) in
                defaults.setBool(false, forKey: YonaConstants.nsUserDefaultsKeys.isBlocked)
                if let dashboardStoryboard = R.storyboard.dashboard.dashboardStoryboard {
                    self.navigationController?.pushViewController(dashboardStoryboard, animated: true)
                }
            }
        } else {
            errorLabel.hidden = false
            self.codeInputView.clear()
            if loginAttempts == totalAttempts {
                self.pinResetButton.hidden = false
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setBool(true, forKey: YonaConstants.nsUserDefaultsKeys.isBlocked)
                defaults.synchronize()
                errorLabel.hidden = false
                self.codeInputView.resignFirstResponder()
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
    
    func checkUserExists() {
        UserRequestManager.sharedInstance.getUser(AllowedGetUserRequest.other){ (success, message, code, user) in
            if code == YonaConstants.serverCodes.errorUserNotFound {
                if let serverMessage = message {
                    self.displayAlertOption("", alertDescription: serverMessage, onCompletion: { (buttonPressed) in
                        switch buttonPressed{
                        case alertButtonType.OK:
                            if let welcome = R.storyboard.welcome.welcomeStoryboard {
                                UIApplication.sharedApplication().keyWindow?.rootViewController =  UINavigationController(rootViewController: welcome)
                            }
                        case alertButtonType.cancel:
                            break
                            //do nothing or send back to start of signup?
                        }
                    })
                }
            }
        }
    }
}

extension LoginViewController: KeyboardProtocol {
    func keyboardWasShown (notification: NSNotification) {
        
        let viewHeight = self.view.frame.size.height
        let info : NSDictionary = notification.userInfo!
        let keyboardSize: CGSize = info.objectForKey(UIKeyboardFrameBeginUserInfoKey)!.CGRectValue.size
        let keyboardInset = keyboardSize.height - viewHeight/3
        
        
        let  pos = (pinResetButton?.frame.origin.y)! + (pinResetButton?.frame.size.height)!
        
        if (pos > (viewHeight-keyboardSize.height)) {
            scrollView.setContentOffset(CGPointMake(0, pos-(viewHeight-keyboardSize.height)), animated: true)
        } else {
            scrollView.setContentOffset(CGPointMake(0, keyboardInset), animated: true)
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        if let position = resetTheView(posi, scrollView: scrollView, view: view) {
            posi = position
        }
    }
}

