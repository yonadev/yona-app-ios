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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Nav bar Back button.
        self.navigationItem.hidesBackButton = true
        
        let viewWidth = self.view.frame.size.width
        let customView=UIView(frame: CGRectMake(0, 0, (viewWidth-60)/2, 2))
        customView.backgroundColor=UIColor.yiDarkishPinkColor()
        
        self.progressView.addSubview(customView)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        #if DEBUG
            print ("pincode is \(YonaConstants.testKeys.otpTestCode)")
        #endif
    }
}

extension AdminOverrideValidationVC: CodeInputViewDelegate {
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
                self.performSegueWithIdentifier(R.segue.adminOverrideValidationVC.transToSetPincode, sender: self)
                
                self.codeInputView.clear()
                
            } else {
                self.checkCodeMessageShowAlert(message, serverMessageCode: serverCode, codeInputView: codeInputView)
                self.codeInputView.clear()
            }
        }
    }
}