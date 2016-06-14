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
    //calls the admin request manager overriding it so that the pin can be reset
    @IBAction func overrideRequestTapped(sender: UIButton) {
        if let userBody = NSUserDefaults.standardUserDefaults().objectForKey(YonaConstants.nsUserDefaultsKeys.userToOverride) as? BodyDataDictionary {
            AdminRequestManager.sharedInstance.adminRequestOverride(userBody) { (success, message, code) in
                //if success then the user is sent OTP code, they are taken to this screen, get an OTP in text message must enter it
                if success {
                    #if DEBUG
                        print ("pincode is \(YonaConstants.testKeys.otpTestCode)")
                    #endif
                    NSUserDefaults.standardUserDefaults().setObject(userBody, forKey: YonaConstants.nsUserDefaultsKeys.userToOverride)
                    NSUserDefaults.standardUserDefaults().setBool(true, forKey: YonaConstants.nsUserDefaultsKeys.adminOverride)
                    self.codeInputView.clear()
                }  else {
                    if let message = message,
                        let code = code {
                        self.displayAlertMessage(code, alertDescription: message)
                    }
                }
            }
        }
    }
}

extension PinResetValidationVC: CodeInputViewDelegate {
    
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

