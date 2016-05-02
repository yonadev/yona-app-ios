//
//  SMSValidationViewController.swift
//  Yona
//
//  Created by Chandan on 01/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

final class SMSValidationViewController: LoginSignupValidationMasterView {
    
    @IBOutlet var headerTitleLabel: UILabel!
    @IBOutlet var progressView: UIView!
    @IBOutlet var infoLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Nav bar Back button.
        self.navigationItem.hidesBackButton = true
        
        dispatch_async(dispatch_get_main_queue(), {
            if NSUserDefaults.standardUserDefaults().boolForKey(YonaConstants.nsUserDefaultsKeys.isBlocked) {
                if let pinResetButton = self.pinResetButton,
                    let resendCodeButton = self.resendCodeButton{
                    resendCodeButton.hidden = true
                    pinResetButton.hidden = false
                }
            } else {
                if let pinResetButton = self.pinResetButton,
                    let resendCodeButton = self.resendCodeButton{
                    resendCodeButton.hidden = false
                    pinResetButton.hidden = true
                }
            }
            self.gradientView.colors = [UIColor.yiGrapeTwoColor(), UIColor.yiGrapeTwoColor()]
        })
        
        let viewWidth = self.view.frame.size.width
        let customView=UIView(frame: CGRectMake(0, 0, (viewWidth-60)/2, 2))
        customView.backgroundColor=UIColor.yiDarkishPinkColor()
        progressView.addSubview(customView)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        self.infoLabel.text = NSLocalizedString("smsvalidation.user.infomessage", comment: "")
        self.headerTitleLabel.text = NSLocalizedString("smsvalidation.user.headerTitle", comment: "").uppercaseString
        if let resendCodeButton = self.resendCodeButton{
            resendCodeButton.setTitle(NSLocalizedString("smsvalidation.button.resendCode", comment: ""), forState: UIControlState.Normal)

        }
        
        #if DEBUG
            self.displayAlertMessage(YonaConstants.testKeys.otpTestCode, alertDescription:"Pincode")
        #endif
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.codeInputView = CodeInputView(frame: CGRect(x: 0, y: 0, width: 260, height: 55))
        self.codeInputView.becomeFirstResponder()
        
        if NSUserDefaults.standardUserDefaults().boolForKey(YonaConstants.nsUserDefaultsKeys.isBlocked) {
            if let pinResetButton = self.pinResetButton,
                let resendCodeButton = self.resendCodeButton{
                resendCodeButton.hidden = true
                pinResetButton.hidden = false
            
        } else {
            if let pinResetButton = self.pinResetButton,
                let resendCodeButton = self.resendCodeButton{
                resendCodeButton.hidden = false
                pinResetButton.hidden = true
            }
        }
        codeInputView.delegate = self
        codeInputView.secure = true
        codeView.addSubview(codeInputView)
        let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(50)))
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            if NSUserDefaults.standardUserDefaults().boolForKey(YonaConstants.nsUserDefaultsKeys.isBlocked) {
                if let resendCodeButton = self.resendCodeButton{
                    resendCodeButton.hidden = true
                }
            } else {
                if let resendCodeButton = self.resendCodeButton{
                    resendCodeButton.hidden = false
                }
            }
        })
        
        
        //keyboard functions
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: Selector.keyboardWasShown, name: UIKeyboardDidShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: Selector.keyboardWillBeHidden, name: UIKeyboardWillHideNotification, object: nil)
    }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func sendOTPAgain(sender: UIButton) {
        Loader.Show(delegate: self)
        APIServiceManager.sharedInstance.otpResendMobile{ (success, message, code) in
            if success {
                dispatch_async(dispatch_get_main_queue(), {
                    Loader.Hide(self)
                    self.codeInputView.userInteractionEnabled = true
                    #if DEBUG
                        self.displayAlertMessage(YonaConstants.testKeys.otpTestCode, alertDescription:"Pincode")
                    #endif
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    Loader.Hide(self)
                    self.displayAlertMessage(message!, alertDescription: "")
                })
            }
        }
    }

    @IBAction func pinResetTapped(sender: UIButton) {
        self.pinResetTapped()
    }
}

extension SMSValidationViewController: CodeInputViewDelegate {
    func codeInputView(codeInputView: CodeInputView, didFinishWithCode code: String) {
        
        if NSUserDefaults.standardUserDefaults().boolForKey(YonaConstants.nsUserDefaultsKeys.isBlocked) {
            codeInputView.userInteractionEnabled = true
            #if DEBUG
                let body = ["code": code]
            #endif
            Loader.Show(delegate: self)
            APIServiceManager.sharedInstance.pinResetVerify(body, onCompletion: { (success, nil, message, code) in
                if success {
                    if let pinResetButton = self.pinResetButton{
                        pinResetButton.hidden = false
                    }
                    dispatch_async(dispatch_get_main_queue(), {
                        Loader.Hide(self)
                    })
                    //pin verify succeeded, unblock app
                    NSUserDefaults.standardUserDefaults().setBool(false, forKey: YonaConstants.nsUserDefaultsKeys.isBlocked)
                    //clear pincode when reset is verified
                    APIServiceManager.sharedInstance.pinResetClear({ (success, nil, message, code) in
                        dispatch_async(dispatch_get_main_queue()) {
                            
                            #if DEBUG
                                self.displayAlertMessage(NSLocalizedString("passcode.user.UnlockPincode", comment: ""), alertDescription:"")
                                //Now send user back to pinreset screen, let them enter pincode and password again
                            #endif
                            codeInputView.resignFirstResponder()
                            //Update flag
                            setViewControllerToDisplay("Passcode", key: YonaConstants.nsUserDefaultsKeys.screenToDisplay)
                            
                            if let passcode = R.storyboard.passcode.passcodeStoryboard {
                                self.navigationController?.pushViewController(passcode, animated: false)
                            }
                            codeInputView.clear()
                        }
                    })
                } else {
                    //pin reset verify code is wrong
                    dispatch_async(dispatch_get_main_queue()) {
                        self.checkCodeMessageShowAlert(message, serverMessageCode: code, codeInputView: codeInputView)
                        Loader.Hide(self)
                        NSUserDefaults.standardUserDefaults().setBool(true, forKey: YonaConstants.nsUserDefaultsKeys.isBlocked)
                        codeInputView.clear()

                    }
                }
            })
        } else {
            let body =
                [
                    YonaConstants.jsonKeys.bodyCode: code
                ]
            
            APIServiceManager.sharedInstance.confirmMobileNumber(body) { success, message, serverCode in
                dispatch_async(dispatch_get_main_queue()) {
                    if (success) {
                        codeInputView.resignFirstResponder()
                        //Update flag
                        setViewControllerToDisplay("Passcode", key: YonaConstants.nsUserDefaultsKeys.screenToDisplay)
                        
                        if let passcode = R.storyboard.passcode.passcodeStoryboard {
                            self.navigationController?.pushViewController(passcode, animated: false)
                        }
                        
                        codeInputView.clear()
                        
                    } else {
                        self.checkCodeMessageShowAlert(message, serverMessageCode: serverCode, codeInputView: codeInputView)
                        codeInputView.clear()
                    }
                }
            }
        }
    }
}
