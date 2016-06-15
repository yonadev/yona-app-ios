//
//  SMSValidationViewController.swift
//  Yona
//
//  Created by Chandan on 01/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

class ConfirmMobileValidationVC: ValidationMasterView {
    @IBOutlet var resendOTPConfirmCodeButton: UIButton!

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setBackgroundColour()
        
        self.codeInputView.delegate = self
        self.codeInputView.secure = true
        codeView.addSubview(self.codeInputView)
        
        //keyboard functions
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: Selector.keyboardWasShown, name: UIKeyboardDidShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: Selector.keyboardWillBeHidden, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    @IBAction func sendOTPConfirmMobileAgain(sender: UIButton) {
        Loader.Show()
        UserRequestManager.sharedInstance.otpResendMobile{ (success, message, code) in
            if success {
                Loader.Hide()
                self.codeInputView.userInteractionEnabled = true
                #if DEBUG
                    print ("pincode is \(YonaConstants.testKeys.otpTestCode)")
                #endif
            } else {
                Loader.Hide()
                self.displayAlertMessage(message!, alertDescription: "")
            }
        }
    }

}

extension ConfirmMobileValidationVC: CodeInputViewDelegate {
    func codeInputView(codeInputView: CodeInputView, didFinishWithCode code: String) {

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
                self.performSegueWithIdentifier(R.segue.confirmMobileValidationVC.transToSetPincode, sender: self)

                self.codeInputView.clear()
                
            } else {
                self.checkCodeMessageShowAlert(message, serverMessageCode: serverCode, codeInputView: codeInputView)
                self.codeInputView.clear()
            }
        }
        
    }
}
