//
//  SMSValidationViewController.swift
//  Yona
//
//  Created by Chandan on 01/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

final class SMSValidationViewController: LoginSignupValidationMasterView {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Nav bar Back button.
        self.navigationItem.hidesBackButton = true
        self.hideShowButtons()
        
        let viewWidth = self.view.frame.size.width
        let customView=UIView(frame: CGRectMake(0, 0, (viewWidth-60)/2, 2))
        customView.backgroundColor=UIColor.yiDarkishPinkColor()
        self.progressView.addSubview(customView)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        #if DEBUG
            self.displayAlertMessage(YonaConstants.testKeys.otpTestCode, alertDescription:"Pincode")
        #endif
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.codeInputView.becomeFirstResponder()
        
        self.codeInputView.delegate = self
        self.codeInputView.secure = true
        codeView.addSubview(self.codeInputView)
        hideShowButtons()
        
        //keyboard functions
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: Selector.keyboardWasShown, name: UIKeyboardDidShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: Selector.keyboardWillBeHidden, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func hideShowButtons() {
        if NSUserDefaults.standardUserDefaults().boolForKey(YonaConstants.nsUserDefaultsKeys.isBlocked) {
            self.resendCodeButton.hidden = true
            self.resendOverrideCode.hidden = true
        } else if NSUserDefaults.standardUserDefaults().boolForKey(YonaConstants.nsUserDefaultsKeys.adminOverride) {
            self.pinResetButton.hidden = true
            self.resendCodeButton.hidden = true
            self.resendOverrideCode.hidden = false
        } else {
            self.pinResetButton.hidden = true
            self.resendOverrideCode.hidden = true
        }
    }
    
    @IBAction func sendOTPAgain(sender: UIButton) {
        Loader.Show()
        UserRequestManager.sharedInstance.otpResendMobile{ (success, message, code) in
            if success {
                    Loader.Hide()
                self.codeInputView.userInteractionEnabled = true
                #if DEBUG
                    self.displayAlertMessage(YonaConstants.testKeys.otpTestCode, alertDescription:"Pincode")
                #endif
            } else {
                Loader.Hide()
                self.displayAlertMessage(message!, alertDescription: "")
            }
        }
    }

    @IBAction func pinResetTapped(sender: UIButton) {
        self.pinResetTapped()
    }
    
    @IBAction func overrideRequestTapped(sender: UIButton) {
        if let userBody = NSUserDefaults.standardUserDefaults().objectForKey(YonaConstants.nsUserDefaultsKeys.userToOverride) as? BodyDataDictionary {
            AdminRequestManager.sharedInstance.adminRequestOverride(userBody) { (success, message, code) in
                //if success then the user is sent OTP code, they are taken to this screen, get an OTP in text message must enter it
                if success {
                    #if DEBUG
                        self.displayAlertMessage(YonaConstants.testKeys.otpTestCode, alertDescription:"Pincode")
                    #endif
                    NSUserDefaults.standardUserDefaults().setObject(userBody, forKey: YonaConstants.nsUserDefaultsKeys.userToOverride)
                    NSUserDefaults.standardUserDefaults().setBool(true, forKey: YonaConstants.nsUserDefaultsKeys.adminOverride)
                    self.codeInputView.clear()
                }  else {
                    if let message = message,
                        let code = code {
                        self.displayAlertMessage(code, alertDescription: message)
                    }
                }
            }
        }
    }
}

