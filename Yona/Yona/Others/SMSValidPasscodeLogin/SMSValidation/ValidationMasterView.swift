//
//  ValidationMasterView.swift
//  Yona
//
//  Created by Ben Smith on 14/06/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

class ValidationMasterView: LoginSignupValidationMasterView {
    

    
    
    override func viewDidAppear(animated: Bool) {
        self.codeInputView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLayoutSubviews()
    {
        var scrollViewInsets = UIEdgeInsetsZero
        scrollViewInsets.top = 0
        scrollView.contentInset = scrollViewInsets
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
    
    func checkCodeMessageShowAlert(message: String?, serverMessageCode: String?, codeInputView: CodeInputView){
        if let codeMessage = serverMessageCode,
            let serverMessage = message {
            if codeMessage == YonaConstants.serverCodes.tooManyFailedConfirmOTPAttemps {
                self.codeInputView.userInteractionEnabled = false
                self.infoLabel.text = message
                #if DEBUG
                    self.displayAlertMessage("", alertDescription: serverMessage)
                #endif
            }//too many pin verify attempts so we need to clear and the user needs to request another one
            else if codeMessage == YonaConstants.serverCodes.tooManyPinResetAttemps {
                self.codeInputView.userInteractionEnabled = false
                self.infoLabel.text = message
                #if DEBUG
                    self.displayAlertMessage("", alertDescription: serverMessage)
                #endif
                PinResetRequestManager.sharedInstance.pinResetClear({ (success, pincode, message, servercode) in
                    if success {
                        //                        self.pinResetButton.hidden = false
                    }
                })
            } else if (codeMessage == YonaConstants.serverCodes.pinResetMismatch) {
                self.infoLabel.text = message
            }
            else {
                self.displayPincodeRemainingMessage()
            }
        }
    }
}
