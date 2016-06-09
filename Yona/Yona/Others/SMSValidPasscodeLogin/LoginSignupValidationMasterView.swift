//
//  LoginSignupValidationMasterView.swift
//  Yona
//
//  Created by Ben Smith on 02/05/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

class LoginSignupValidationMasterView: BaseViewController {
    
    var colorX : UIColor = UIColor.yiWhiteColor()
    var posi:CGFloat = 0.0
    var codeInputView = CodeInputView(frame: CGRect(x: 0, y: 0, width: 260, height: 55))
    
    @IBOutlet var resendCodeButton: UIButton!
    @IBOutlet var pinResetButton: UIButton!
    @IBOutlet var resendOverrideCode: UIButton!
    
    @IBOutlet var infoLabel: UILabel!
    @IBOutlet var progressView:UIView!
    @IBOutlet var codeView:UIView!
    @IBOutlet var headerTitleLabel: UILabel!
    @IBOutlet var scrollView: UIScrollView!
    
    //passcode screen variables
    @IBOutlet var screenNameLabel: UILabel!
    @IBOutlet var topView: UIView!
    @IBOutlet var avtarImage: UIImageView!
    @IBOutlet var errorLabel: UILabel!
    @IBOutlet var backButton: UIBarButtonItem!
    var isFromSettings = false
    var isFromPinReset:Bool?
    
    override func viewWillDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    

}
//MARK: - Messaging for views from server
extension LoginSignupValidationMasterView {
    func checkCodeMessageShowAlert(message: String?, serverMessageCode: String?, codeInputView: CodeInputView){
        if let codeMessage = serverMessageCode,
            let serverMessage = message {
            if codeMessage == YonaConstants.serverCodes.tooManyResendOTPAttemps {
                //make sure they are never on screen at same time
                self.resendCodeButton.hidden = false
                self.pinResetButton.hidden = true
                self.codeInputView.userInteractionEnabled = false
                #if DEBUG
                    self.displayAlertMessage("", alertDescription: serverMessage)
                #endif
            }//too many pin verify attempts so we need to clear and the user needs to request another one
            else if codeMessage == YonaConstants.serverCodes.tooManyPinResetAttemps {
                //make sure they are never on screen at same time
                self.resendCodeButton.hidden = true
                self.pinResetButton.hidden = false
                self.codeInputView.userInteractionEnabled = false
                #if DEBUG
                    self.displayAlertMessage("", alertDescription: serverMessage)
                #endif
                PinResetRequestManager.sharedInstance.pinResetClear({ (success, pincode, message, servercode) in
                    if success {
                        self.pinResetButton.hidden = false
                    }
                })
            } else {
                self.displayAlertMessage("", alertDescription: serverMessage)
            }
        }
    }
}

//MARK: - Setup Pincode screen differently for change pin
extension LoginSignupValidationMasterView {
    /** Helps to setup the pincode screen differnetly if you come from the settings menu and you want to change the pin, uses yellow background and different text
     - parameter headerTitleLabel: String, Title of header
     - parameter screenNameText: String, Screen name title
     - parameter infoLabelText: String lable on the information to the user
     */
    func setupPincodeScreenDifferentlyWithText(screenNameLabelText: String?, headerTitleLabelText: String?, errorLabelText: String?, infoLabelText: String?, avtarImageName: UIImage?) {
        let gradientNavBar = self.navigationController?.navigationBar as? GradientNavBar

        if isFromSettings {
            //Nav bar Back button.
            self.navigationItem.title = screenNameLabelText
            topView.backgroundColor = UIColor.yiMangoColor()
            self.view.backgroundColor = UIColor.yiMangoColor()
            gradientNavBar?.gradientColor = UIColor.yiMangoTriangleColor()
                        
            let viewWidth = self.view.frame.size.width
            let customView=UIView(frame: CGRectMake(0, 0, (viewWidth-60)/3, 2))
            customView.backgroundColor=UIColor.yiDarkishPinkColor()
            self.progressView.addSubview(customView)
            self.progressView.hidden = false
            avtarImage.image = avtarImageName
            if let headerTitleLabelText = headerTitleLabelText{
                headerTitleLabel.text = headerTitleLabelText
            }
            infoLabel.text = infoLabelText
            if let errorLabelText = errorLabelText {
                errorLabel.text = errorLabelText
                errorLabel.hidden = false
            }
        } else {
            //Nav bar Back button.
            self.navigationController?.setNavigationBarHidden(false, animated: false)
            gradientNavBar?.gradientColor = UIColor.yiGrapeTwoColor()
        }
    }
}

//MARK: - Button logic code used on 2 screens
extension LoginSignupValidationMasterView {
    func pinResetTapped() {
        isFromPinReset = true
        Loader.Show()
        PinResetRequestManager.sharedInstance.pinResetRequest({ (success, pincode, message, code) in
            if success {
                Loader.Hide()
                if let timeISOCode = pincode {
                    //we need to store this incase the app is backgrounded
                    NSUserDefaults.standardUserDefaults().setValue(timeISOCode, forKeyPath: YonaConstants.nsUserDefaultsKeys.timeToPinReset)
                    self.displayPincodeRemainingMessage()
                    NSUserDefaults.standardUserDefaults().setBool(true, forKey: YonaConstants.nsUserDefaultsKeys.isBlocked)
                    if self.isFromSettings { //need to reset the colour back to grape colour
                        let gradientNavBar = self.navigationController?.navigationBar as? GradientNavBar
                        gradientNavBar?.backgroundColor = UIColor.yiGrapeColor()
                        gradientNavBar?.gradientColor = UIColor.yiGrapeTwoColor()
                    }
                    setViewControllerToDisplay(ViewControllerTypeString.smsValidation, key: YonaConstants.nsUserDefaultsKeys.screenToDisplay)
                    if let sMSValidation = R.storyboard.login.sMSValidationViewController {
                        sMSValidation.isFromPinReset = true
                        self.navigationController?.pushViewController(sMSValidation, animated: false)
                    }
                }
            } else {
                Loader.Hide()
                //TODO: Will change this after this build
                self.displayAlertMessage("", alertDescription: NSLocalizedString("userNotFoundAlert", comment: ""))
            }
        })
    }

    func displayPincodeRemainingMessage(){
        guard let timeISOCode = NSUserDefaults.standardUserDefaults().valueForKey(YonaConstants.nsUserDefaultsKeys.timeToPinReset) as? String else {
            return
        }
        let (hour, minute, seconds) = timeISOCode.convertFromISO8601Duration()
        let localizedString = NSLocalizedString("login.user.pinResetReuestAlert", comment: "")
        let alert = NSString(format: localizedString, String(hour), String(minute), String(seconds))
        self.displayAlertMessage("", alertDescription: String(alert))
    }
}

extension Selector {
    static let keyboardWasShown = #selector(ConfirmPasscodeViewController.keyboardWasShown(_:))
    static let keyboardWillBeHidden = #selector(ConfirmPasscodeViewController.keyboardWillBeHidden(_:))
    static let pinResetTapped = #selector(SMSValidationViewController.pinResetTapped(_:))
    
}