extension SMSValidationViewController: CodeInputViewDelegate {
    func codeInputView(codeInputView: CodeInputView, didFinishWithCode code: String) {
        
        //the app becomes blocked if the user enters their passcode incorrectly 5 times, in this case we must verify the pin they enter
        if NSUserDefaults.standardUserDefaults().boolForKey(YonaConstants.nsUserDefaultsKeys.isBlocked) {
            self.codeInputView.userInteractionEnabled = true
            let body = ["code": code]
            Loader.Show()
            PinResetRequestManager.sharedInstance.pinResetVerify(body, onCompletion: { (success, nil, message, code) in
                Loader.Hide()
                if success {
                    self.pinResetButton.hidden = false
                    //pin verify succeeded, unblock app
                    NSUserDefaults.standardUserDefaults().setBool(false, forKey: YonaConstants.nsUserDefaultsKeys.isBlocked)
                    //clear pincode when reset is verified
                    PinResetRequestManager.sharedInstance.pinResetClear({ (success, nil, message, code) in
                        //Now send user back to pinreset screen, let them enter pincode and password again
                        self.codeInputView.resignFirstResponder()
                        //Update flag
                        setViewControllerToDisplay(ViewControllerTypeString.passcode, key: YonaConstants.nsUserDefaultsKeys.screenToDisplay)
                        
                        if let passcode = R.storyboard.login.passcodeViewController {
                            passcode.isFromPinReset = self.isFromPinReset
                            self.navigationController?.pushViewController(passcode, animated: false)
                        }
                        self.codeInputView.clear()
                    })
                } else {//pin reset verify code is wrong
                    self.displayPincodeRemainingMessage()
                    NSUserDefaults.standardUserDefaults().setBool(true, forKey: YonaConstants.nsUserDefaultsKeys.isBlocked)
                    self.codeInputView.clear()
                }
            })
        } else if NSUserDefaults.standardUserDefaults().boolForKey(YonaConstants.nsUserDefaultsKeys.adminOverride) {
            //if the admin override flag is true, then we need to post the users new details (passed from signup2 controller) with the confirm code they entered, necessary to use userdefaults incase the user  closes app during the override process and has to complete the process
            if let userBody = NSUserDefaults.standardUserDefaults().objectForKey(YonaConstants.nsUserDefaultsKeys.userToOverride) as? BodyDataDictionary {
                Loader.Show()
                UserRequestManager.sharedInstance.postUser(userBody, confirmCode: code){ (success, message, serverCode, user) in
                    Loader.Hide()
                    if success {
                        //reset our userdefaults to store the new user body
                        NSUserDefaults.standardUserDefaults().setBool(false, forKey: YonaConstants.nsUserDefaultsKeys.adminOverride)
                        self.codeInputView.resignFirstResponder()
                        //Update flag
                        setViewControllerToDisplay(ViewControllerTypeString.passcode, key: YonaConstants.nsUserDefaultsKeys.screenToDisplay)
                        
                        if let passcode = R.storyboard.login.passcodeViewController {
                            self.navigationController?.pushViewController(passcode, animated: false)
                        }
                        
                        self.codeInputView.clear()
                    } else {
                        self.checkCodeMessageShowAlert(message, serverMessageCode: serverCode, codeInputView: codeInputView)
                        self.codeInputView.clear()
                    }
                }
            }
        } else { //normal confirm passcode block with OTP sent to them
            let body =
                [
                    YonaConstants.jsonKeys.bodyCode: code
                ]
            Loader.Show()
            UserRequestManager.sharedInstance.confirmMobileNumber(body) { success, message, serverCode in
                Loader.Hide()
                if (success) {
                    self.codeInputView.resignFirstResponder()
                    //Update flag
                    
                    setViewControllerToDisplay(ViewControllerTypeString.passcode, key: YonaConstants.nsUserDefaultsKeys.screenToDisplay)
                    
                    if let passcode = R.storyboard.login.passcodeViewController {
                        self.navigationController?.pushViewController(passcode, animated: false)
                    }
                    
                    self.codeInputView.clear()
                    
                } else {
                    self.checkCodeMessageShowAlert(message, serverMessageCode: serverCode, codeInputView: codeInputView)
                    self.codeInputView.clear()
                }
            }
        }
    }
}

extension SMSValidationViewController: KeyboardProtocol {
    
    func keyboardWasShown (notification: NSNotification) {
        
        let viewHeight = self.view.frame.size.height
        let info : NSDictionary = notification.userInfo!
        let keyboardSize: CGSize = info.objectForKey(UIKeyboardFrameBeginUserInfoKey)!.CGRectValue.size
        let keyboardInset = keyboardSize.height - viewHeight/3
        
        
        let  pos = (resendCodeButton?.frame.origin.y)! + (resendCodeButton?.frame.size.height)!
        
        
        if (pos > (viewHeight-keyboardSize.height)) {
            posi = pos-(viewHeight-keyboardSize.height)
            self.view.frame.origin.y -= posi
            
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
