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
    @IBOutlet weak var bottomSpaceContraint: NSLayoutConstraint!
    @IBOutlet var pinResetButton: UIButton!
    @IBOutlet var closeButton: UIBarButtonItem?
    @IBOutlet var accountBlockedTitle: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupPincodeScreenDifferentlyWithText(NSLocalizedString("change-pin", comment: ""), headerTitleLabelText: nil, errorLabelText: NSLocalizedString("settings_current_pin_message", comment: ""), infoLabelText: NSLocalizedString("settings_current_pin", comment: ""), avtarImageName: R.image.icnSecure)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if !isFromSettings {
            //Get user call
            self.closeButton?.enabled = false
            self.closeButton?.tintColor = UIColor.clearColor()
            checkUserExists()
        } else {
            self.closeButton?.enabled = true
            self.closeButton?.tintColor = UIColor.whiteColor()
        }
        
        setBackgroundColour()
        self.codeInputView.delegate = self
        self.codeInputView.secure = true
        codeView.addSubview(self.codeInputView)
        codeInputView.clear()
        if NSUserDefaults.standardUserDefaults().boolForKey(YonaConstants.nsUserDefaultsKeys.isBlocked) {
            
            self.codeInputView.hidden = true
            self.setCornerRadius()
            errorLabel.hidden = false
            errorLabel.text = NSLocalizedString("login.user.errorinfoText", comment: "")
            self.codeInputView.resignFirstResponder()
            self.accountBlockedTitle?.hidden = false
            self.infoLabel?.hidden = true
            return;
        }
        
        //keyboard functions
        let notificationCenter = NSNotificationCenter.defaultCenter() 
        notificationCenter.addObserver(self, selector: Selector.keyboardWasShown , name: UIKeyboardDidShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: Selector.keyboardWillBeHidden, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
//        if NSUserDefaults.standardUserDefaults().boolForKey(YonaConstants.nsUserDefaultsKeys.isBlocked) == false {
//            self.codeInputView.becomeFirstResponder()
//        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func viewDidLayoutSubviews()
    {
        
        var scrollViewInsets = UIEdgeInsetsZero
        scrollViewInsets.top = 0
        scrollView.contentInset = scrollViewInsets
    }

}

extension LoginViewController: CodeInputViewDelegate {
    func codeInputView(codeInputView: CodeInputView, didFinishWithCode code: String) {
        let passcode = KeychainManager.sharedInstance.getPINCode()
        if code ==  passcode {
            Loader.Show()
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: YonaConstants.nsUserDefaultsKeys.isLoggedIn)
            UserRequestManager.sharedInstance.getUser(GetUserRequest.allowed){ (success, message, code, user) in
                if success {
                    Loader.Hide()
                    self.codeInputView.resignFirstResponder()
                    let defaults = NSUserDefaults.standardUserDefaults()
                    defaults.setBool(false, forKey: YonaConstants.nsUserDefaultsKeys.isBlocked)
                    if self.isFromSettings {
                        self.performSegueWithIdentifier(R.segue.loginViewController.transToPasscode, sender: self)
                    } else {
                        self.navigationController?.popViewControllerAnimated(false)
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                    
                } else {
                    Loader.Hide()
                    if let message = message {
                        self.codeInputView.clear()
                        self.infoLabel.text = message
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
                self.codeInputView.hidden = true
                self.accountBlockedTitle?.hidden = false
                self.infoLabel?.hidden = true
                self.setCornerRadius()
                errorLabel.text = NSLocalizedString("login.user.errorinfoText", comment: "")
            }
            else {
                loginAttempts += 1
            }
        }
    }
    
    func setCornerRadius(){
        self.pinResetButton.backgroundColor = UIColor.whiteColor()
        self.pinResetButton.setTitleColor(UIColor.yiGrapeColor(), forState: UIControlState.Normal)
        pinResetButton.layer.cornerRadius = pinResetButton.frame.size.height/2
        pinResetButton.layer.borderWidth = 1
    }
    
    @IBAction func pinResetTapped(sender: UIButton) {
        self.pinResetTapped()
    }
    
    // Go Back To Previous VC
    @IBAction func backToSettings(sender: AnyObject) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /** If the user has been deleted on another device then this method will check if the user exists, and if not then it will send the user back to the welcome screen to re-register
     */
    func checkUserExists() {
        UserRequestManager.sharedInstance.getUser(GetUserRequest.allowed){ (success, message, code, user) in
            if code == YonaConstants.serverCodes.errorUserNotFound {
                if let serverMessage = message {
                    self.displayAlertOption("", cancelButton: true, alertDescription: serverMessage, onCompletion: { (buttonPressed) in
                        switch buttonPressed{
                        case alertButtonType.OK:
                            if let welcome = R.storyboard.welcome.welcomeViewController {
                                self.view.window?.rootViewController?.dismissViewControllerAnimated(false, completion:nil)
                                self.view.window?.rootViewController?.presentViewController(welcome, animated: false, completion: nil)
                            }
                        case alertButtonType.cancel:
                            break
                            //do nothing or send back to start of signup?
                        }
                    })
                }
            } else {
                if NSUserDefaults.standardUserDefaults().boolForKey(YonaConstants.nsUserDefaultsKeys.isBlocked) == false {
                    self.codeInputView.becomeFirstResponder()
                }
            }
        }
    }
}

private extension Selector {
    static let back = #selector(LoginViewController.backToSettings(_:))
}


extension LoginViewController: KeyboardProtocol {
    func keyboardWasShown (notification: NSNotification) {
        
        if let activeField = self.pinResetButton, keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
            var aRect = self.view.bounds
            aRect.origin.x = 64
            aRect.size.height -= 64

            aRect.size.height -= keyboardSize.size.height
            if (!CGRectContainsPoint(aRect, activeField.frame.origin)) {
                var frameToScrollTo = activeField.frame
                frameToScrollTo.size.height += 30
                self.scrollView.scrollRectToVisible(frameToScrollTo, animated: true)
            }
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        let contentInsets = UIEdgeInsetsZero
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
    }
}
