 //
//  AdminOverrideValidationVC.swift
//  Yona
//
//  Created by Ben Smith on 14/06/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

class AdminOverrideValidationVC: ValidationMasterView {
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
    
    @IBAction func sendAdminRequestOTPConfirmMobileAgain(sender: UIButton) {
        Loader.Show()
        if let userBody = NSUserDefaults.standardUserDefaults().objectForKey(YonaConstants.nsUserDefaultsKeys.userToOverride) as? BodyDataDictionary {
            if let mobileNumber = userBody["mobileNumber"] as? String {
                AdminRequestManager.sharedInstance.adminRequestOverride(mobileNumber){ (success, message, code) in
                    Loader.Hide()
                    //if success then the user is sent OTP code, they are taken to this screen, get an OTP in text message must enter it
                    if success {
                        NSUserDefaults.standardUserDefaults().setBool(true, forKey: YonaConstants.nsUserDefaultsKeys.adminOverride)
                    } else {
                        if let message = message,
                            let code = code {
                            self.displayAlertMessage(code, alertDescription: message)
                        }
                    }
                }
            }
        }

    }

}

extension AdminOverrideValidationVC: CodeInputViewDelegate {
    func codeInputView(codeInputView: CodeInputView, didFinishWithCode code: String) {

        if NSUserDefaults.standardUserDefaults().boolForKey(YonaConstants.nsUserDefaultsKeys.adminOverride) {
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
                        self.performSegueWithIdentifier(R.segue.pinResetValidationVC.transToSetPincode, sender: self)
                        
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
