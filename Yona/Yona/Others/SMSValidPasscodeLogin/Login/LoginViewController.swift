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
    
    @IBOutlet weak var bottomSpaceContraint: NSLayoutConstraint!
    @IBOutlet var pinResetButton: UIButton!
    @IBOutlet var closeButton: UIBarButtonItem?
    @IBOutlet var accountBlockedTitle: UILabel?
    
    var maxAttempts : Int = 5
    let touchIdButton = UIButton(type: UIButton.ButtonType.custom)
    
    //MARK: - view life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        AppDelegate.instance = self
        setupPincodeScreenDifferentlyWithText(NSLocalizedString("login", comment: ""), headerTitleLabelText: nil, errorLabelText: NSLocalizedString("settings_current_pin_message", comment: ""), infoLabelText: NSLocalizedString("settings_current_pin", comment: ""), avtarImageName: R.image.icnSecure())
        
        touchIdButton.setImage(UIImage(named: "fingerPrint"), for: UIControl.State())
        touchIdButton.setTitleColor(UIColor.black, for: UIControl.State())
        touchIdButton.adjustsImageWhenHighlighted = false
        touchIdButton.imageView?.contentMode = .scaleAspectFit
        touchIdButton.contentHorizontalAlignment = .center
        touchIdButton.addTarget(self, action: #selector(touchIdButtonAction), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "LoginViewController")
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as? [AnyHashable: Any])
        if !isFromSettings {
            //Get user call
            pinResetButton.isHidden = true
            self.closeButton?.isEnabled = false
            self.closeButton?.tintColor = UIColor.clear
        } else {
            pinResetButton.isHidden = false
            self.closeButton?.isEnabled = true
            self.closeButton?.tintColor = UIColor.white
        }
        setBackgroundColour()
        configureCodeInputView()
        if UserDefaults.standard.bool(forKey: YonaConstants.nsUserDefaultsKeys.isBlocked) {
            return showUserBlockedScreen()
        }
        //keyboard functions
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(_:)) , name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if isFromSettings {
            codeInputView.becomeFirstResponder()
            closeButton  = UIBarButtonItem(image: UIImage(named: "icnBack"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(LoginViewController.backToSettings(_:)))
            self.navigationItem.setLeftBarButton(closeButton, animated: false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        var scrollViewInsets = UIEdgeInsets.zero
        scrollViewInsets.top = 0
        scrollView.contentInset = scrollViewInsets
    }
    
    fileprivate func configureCodeInputView() {
        self.codeInputView.delegate = self
        self.codeInputView.secure = true
        codeView.addSubview(self.codeInputView)
        codeInputView.clear()
        self.codeInputView.becomeFirstResponder()
    }
    
    fileprivate func showUserBlockedScreen() {
        pinResetButton.isHidden = false
        codeInputView.isHidden = true
        setCornerRadius()
        errorLabel.isHidden = false
        errorLabel.text = NSLocalizedString("login.user.errorinfoText", comment: "")
        codeInputView.resignFirstResponder()
        accountBlockedTitle?.isHidden = false
        infoLabel?.isHidden = true
        avtarImage.image = UIImage(named: "icnSecure")
        return
    }
    
    @objc func touchIdButtonAction() {
        AVTouchIDHelper().authenticateUser(withDesc: NSLocalizedString("touchId-alert", comment: ""), success: {
            self.authenticatedSuccessFully()
        }) { (error) in
        }
    }
}

//MARK: - AppLifeCylcleConsumer Methods
extension LoginViewController: AppLifeCylcleConsumer {
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
}
//MARK: - CodeInputViewDelegate Methods
extension LoginViewController: CodeInputViewDelegate {
    fileprivate func handleGetUserSuccess(_ user: Users?) {
        self.codeInputView.resignFirstResponder()
        UserDefaults.standard.set(false, forKey: YonaConstants.nsUserDefaultsKeys.isBlocked)
        if self.isFromSettings {
            self.performSegue(withIdentifier: R.segue.loginViewController.transToPasscode, sender: self)
        } else {
            self.postOpenAppEvent(user)
            AppDelegate.sharedApp.doTestCycleForVPN()
            self.navigationController?.popViewController(animated: false)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    fileprivate func handleUserNotFound(_ message: ServerMessage?) {
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
        return
    }
    
    func authenticatedSuccessFully() {
        Loader.Show()
        UserDefaults.standard.set(true, forKey: YonaConstants.nsUserDefaultsKeys.isLoggedIn)
        UserRequestManager.sharedInstance.getUser(GetUserRequest.allowed){ (success, message, code, user) in
            Loader.Hide()
            if code == YonaConstants.serverCodes.errorUserNotFound {
                return self.handleUserNotFound(message) // If the user has been deleted on another device then this method, it will send the user back to the welcome screen to re-register
            }
            if success {
                self.handleGetUserSuccess(user)
            } else {
                if let message = message {
                    self.codeInputView.clear()
                    self.infoLabel.text = message
                }
            }
        }      
    }
    
    //post open app event on every launch of app
    func postOpenAppEvent(_ user: Users?) {
        UserRequestManager.sharedInstance.postOpenAppEvent(user!, onCompletion: { (success, message, code) in
            if !success{
                self.displayAlertMessage(code!, alertDescription: message!)
            }
        })
    }
    
    fileprivate func showMaxLoginAttemptsReachedScreen() {
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: YonaConstants.nsUserDefaultsKeys.isBlocked)
        defaults.synchronize()
        setFailedLoginAttempts(0)
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
    
    func setFailedLoginAttempts(_ attempts:Int){
        UserDefaults.standard.set(attempts, forKey: YonaConstants.nsUserDefaultsKeys.numberOfFailedLoginAttempts)
    }
    
    func getFailedLoginAttempts() -> Int {
        return UserDefaults.standard.integer(forKey: YonaConstants.nsUserDefaultsKeys.numberOfFailedLoginAttempts)
    }
    
    func codeInputView(_ codeInputView: CodeInputView, didFinishWithCode code: String) {
        let pin = KeychainManager.sharedInstance.getPINCode()
        if code ==  pin {
            authenticatedSuccessFully()
            setFailedLoginAttempts(0)
        } else {
            errorLabel.isHidden = false
            self.codeInputView.clear()
            if  getFailedLoginAttempts()+1 == maxAttempts {
                showMaxLoginAttemptsReachedScreen()
            } else {
                errorLabel.text = NSLocalizedString("passcode-tryagain", comment: "")
                setFailedLoginAttempts(getFailedLoginAttempts()+1)
            }
        }
    }
    
    func setCornerRadius(){
        self.pinResetButton.backgroundColor = UIColor.white
        if isFromSettings {
            self.pinResetButton.setTitleColor(UIColor.yiMangoColor(), for: UIControl.State())
        } else {
            self.pinResetButton.setTitleColor(UIColor.yiGrapeColor(), for: UIControl.State())
        }
        pinResetButton.layer.cornerRadius = pinResetButton.frame.size.height/2
    }
    
    @IBAction func pinResetTapped(_ sender: UIButton) {
        weak var tracker = GAI.sharedInstance().defaultTracker
        tracker!.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action", action: "pinResetTapped", label: "Reset the pin button pressed", value: nil).build() as? [AnyHashable: Any])
        self.pinResetTapped()
    }
    
    // Go Back To Previous VC
    @IBAction func backToSettings(_ sender: AnyObject) {
        weak var tracker = GAI.sharedInstance().defaultTracker
        tracker!.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action", action: "backToSettings", label: "Back to settings from pinreset", value: nil).build() as? [AnyHashable: Any])
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}

private extension Selector {
    static let back = #selector(LoginViewController.backToSettings(_:))
}

//MARK: - KeyboardProtocol Methods
extension LoginViewController: KeyboardProtocol {
    @objc func keyboardWasShown (_ notification: Notification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue else { return }
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
                keyBoardWindow?.bringSubviewToFront(self.touchIdButton)
                self.touchIdButtonAction()
            }
        })
    }
    
    @objc func keyboardWillBeHidden(_ notification: Notification) {
        DispatchQueue.main.async(execute: {
            self.touchIdButton.removeFromSuperview()
        })
        let contentInsets = UIEdgeInsets.zero
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
    }
}
