 //
//  AdminOverrideValidationVC.swift
//  Yona
//
//  Created by Ben Smith on 14/06/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

class AdminOverrideValidationVC: ValidationMasterView {
    @IBOutlet var resendConfirmationCodeButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "AdminOverrideValidationVC")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as? [AnyHashable: Any])
        
        setBackgroundColour()
        self.navigationController?.isNavigationBarHidden = false
        self.codeInputView.delegate = self
        self.codeInputView.secure = true
        codeView.addSubview(self.codeInputView)
        
        //keyboard functions
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(_:)) , name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func sendAdminRequestConfirmationCodeAction(_ sender: UIButton) {
        weak var tracker = GAI.sharedInstance().defaultTracker
        tracker!.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action", action: "sendAdminRequestConfirmationCode", label: "Send Admin Request for new confirmation code", value: nil).build() as? [AnyHashable: Any])
        
        Loader.Show()
        if let userBody = UserDefaults.standard.object(forKey: YonaConstants.nsUserDefaultsKeys.userBody) as? BodyDataDictionary {
            if let mobileNumber = userBody["mobileNumber"] as? String {
                AdminRequestManager.sharedInstance.adminRequestOverride(mobileNumber){ (success, message, code) in
                    Loader.Hide()
                    //if success then the user is sent Confirmation code, they are taken to this screen, get a Confirmation code in text message must enter it
                    if success {
                        UserDefaults.standard.set(true, forKey: YonaConstants.nsUserDefaultsKeys.adminOverride)
                    } else {
                        if let message = message {
                            self.infoLabel.text = message
                        }
                    }
                }
            }
        }

    }
    
    // Go Back To Previous VC
    @IBAction func back(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }

}

extension AdminOverrideValidationVC: CodeInputViewDelegate {
    func codeInputView(_ codeInputView: CodeInputView, didFinishWithCode code: String) {

        if UserDefaults.standard.bool(forKey: YonaConstants.nsUserDefaultsKeys.adminOverride) {
            //if the admin override flag is true, then we need to post the users new details (passed from signup2 controller) with the confirm code they entered, necessary to use userdefaults incase the user  closes app during the override process and has to complete the process
            if let userBody = UserDefaults.standard.object(forKey: YonaConstants.nsUserDefaultsKeys.userBody) as? BodyDataDictionary {
                Loader.Show()
                UserRequestManager.sharedInstance.postUser(userBody, confirmCode: code){ (success, message, serverCode, user) in
                    Loader.Hide()
                    self.codeInputView.clear()
                    if success {
                        //reset our userdefaults to store the new user body
                        UserDefaults.standard.set(false, forKey: YonaConstants.nsUserDefaultsKeys.adminOverride)
                        self.codeInputView.resignFirstResponder()
                        //Update flag
                        UserDefaults.standard.set(false, forKey: YonaConstants.nsUserDefaultsKeys.confirmPinFromSignUp)
                        setViewControllerToDisplay(ViewControllerTypeString.setPin, key: YonaConstants.nsUserDefaultsKeys.screenToDisplay)
                        self.performSegue(withIdentifier: R.segue.adminOverrideValidationVC.transToSetPincode, sender: self)
                    } else {
                        self.checkCodeMessageShowAlert(message, serverMessageCode: serverCode, codeInputView: codeInputView)
                    }
                }
            }
        }
    }
}
 
 extension AdminOverrideValidationVC: KeyboardProtocol {
    @objc func keyboardWasShown (_ notification: Notification) {
        
        if let activeField = self.resendConfirmationCodeButton, let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
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
    
    @objc func keyboardWillBeHidden(_ notification: Notification) {
        let contentInsets = UIEdgeInsets.zero
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
    }
 }
