//
//  ValidationMasterView.swift
//  Yona
//
//  Created by Ben Smith on 14/06/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

class ValidationMasterView: LoginSignupValidationMasterView {
    
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
            } else if (codeMessage == YonaConstants.serverCodes.mobileConfirmMismatch) {
                self.infoLabel.text = message
            } else if (codeMessage == YonaConstants.serverCodes.pinResetMismatch) {
                self.infoLabel.text = message
            } else if (codeMessage == YonaConstants.serverCodes.userOverWriteConfirmCodeMismatch) {
                self.infoLabel.text = message
            } else {
                self.displayPincodeRemainingMessage()
            }
        }
    }

}
