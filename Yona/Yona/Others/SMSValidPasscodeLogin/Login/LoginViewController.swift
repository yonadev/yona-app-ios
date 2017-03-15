//
//  LoginViewController.swift
//  Yona
//
//  Created by Chandan on 05/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit
import LocalAuthentication

class LoginViewController: LoginSignupValidationMasterView {
    var loginAttempts:Int = 1
    private var totalAttempts : Int = 3
    @IBOutlet weak var bottomSpaceContraint: NSLayoutConstraint!
    @IBOutlet var pinResetButton: UIButton!
    @IBOutlet var closeButton: UIBarButtonItem?
    @IBOutlet var accountBlockedTitle: UILabel?
    
    let touchIdButton = UIButton(type: UIButtonType.Custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPincodeScreenDifferentlyWithText(NSLocalizedString("login", comment: ""), headerTitleLabelText: nil, errorLabelText: NSLocalizedString("settings_current_pin_message", comment: ""), infoLabelText: NSLocalizedString("settings_current_pin", comment: ""), avtarImageName: R.image.icnSecure)
        
        touchIdButton.setImage(UIImage(named: "fingerPrint"), forState: .Normal)
        touchIdButton.setTitleColor(UIColor.blackColor(), forState: UIControlState())
        touchIdButton.adjustsImageWhenHighlighted = false
        touchIdButton.imageView?.contentMode = .ScaleAspectFit
        touchIdButton.contentHorizontalAlignment = .Center
        touchIdButton.addTarget(self, action: #selector(touchIdButtonAction), forControlEvents: .TouchUpInside)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "LoginViewController")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
        
        
        serverHiddenView.alpha = 0.0
        
        serverHiddenView.layer.cornerRadius = 5.0
        serverHiddenView.layer.masksToBounds = true
        serverHiddenView.layer.borderWidth = 1.0
        serverHiddenView.layer.borderColor = UIColor.whiteColor().CGColor
        
        let longPressRec = UILongPressGestureRecognizer()
        longPressRec.minimumPressDuration = 4.0
        longPressRec.addTarget(self, action: #selector(longPress))
        infoLabel.addGestureRecognizer(longPressRec)
        infoLabel.userInteractionEnabled = true
        
        if !isFromSettings {
            //Get user call
            self.closeButton?.enabled = false
            self.closeButton?.tintColor = UIColor.clearColor()
            checkUserExists()
            pinResetButton.hidden = true
        } else {
            pinResetButton.hidden = true
            self.closeButton?.enabled = true
            self.closeButton?.tintColor = UIColor.whiteColor()
            
            
        }
        
        
        setBackgroundColour()
        self.codeInputView.delegate = self
        self.codeInputView.secure = true
        codeView.addSubview(self.codeInputView)
        codeInputView.clear()
        if NSUserDefaults.standardUserDefaults().boolForKey(YonaConstants.nsUserDefaultsKeys.isBlocked) {
            pinResetButton.hidden = false
            codeInputView.hidden = true
            setCornerRadius()
            errorLabel.hidden = false
            errorLabel.text = NSLocalizedString("login.user.errorinfoText", comment: "")
            codeInputView.resignFirstResponder()
            accountBlockedTitle?.hidden = false
            infoLabel?.hidden = true
            avtarImage.image = UIImage(named: "icnSecure")
            return;
        }
        
        //keyboard functions
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: Selector.keyboardWasShown , name: UIKeyboardDidShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: Selector.keyboardWillBeHidden, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func touchIdButtonAction() {
        AVTouchIDHelper().authenticateUser(withDesc: NSLocalizedString("touchId-alert", comment: ""),
            success: {
                
                self.authenticatedSuccessFully()
            
            }) { (error) in
                
                self.displayAlertOption("", cancelButton: false, alertDescription: NSLocalizedString("touchId-failure", comment: ""), onCompletion: { _ in })
                
                
//                if error.code == LAError.TouchIDNotEnrolled.rawValue {
//                    self.displayAlertOption("", cancelButton: false, alertDescription: "TouchId not enrolled", onCompletion: { _ in })
//                } else {
//                    self.displayAlertOption("", cancelButton: false, alertDescription: "Authentication Failed", onCompletion: { _ in })
//                }
                
        }
    }
    
    
    
    override func viewDidAppear(animated: Bool) {
        //        if NSUserDefaults.standardUserDefaults().boolForKey(YonaConstants.nsUserDefaultsKeys.isBlocked) == false {
        //            self.codeInputView.becomeFirstResponder()
        //        }
        if isFromSettings {
            codeInputView.becomeFirstResponder()
            closeButton  = UIBarButtonItem(image: UIImage(named: "icnBack"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(LoginViewController.backToSettings(_:)))
            self.navigationItem.setLeftBarButtonItem(closeButton, animated: false)
            
        }
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
    
    
    //MARK: Server changeView
    
    @IBAction func didPresChangeServer() {
        UIView.animateWithDuration(0.3, animations: {
            self.serverHiddenView.alpha = 0.0
        })
        
        NSUserDefaults.standardUserDefaults().setObject(serverHiddenTextField.text, forKey: "YONA_URL")
        serverHiddenTextField.resignFirstResponder()
        
        
    }
    
    @IBAction func cancelChangeServer() {
        UIView.animateWithDuration(0.3, animations: {
            self.serverHiddenView.alpha = 0.0
        })
        serverHiddenTextField.resignFirstResponder()
        codeInputView.becomeFirstResponder()
    }
    
    
    @IBAction func longPress(){
        if let url = NSUserDefaults.standardUserDefaults().stringForKey("YONA_URL") {
            serverHiddenTextField.text = url
        }
        UIView.animateWithDuration(0.3, animations: {
            self.serverHiddenView.alpha = 1.0
            }, completion: { completed in
                self.serverHiddenTextField.becomeFirstResponder()
        })
        
        //animateWithDuration(0.3, animations: {
        //
        // })
    }
    
    
    
}

extension LoginViewController: CodeInputViewDelegate {
    
    func authenticatedSuccessFully() {
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
                    UserRequestManager.sharedInstance.informServerAppIsOpen(user!, success: { })
                    AppDelegate.sharedApp!.doTestCycleForVPN()
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
    
    func codeInputView(codeInputView: CodeInputView, didFinishWithCode code: String) {
        let passcode = KeychainManager.sharedInstance.getPINCode()
        if code ==  passcode {
            authenticatedSuccessFully()
        } else {
            errorLabel.hidden = false
            self.codeInputView.clear()
            if loginAttempts == totalAttempts {
                
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setBool(true, forKey: YonaConstants.nsUserDefaultsKeys.isBlocked)
                defaults.synchronize()
                errorLabel.hidden = false
                self.navigationItem.title = NSLocalizedString("login", comment: "")
                self.codeInputView.resignFirstResponder()
                self.pinResetButton.hidden = false
                self.codeInputView.hidden = true
                self.accountBlockedTitle?.hidden = false
                self.infoLabel?.hidden = true
                self.setCornerRadius()
                avtarImage.image = UIImage(named: "icnSecure")
                errorLabel.text = NSLocalizedString("login.user.errorinfoText", comment: "")
            }
            else {
                errorLabel.text = NSLocalizedString("passcode-tryagain", comment: "")
                loginAttempts += 1
            }
        }
    }
    
    func setCornerRadius(){
        self.pinResetButton.backgroundColor = UIColor.whiteColor()
        if isFromSettings {
            self.pinResetButton.setTitleColor(UIColor.yiMangoColor(), forState: UIControlState.Normal)
        } else {
            self.pinResetButton.setTitleColor(UIColor.yiGrapeColor(), forState: UIControlState.Normal)
        }
        pinResetButton.layer.cornerRadius = pinResetButton.frame.size.height/2
        //        pinResetButton.layer.borderWidth = 1
    }
    
    @IBAction func pinResetTapped(sender: UIButton) {
        weak var tracker = GAI.sharedInstance().defaultTracker
        tracker!.send(GAIDictionaryBuilder.createEventWithCategory("ui_action", action: "pinResetTapped", label: "Reset the pin button pressed", value: nil).build() as [NSObject : AnyObject])
        
        self.pinResetTapped()
    }
    
    // Go Back To Previous VC
    @IBAction func backToSettings(sender: AnyObject) {
        weak var tracker = GAI.sharedInstance().defaultTracker
        tracker!.send(GAIDictionaryBuilder.createEventWithCategory("ui_action", action: "backToSettings", label: "Back to settings from pinreset", value: nil).build() as [NSObject : AnyObject])
        
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /** If the user has been deleted on another device then this method will check if the user exists, and if not then it will send the user back to the welcome screen to re-register
     */
    func checkUserExists() {
        UserRequestManager.sharedInstance.getUser(GetUserRequest.allowed){ (success, message, code, user) in
            if code == YonaConstants.serverCodes.errorUserNotFound {
                Loader.Hide()
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
        
        guard let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() else { return }
        
        
        if let activeField = self.pinResetButton {
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
        
        
        
        
        dispatch_async(dispatch_get_main_queue(),{
            if AVTouchIDHelper().isBiometricSupported() {
                let width = UIScreen.mainScreen().bounds.width
                let height = CGRectGetHeight(keyboardSize)
                print(width)
                let btnHeight = height / 4 - 3
                let btnWidth = (width / 3) - 2
                self.touchIdButton.frame = CGRect(x: 0, y: (UIScreen.mainScreen().bounds.height - btnHeight), width: btnWidth, height: btnHeight)
                
                self.touchIdButton.hidden = false
                let keyBoardWindow = UIApplication.sharedApplication().windows.last
                keyBoardWindow?.addSubview(self.touchIdButton)
                keyBoardWindow?.bringSubviewToFront(self.touchIdButton)
            }
        })
        
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        
        dispatch_async(dispatch_get_main_queue(), {
            self.touchIdButton.removeFromSuperview()
        })
        
        let contentInsets = UIEdgeInsetsZero
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
    }
    
}
