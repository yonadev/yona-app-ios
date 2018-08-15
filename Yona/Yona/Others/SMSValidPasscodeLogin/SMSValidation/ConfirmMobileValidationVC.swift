//
//  SMSValidationViewController.swift
//  Yona
//
//  Created by Chandan on 01/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//


// THIS whole class system is becoming a mess
// we should spend 1-2 days on cleaning it up
// Anders Liebl

import UIKit

class ConfirmMobileValidationVC: ValidationMasterView {
    @IBOutlet var resendOTPConfirmCodeButton: UIButton!
    var isFromUserProfile : Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "ConfirmMobileValidationVC")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as! [AnyHashable: Any])
        self.navigationController?.isNavigationBarHidden = false
        setBackgroundColour()
        
        self.codeInputView.delegate = self
        self.codeInputView.secure = true
        codeView.addSubview(self.codeInputView)
        
        //keyboard functions
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: Selector.keyboardWasShown, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        notificationCenter.addObserver(self, selector: Selector.keyboardWillBeHidden, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @IBAction func sendOTPConfirmMobileAgain(_ sender: UIButton) {
        Loader.Show()
        weak var tracker = GAI.sharedInstance().defaultTracker
        tracker!.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action", action: "sendOTPConfirmMobileAgain", label: "Send confirm OTP mobile again", value: nil).build() as! [AnyHashable: Any])
        
        UserRequestManager.sharedInstance.otpResendMobile{ (success, message, code) in
            if success {
                Loader.Hide()
                self.codeInputView.isUserInteractionEnabled = true
                #if DEBUG
                    print ("pincode is \(YonaConstants.testKeys.otpTestCode)")
                #endif
            } else {
                Loader.Hide()
                if let message = message {
                    self.infoLabel.text = message
                }
            }
        }
    }
    
    // Go Back To Previous VC
    @IBAction func back(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension ConfirmMobileValidationVC: CodeInputViewDelegate {
    func codeInputView(_ codeInputView: CodeInputView, didFinishWithCode code: String) {
        
        let body = [YonaConstants.jsonKeys.bodyCode: code]
        Loader.Show()
        UserRequestManager.sharedInstance.confirmMobileNumber(body as BodyDataDictionary) { success, message, serverCode in
            Loader.Hide()
            if (success) {
                self.codeInputView.resignFirstResponder()
                //Update flag
                if self.isFromUserProfile {
                    self.navigationController?.popToRootViewController(animated: true)
                } else {
                    setViewControllerToDisplay(ViewControllerTypeString.passcode, key: YonaConstants.nsUserDefaultsKeys.screenToDisplay)
                    self.performSegue(withIdentifier: R.segue.confirmMobileValidationVC.transToSetPincode, sender: self)
                }
                self.codeInputView.clear()
            } else {
                self.checkCodeMessageShowAlert(message, serverMessageCode: serverCode, codeInputView: codeInputView)
                self.codeInputView.clear()
            }
        }
    }
}

extension ConfirmMobileValidationVC: KeyboardProtocol {
    func keyboardWasShown (_ notification: Notification) {
        
        if let activeField = self.resendOTPConfirmCodeButton, let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
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
    }
    
    func keyboardWillBeHidden(_ notification: Notification) {
        let contentInsets = UIEdgeInsets.zero
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
    }
}
