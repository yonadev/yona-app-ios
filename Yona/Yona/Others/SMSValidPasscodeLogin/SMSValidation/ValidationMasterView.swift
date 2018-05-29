//
//  ValidationMasterView.swift
//  Yona
//
//  Created by Ben Smith on 14/06/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

class ValidationMasterView: LoginSignupValidationMasterView {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Nav bar Back button.
        self.navigationItem.hidesBackButton = true
        
        let viewWidth = self.view.frame.size.width
        let customView=UIView(frame: CGRect(x: 0, y: 0, width: (viewWidth-60)/2, height: 2))
        customView.backgroundColor=UIColor.yiDarkishPinkColor()
        
        self.progressView.addSubview(customView)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        #if DEBUG
            print ("pincode is \(YonaConstants.testKeys.otpTestCode)")
        #endif
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "ValidationMasterView")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as! [AnyHashable: Any])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.codeInputView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews()
    {
//        var scrollViewInsets = UIEdgeInsetsZero
//        scrollViewInsets.top = 0
//        scrollView.contentInset = scrollViewInsets
    }
    
    func checkCodeMessageShowAlert(_ message: String?, serverMessageCode: String?, codeInputView: CodeInputView){
        if let codeMessage = serverMessageCode,
            let serverMessage = message {
            if codeMessage == YonaConstants.serverCodes.tooManyFailedConfirmOTPAttemps {
                self.codeInputView.isUserInteractionEnabled = false
                self.infoLabel.text = serverMessage
            }//too many pin verify attempts so we need to clear and the user needs to request another one
            else if codeMessage == YonaConstants.serverCodes.tooManyPinResetAttemps {
                self.codeInputView.isUserInteractionEnabled = false
                self.infoLabel.text = message
                PinResetRequestManager.sharedInstance.pinResetClear({ (success, pincode, message, servercode) in
                    
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
