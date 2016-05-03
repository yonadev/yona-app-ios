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
        
        dispatch_async(dispatch_get_main_queue(), {
            if NSUserDefaults.standardUserDefaults().boolForKey(YonaConstants.nsUserDefaultsKeys.isBlocked) {
                self.resendCodeButton.hidden = true
                self.pinResetButton.hidden = false
            } else {
                self.resendCodeButton.hidden = false
                self.pinResetButton.hidden = true
            }
            self.gradientView.colors = [UIColor.yiGrapeTwoColor(), UIColor.yiGrapeTwoColor()]
        })
        
        let viewWidth = self.view.frame.size.width
        let customView=UIView(frame: CGRectMake(0, 0, (viewWidth-60)/2, 2))
        customView.backgroundColor=UIColor.yiDarkishPinkColor()
        self.progressView.addSubview(customView)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
                
        #if DEBUG
            self.displayAlertMessage(YonaConstants.testKeys.otpTestCode, alertDescription:"Pincode")
        #endif
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.codeInputView.becomeFirstResponder()
        
        if NSUserDefaults.standardUserDefaults().boolForKey(YonaConstants.nsUserDefaultsKeys.isBlocked) {
            self.resendCodeButton.hidden = true
            self.pinResetButton.hidden = false
        } else {
            self.resendCodeButton.hidden = false
            self.pinResetButton.hidden = true
        }
        self.codeInputView.delegate = self
        self.codeInputView.secure = true
        codeView.addSubview(self.codeInputView)
        let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(50)))
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            if NSUserDefaults.standardUserDefaults().boolForKey(YonaConstants.nsUserDefaultsKeys.isBlocked) {
                self.resendCodeButton.hidden = true
            } else {
                self.resendCodeButton.hidden = false
            }
        })
        
        
        //keyboard functions
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: Selector.keyboardWasShown, name: UIKeyboardDidShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: Selector.keyboardWillBeHidden, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @IBAction func sendOTPAgain(sender: UIButton) {
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
            self.codeInputView.userInteractionEnabled = true
            #if DEBUG
                let body = ["code": code]
            #endif
            Loader.Show(delegate: self)
            APIServiceManager.sharedInstance.pinResetVerify(body, onCompletion: { (success, nil, message, code) in
                if success {
                    self.pinResetButton.hidden = false
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
                            self.codeInputView.resignFirstResponder()
                            //Update flag
                            setViewControllerToDisplay("Passcode", key: YonaConstants.nsUserDefaultsKeys.screenToDisplay)
                            
                            if let passcode = R.storyboard.passcode.passcodeStoryboard {
                                self.navigationController?.pushViewController(passcode, animated: false)
                            }
                            self.codeInputView.clear()
                        }
                    })
                } else {
                    //pin reset verify code is wrong
                    dispatch_async(dispatch_get_main_queue()) {
                        self.checkCodeMessageShowAlert(message, serverMessageCode: code, codeInputView: codeInputView)
                        Loader.Hide(self)
                        NSUserDefaults.standardUserDefaults().setBool(true, forKey: YonaConstants.nsUserDefaultsKeys.isBlocked)
                        self.codeInputView.clear()

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
                        self.codeInputView.resignFirstResponder()
                        //Update flag
                        setViewControllerToDisplay("Passcode", key: YonaConstants.nsUserDefaultsKeys.screenToDisplay)
                        
                        if let passcode = R.storyboard.passcode.passcodeStoryboard {
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
