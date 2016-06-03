//
//  LoginViewController.swift
//  Yona
//
//  Created by Chandan on 05/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

class LoginViewController: LoginSignupValidationMasterView {
    var loginAttempts:Int = 1
    private var totalAttempts : Int = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        
        if !isFromSettings {
        //Get user call
        checkUserExists()
        
        }
        setupPincodeScreenDifferentlyWithText(NSLocalizedString("change-pin", comment: ""), headerTitleLabelText: nil, errorLabelText: NSLocalizedString("settings_current_pin_message", comment: ""), infoLabelText: NSLocalizedString("settings_current_pin", comment: ""), avtarImageName: R.image.icnSecure)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.codeInputView.delegate = self
        self.codeInputView.secure = true
        codeView.addSubview(self.codeInputView)
        codeInputView.clear()
        self.codeInputView.becomeFirstResponder()
        
        if NSUserDefaults.standardUserDefaults().boolForKey(YonaConstants.nsUserDefaultsKeys.isBlocked) {
            
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
            Loader.Show()
            
            UserRequestManager.sharedInstance.getUser(GetUserRequest.allowed){ (success, message, code, user) in
                if success {
                    Loader.Hide()
                    self.codeInputView.resignFirstResponder()
                    let defaults = NSUserDefaults.standardUserDefaults()
                    defaults.setBool(false, forKey: YonaConstants.nsUserDefaultsKeys.isBlocked)
                    if self.isFromSettings {
                        if let passcode = R.storyboard.passcode.passcodeStoryboard {
                            passcode.isFromSettings = self.isFromSettings
                            self.navigationController?.pushViewController(passcode, animated: false)
                        }
                    } else {
                        self.navigationController?.popViewControllerAnimated(false)
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                    
                } else {
                    Loader.Hide()
                    if let message = message {
                        self.codeInputView.clear()
                        self.displayAlertMessage("", alertDescription: message)
                    }
                }
            }
        }
        else {
            errorLabel.hidden = false
            self.codeInputView.clear()
            if loginAttempts == totalAttempts {
                
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
    
    // Go Back To Previous VC
    @IBAction func back(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func checkUserExists() {
        UserRequestManager.sharedInstance.getUser(GetUserRequest.notAllowed){ (success, message, code, user) in
            if code == YonaConstants.serverCodes.errorUserNotFound {
                if let serverMessage = message {
                    self.displayAlertOption("", cancelButton: true, alertDescription: serverMessage, onCompletion: { (buttonPressed) in
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
            if !success {
                if let message = message {
                    self.displayAlertMessage("", alertDescription: message)
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

private extension Selector {
    static let back = #selector(LoginViewController.back(_:))
}

