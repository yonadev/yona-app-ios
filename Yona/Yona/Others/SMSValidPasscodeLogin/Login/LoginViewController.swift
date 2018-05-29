//
//  LoginViewController.swift
//  Yona
//
//  Created by Chandan on 05/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit
import LocalAuthentication

class LoginViewController: LoginSignupValidationMasterView, AppLifeCylcleConsumer {
    var loginAttempts:Int = 1
    fileprivate var totalAttempts : Int = 3
    @IBOutlet weak var bottomSpaceContraint: NSLayoutConstraint!
    @IBOutlet var pinResetButton: UIButton!
    @IBOutlet var closeButton: UIBarButtonItem?
    @IBOutlet var accountBlockedTitle: UILabel?
    let touchIdButton = UIButton(type: UIButtonType.custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AppDelegate.instance = self
        setupPincodeScreenDifferentlyWithText(NSLocalizedString("login", comment: ""), headerTitleLabelText: nil, errorLabelText: NSLocalizedString("settings_current_pin_message", comment: ""), infoLabelText: NSLocalizedString("settings_current_pin", comment: ""), avtarImageName: R.image.icnSecure())
        
        touchIdButton.setImage(UIImage(named: "fingerPrint"), for: UIControlState())
        touchIdButton.setTitleColor(UIColor.black, for: UIControlState())
        touchIdButton.adjustsImageWhenHighlighted = false
        touchIdButton.imageView?.contentMode = .scaleAspectFit
        touchIdButton.contentHorizontalAlignment = .center
        touchIdButton.addTarget(self, action: #selector(touchIdButtonAction), for: .touchUpInside)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Loader.Hide()
        super.viewWillAppear(animated)
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "LoginViewController")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as! [AnyHashable: Any])
        
        
        serverHiddenView.alpha = 0.0
        
        serverHiddenView.layer.cornerRadius = 5.0
        serverHiddenView.layer.masksToBounds = true
        serverHiddenView.layer.borderWidth = 1.0
        serverHiddenView.layer.borderColor = UIColor.white.cgColor
        
