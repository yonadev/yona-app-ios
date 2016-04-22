//
//  LoginViewController.swift
//  Yona
//
//  Created by Chandan on 05/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet var codeView:UIView!
    @IBOutlet var infoLabel: UILabel!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var pinResetButton: UIButton!
    @IBOutlet var errorLabel: UILabel!
    
    private var colorX : UIColor = UIColor.yiWhiteColor()
    var posi:CGFloat = 0.0
    var loginAttempts:Int = 1
    private var codeInputView: CodeInputView?
    private var totalAttempts : Int = 5
    override func viewDidLoad() {
        super.viewDidLoad()
        
      
        //Nav bar Back button.
        self.navigationItem.hidesBackButton = true
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        codeInputView = CodeInputView(frame: CGRect(x: 0, y: 0, width: 260, height: 55))
        
        if codeInputView != nil {
            codeInputView!.delegate = self
            codeInputView?.secure = true
            codeView.addSubview(codeInputView!)
            
            codeInputView!.becomeFirstResponder()
        }
        
        if NSUserDefaults.standardUserDefaults().boolForKey(YonaConstants.nsUserDefaultsKeys.isBlocked) {
                self.displayAlertMessage("Login", alertDescription: NSLocalizedString("login.user.errorinfoText", comment: ""))
                codeInputView!.resignFirstResponder()
                codeInputView!.userInteractionEnabled = false
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
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setBool(true, forKey: YonaConstants.nsUserDefaultsKeys.isBlocked)
                defaults.synchronize()
                self.displayAlertMessage("Login", alertDescription: NSLocalizedString("login.user.errorinfoText", comment: ""))
                codeInputView.userInteractionEnabled = false
                codeInputView.resignFirstResponder()
                errorLabel.hidden = false
                errorLabel.text = NSLocalizedString("login.user.errorinfoText", comment: "")
            }
            else {
                loginAttempts += 1
            }
        }
        
    }
    
    @IBAction func pinReset(sender: UIButton) {
        if NSUserDefaults.standardUserDefaults().boolForKey(YonaConstants.nsUserDefaultsKeys.isBlocked) {

            APIServiceManager.sharedInstance.pinResetRequest({ (success, pincode, message, code) in
                if success{
                        if let pincodeUnwrap = pincode {
                            dispatch_async(dispatch_get_main_queue(), {
                                self.displayAlertMessage(NSLocalizedString("challenges.addBudgetGoal.newPinCode", comment: ""), alertDescription: pincodeUnwrap)
                            })
                            //get otp sent again
                            APIServiceManager.sharedInstance.otpResendMobile{ (success, message, code) in
                                if success {
                                    dispatch_async(dispatch_get_main_queue(), {
                                        #if DEBUG
                                        self.displayAlertMessage(YonaConstants.testKeys.otpTestCode, alertDescription:"Pincode")
                                        //Now send user back to pinreset screen, let them enter pincode and password again
                                        #endif
                                        let defaults = NSUserDefaults.standardUserDefaults()
                                        defaults.setBool(false, forKey: YonaConstants.nsUserDefaultsKeys.isBlocked)
                                        defaults.synchronize()
                                        self.codeInputView!.userInteractionEnabled = true
                                        self.errorLabel.hidden = true
                                        self.loginAttempts = 0
                                        
                                    })

                                }
                            }
                        }
                    
                }
            })
            
        }
    }
}

private extension Selector {
    static let keyboardWasShown = #selector(LoginViewController.keyboardWasShown(_:))
    
    static let keyboardWillBeHidden = #selector(LoginViewController.keyboardWillBeHidden(_:))
}
