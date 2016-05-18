//
//  LoginSignupValidationMasterView.swift
//  Yona
//
//  Created by Ben Smith on 02/05/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

class LoginSignupValidationMasterView: UIViewController {
    
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
    @IBOutlet var gradientView: GradientView!
    
    //passcode screen variables
    @IBOutlet var screenNameLabel: UILabel!
    @IBOutlet var topView: UIView!
    @IBOutlet var avtarImage: UIImageView!
    @IBOutlet var gradientContainerView: UIView!
    @IBOutlet var errorLabel: UILabel!
    var isFromSettings = false
    
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
    func setupPincodeScreenDifferentlyWithText(headerTitleLabel: String, screenNameText: String, infoLabelText: String) {
        if isFromSettings {
            self.screenNameLabel.text = screenNameText
            topView.backgroundColor = UIColor.yiMangoColor()
            self.gradientView.colors = [UIColor.yiMangoTriangleColor(), UIColor.yiMangoTriangleColor()]
            gradientContainerView.backgroundColor = UIColor.yiMangoColor()
            
            let viewWidth = self.view.frame.size.width
            let customView=UIView(frame: CGRectMake(0, 0, (viewWidth-60)/3, 2))
            customView.backgroundColor=UIColor.yiDarkishPinkColor()
            self.progressView.addSubview(customView)
            self.progressView.hidden = false
            avtarImage = UIImageView(image: R.image.icnAccountCreated)
            self.headerTitleLabel.text = headerTitleLabel
            infoLabel.text = infoLabelText
            errorLabel.text = NSLocalizedString("settings_current_pin_message", comment: "")
            errorLabel.hidden = false
        } else {
            self.gradientView.colors = [UIColor.yiGrapeTwoColor(), UIColor.yiGrapeTwoColor()]
        }
    }
}

//MARK: - Button logic code used on 2 screens
extension LoginSignupValidationMasterView {
    func pinResetTapped() {
        Loader.Show()
        PinResetRequestManager.sharedInstance.pinResetRequest({ (success, pincode, message, code) in
            if success {
                Loader.Hide()
                print(pincode!)
                if pincode != nil {
                    NSUserDefaults.standardUserDefaults().setBool(true, forKey: YonaConstants.nsUserDefaultsKeys.isBlocked)
                    let timeToDisplay = pincode!.convertFromISO8601Duration()
                    setViewControllerToDisplay("SMSValidation", key: YonaConstants.nsUserDefaultsKeys.screenToDisplay)
                    let localizedString = NSLocalizedString("login.user.pinResetReuestAlert", comment: "")
                    let alert = NSString(format: localizedString, timeToDisplay!)
                    self.displayAlertMessage("", alertDescription: String(alert))
                    
                    if let sMSValidation = R.storyboard.sMSValidation.sMSValidationViewController {
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
}

extension Selector {
    static let keyboardWasShown = #selector(ConfirmPasscodeViewController.keyboardWasShown(_:))
    static let keyboardWillBeHidden = #selector(ConfirmPasscodeViewController.keyboardWillBeHidden(_:))
    static let pinResetTapped = #selector(SMSValidationViewController.pinResetTapped(_:))
    
}