        let longPressRec = UILongPressGestureRecognizer()
        longPressRec.minimumPressDuration = 4.0
        longPressRec.addTarget(self, action: #selector(longPress))
        infoLabel.addGestureRecognizer(longPressRec)
        infoLabel.isUserInteractionEnabled = true
        
        if !isFromSettings {
            //Get user call
            self.closeButton?.isEnabled = false
            self.closeButton?.tintColor = UIColor.clear
            checkUserExists()
            pinResetButton.isHidden = true
        } else {
            pinResetButton.isHidden = true
            self.closeButton?.isEnabled = true
            self.closeButton?.tintColor = UIColor.white
            
            
        }
        
        
        setBackgroundColour()
        self.codeInputView.delegate = self
        self.codeInputView.secure = true
        codeView.addSubview(self.codeInputView)
        codeInputView.clear()
        if UserDefaults.standard.bool(forKey: YonaConstants.nsUserDefaultsKeys.isBlocked) {
            pinResetButton.isHidden = false
            codeInputView.isHidden = true
            setCornerRadius()
            errorLabel.isHidden = false
            errorLabel.text = NSLocalizedString("login.user.errorinfoText", comment: "")
            codeInputView.resignFirstResponder()
            accountBlockedTitle?.isHidden = false
            infoLabel?.isHidden = true
            avtarImage.image = UIImage(named: "icnSecure")
            return;
        }
        
        //keyboard functions
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: Selector.keyboardWasShown , name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        notificationCenter.addObserver(self, selector: Selector.keyboardWillBeHidden, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func appDidEnterForeground() {
        if Reachability.isNetworkReachable() {
            DispatchQueue.main.async(execute: {
                print(self.infoLabel.text!)
                let text = NSLocalizedString("connection-not-available", comment: "")
                
                if self.infoLabel.text == text {
                    self.infoLabel.text = NSLocalizedString("passcode-title", comment: "")
                }
                
            })
        } else {
            DispatchQueue.main.async(execute: {
                self.infoLabel.text = NSLocalizedString("connection-not-available", comment: "")
            })
        }
    }
    
    
    
    @objc func touchIdButtonAction() {
        AVTouchIDHelper().authenticateUser(withDesc: NSLocalizedString("touchId-alert", comment: ""),
            success: {
                
                self.authenticatedSuccessFully()
            
            }) { (error) in
//                if error.code == LAError.TouchIDNotEnrolled.rawValue {
//                    self.displayAlertOption("", cancelButton: false, alertDescription: "TouchId not enrolled", onCompletion: { _ in })
//                } else {
//                    self.displayAlertOption("", cancelButton: false, alertDescription: "Authentication Failed", onCompletion: { _ in })
//                }
                
        }
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        //        if NSUserDefaults.standardUserDefaults().boolForKey(YonaConstants.nsUserDefaultsKeys.isBlocked) == false {
        //            self.codeInputView.becomeFirstResponder()
        //        }
        if isFromSettings {
            codeInputView.becomeFirstResponder()
            closeButton  = UIBarButtonItem(image: UIImage(named: "icnBack"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(LoginViewController.backToSettings(_:)))
            self.navigationItem.setLeftBarButton(closeButton, animated: false)
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews()
    {
        
        var scrollViewInsets = UIEdgeInsets.zero
        scrollViewInsets.top = 0
        scrollView.contentInset = scrollViewInsets
    }
    
    
    //MARK: Server changeView
    
    @IBAction func didPresChangeServer() {
        UIView.animate(withDuration: 0.3, animations: {
            self.serverHiddenView.alpha = 0.0
        })
        
        UserDefaults.standard.set(serverHiddenTextField.text, forKey: "YONA_URL")
        serverHiddenTextField.resignFirstResponder()
        
        
    }
    
    @IBAction func cancelChangeServer() {
        UIView.animate(withDuration: 0.3, animations: {
            self.serverHiddenView.alpha = 0.0
        })
        serverHiddenTextField.resignFirstResponder()
        codeInputView.becomeFirstResponder()
    }
    
    
    @IBAction func longPress(){
        if let url = UserDefaults.standard.string(forKey: "YONA_URL") {
            serverHiddenTextField.text = url
        }
        UIView.animate(withDuration: 0.3, animations: {
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
        UserDefaults.standard.set(true, forKey: YonaConstants.nsUserDefaultsKeys.isLoggedIn)
        UserRequestManager.sharedInstance.getUser(GetUserRequest.allowed){ (success, message, code, user) in
            if success {
                Loader.Hide()
                self.codeInputView.resignFirstResponder()
                let defaults = UserDefaults.standard
                defaults.set(false, forKey: YonaConstants.nsUserDefaultsKeys.isBlocked)
                if self.isFromSettings {
                    self.performSegue(withIdentifier: R.segue.loginViewController.transToPasscode, sender: self)
                } else {
                    UserRequestManager.sharedInstance.informServerAppIsOpen(user!, success: { })
                    AppDelegate.sharedApp.doTestCycleForVPN()
                    self.navigationController?.popViewController(animated: false)
                    self.dismiss(animated: true, completion: nil)
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
    
    func codeInputView(_ codeInputView: CodeInputView, didFinishWithCode code: String) {
        let passcode = KeychainManager.sharedInstance.getPINCode()
        if code ==  passcode {
            authenticatedSuccessFully()
        } else {
            errorLabel.isHidden = false
            self.codeInputView.clear()
            if loginAttempts == totalAttempts {
                
                let defaults = UserDefaults.standard
                defaults.set(true, forKey: YonaConstants.nsUserDefaultsKeys.isBlocked)
                defaults.synchronize()
                errorLabel.isHidden = false
                self.navigationItem.title = NSLocalizedString("login", comment: "")
                self.codeInputView.resignFirstResponder()
                self.pinResetButton.isHidden = false
                self.codeInputView.isHidden = true
                self.accountBlockedTitle?.isHidden = false
                self.infoLabel?.isHidden = true
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
        self.pinResetButton.backgroundColor = UIColor.white
        if isFromSettings {
            self.pinResetButton.setTitleColor(UIColor.yiMangoColor(), for: UIControlState())
        } else {
            self.pinResetButton.setTitleColor(UIColor.yiGrapeColor(), for: UIControlState())
        }
        pinResetButton.layer.cornerRadius = pinResetButton.frame.size.height/2
        //        pinResetButton.layer.borderWidth = 1
    }
    
    @IBAction func pinResetTapped(_ sender: UIButton) {
        weak var tracker = GAI.sharedInstance().defaultTracker
        tracker!.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action", action: "pinResetTapped", label: "Reset the pin button pressed", value: nil).build() as! [AnyHashable: Any])
        
        self.pinResetTapped()
    }
    
    // Go Back To Previous VC
    @IBAction func backToSettings(_ sender: AnyObject) {
        weak var tracker = GAI.sharedInstance().defaultTracker
        tracker!.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action", action: "backToSettings", label: "Back to settings from pinreset", value: nil).build() as! [AnyHashable: Any])
        
        self.navigationController?.dismiss(animated: true, completion: nil)
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
                        case alertButtonType.ok:
                             let welcome = R.storyboard.welcome.welcomeViewController(())
                                self.view.window?.rootViewController?.dismiss(animated: false, completion:nil)
                             self.view.window?.rootViewController?.present(welcome!, animated: false, completion: nil)
                            
                        case alertButtonType.cancel:
                            break
                        }
                    })
                }
            } else {
                if UserDefaults.standard.bool(forKey: YonaConstants.nsUserDefaultsKeys.isBlocked) == false {
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
    func keyboardWasShown (_ notification: Notification) {
        
        guard let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        
        if let activeField = self.pinResetButton {
            let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
            var aRect = self.view.bounds
            aRect.origin.x = 64
            aRect.size.height -= 64
            
            aRect.size.height -= keyboardSize.size.height
            if (!aRect.contains(activeField.frame.origin)) {
                var frameToScrollTo = activeField.frame
                frameToScrollTo.size.height += 30
                self.scrollView.scrollRectToVisible(frameToScrollTo, animated: true)
            }
        }
        
        
        
        
        DispatchQueue.main.async(execute: {
            if AVTouchIDHelper().isBiometricSupported() {
                let width = UIScreen.main.bounds.width
                let height = keyboardSize.height
                print(width)
                let btnHeight = height / 4 - 3
                let btnWidth = (width / 3) - 2
                self.touchIdButton.frame = CGRect(x: 0, y: (UIScreen.main.bounds.height - btnHeight), width: btnWidth, height: btnHeight)
                
                self.touchIdButton.isHidden = false
                let keyBoardWindow = UIApplication.shared.windows.last
                keyBoardWindow?.addSubview(self.touchIdButton)
                keyBoardWindow?.bringSubview(toFront: self.touchIdButton)
                
                self.touchIdButtonAction()
            }
        })
        
    }
    
    func keyboardWillBeHidden(_ notification: Notification) {
        
        DispatchQueue.main.async(execute: {
            self.touchIdButton.removeFromSuperview()
        })
        
        let contentInsets = UIEdgeInsets.zero
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
    }
    
}
