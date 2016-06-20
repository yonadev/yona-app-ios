//
//  PinResetValidationVC.swift
//  Yona
//
//  Created by Ben Smith on 14/06/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

final class PinResetValidationVC: ValidationMasterView {
    @IBOutlet var resendOTPResetCode: UIButton!

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setBackgroundColour()
        displayPincodeRemainingMessage()
        self.codeInputView.delegate = self
        self.codeInputView.secure = true
        codeView.addSubview(self.codeInputView)
        
        //keyboard functions
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: Selector.keyboardWasShown, name: UIKeyboardDidShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: Selector.keyboardWillBeHidden, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    @IBAction func resendPinResetRequestOTPCode(sender: UIButton) {
        Loader.Show()
        PinResetRequestManager.sharedInstance.pinResendResetRequest{ (success, nil, message, code) in
            if success {
                Loader.Hide()
                self.codeInputView.userInteractionEnabled = true
                #if DEBUG
                    print ("pincode is \(code)")
                #endif
            } else {
                PinResetRequestManager.sharedInstance.pinResetRequest({ (success, pincode, message, code) in
                    Loader.Hide()
                    if success {
                        self.displayPincodeRemainingMessage()
                        self.codeInputView.userInteractionEnabled = true
                    } else {
                        if let message = message {
                            self.infoLabel.text = message
                        }
                    }
                })
            }
        }
    }
}

extension PinResetValidationVC: CodeInputViewDelegate {
    
    func codeInputView(codeInputView: CodeInputView, didFinishWithCode code: String) {
        self.codeInputView.userInteractionEnabled = true
        let body = ["code": code]
        Loader.Show()
        PinResetRequestManager.sharedInstance.pinResetVerify(body, onCompletion: { (success, nil, message, code) in
            Loader.Hide()
            if success {
                //pin verify succeeded, unblock app
                NSUserDefaults.standardUserDefaults().setBool(false, forKey: YonaConstants.nsUserDefaultsKeys.isBlocked)
                //clear pincode when reset is verified
                PinResetRequestManager.sharedInstance.pinResetClear({ (success, nil, message, code) in
                    //Now send user back to pinreset screen, let them enter pincode and password again
                    self.codeInputView.resignFirstResponder()
                    //Update flag
                    setViewControllerToDisplay(ViewControllerTypeString.passcode, key: YonaConstants.nsUserDefaultsKeys.screenToDisplay)
                    self.performSegueWithIdentifier(R.segue.pinResetValidationVC.transToSetPincode, sender: self)
                    self.codeInputView.clear()
                })
            } else {//pin reset verify code is wrong
                self.checkCodeMessageShowAlert(message, serverMessageCode: code, codeInputView: codeInputView)
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: YonaConstants.nsUserDefaultsKeys.isBlocked)
                self.codeInputView.clear()
            }
        })
    }
}

extension PinResetValidationVC: KeyboardProtocol {
    func keyboardWasShown (notification: NSNotification) {
        
        if let activeField = self.resendOTPResetCode, keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
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
