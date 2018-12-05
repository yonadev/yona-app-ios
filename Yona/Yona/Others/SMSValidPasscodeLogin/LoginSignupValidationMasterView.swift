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
    var pinString: String? //the passcode to pass to confirm passcode view

    
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
    
    
    @IBOutlet var serverHiddenButton: UIButton!
    @IBOutlet var serverHiddenText: UILabel!
    @IBOutlet var serverHiddenTextField: UITextField!
    @IBOutlet var serverHiddenView : UIView!
    @IBOutlet var serverHiddenLonPres : UILongPressGestureRecognizer!

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - display methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        setBackgroundColour()
        
        if let confirmPinVC = segue.destination as? ConfirmPinViewController {
            confirmPinVC.isFromSettings = isFromSettings
            confirmPinVC.isFromPinReset = isFromPinReset
            confirmPinVC.pin = pinString
        } else if let setPinVC = segue.destination as? SetPinViewController {
            setPinVC.isFromPinReset = isFromPinReset
            setPinVC.isFromSettings = isFromSettings

        } else if let confirmMobile = segue.destination as? ConfirmMobileValidationVC {
            confirmMobile.isFromPinReset = isFromPinReset
            confirmMobile.isFromSettings = isFromSettings
            if confirmMobile.isFromSettings {
                self.navigationController?.navigationItem.setHidesBackButton(true, animated: true)
            }
        } else if let pinReset = segue.destination as? PinResetValidationVC {
            pinReset.isFromPinReset = isFromPinReset
            pinReset.isFromSettings = isFromSettings
            if pinReset.isFromSettings {
                self.navigationController?.navigationItem.setHidesBackButton(true, animated: true)
            }
        }else if let adminOverride = segue.destination as? AdminOverrideValidationVC {
            adminOverride.isFromPinReset = isFromPinReset
            adminOverride.isFromSettings = isFromSettings
            if adminOverride.isFromSettings {
                self.navigationController?.navigationItem.setHidesBackButton(true, animated: true)
            }
        }

    }
    
    func setBackgroundColour(){
        let gradientNavBar = self.navigationController?.navigationBar as? GradientNavBar
        if self.isFromSettings {
            if let topView = topView {
                topView.backgroundColor = UIColor.yiMangoColor()
            }
            self.view.backgroundColor = UIColor.yiMangoColor()
            gradientNavBar?.gradientColor = UIColor.yiMangoTriangleColor()
            gradientNavBar?.backgroundColor = UIColor.yiMangoColor()
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
    func setupPincodeScreenDifferentlyWithText(_ screenNameLabelText: String?, headerTitleLabelText: String?, errorLabelText: String?, infoLabelText: String?, avtarImageName: UIImage?) {
        setBackgroundColour()
        if isFromSettings {
            //Nav bar Back button.
            self.navigationItem.title = screenNameLabelText
            let viewWidth = self.view.frame.size.width
            let customView=UIView(frame: CGRect(x: 0, y: 0, width: (viewWidth-60)/3, height: 2))
            customView.backgroundColor=UIColor.yiDarkishPinkColor()
            self.progressView.addSubview(customView)
            self.progressView.isHidden = false
            avtarImage.image = avtarImageName
            if let headerTitleLabelText = headerTitleLabelText{
                headerTitleLabel.text = headerTitleLabelText
            }
            infoLabel.text = infoLabelText
            if let errorLabelText = errorLabelText {
                errorLabel.text = errorLabelText
                errorLabel.isHidden = false
            }
            
        } else {
            //Nav bar Back button.
            self.navigationController?.setNavigationBarHidden(false, animated: false)
        }
    }
}

//MARK: - Button logic code used on 2 screens
extension LoginSignupValidationMasterView {
    func pinResetTapped() {
        isFromPinReset = true
        view.isUserInteractionEnabled = false
        Loader.Show()
        PinResetRequestManager.sharedInstance.pinResetRequest({ (success, pincode, message, code) in
            if success {
                Loader.Hide()
                self.view.isUserInteractionEnabled = true
                if let timeISOCode = pincode {
                    //we need to store this incase the app is backgrounded
                    UserDefaults.standard.setValue(timeISOCode, forKeyPath: YonaConstants.nsUserDefaultsKeys.timeToPinReset)
                    UserDefaults.standard.setValue(Date(), forKey: YonaConstants.nsUserDefaultsKeys.timeToPinResetInitialRequestTime)
                    UserDefaults.standard.synchronize()
                    self.displayPincodeRemainingMessage()
                    
                    setViewControllerToDisplay(ViewControllerTypeString.pinResetValidation, key: YonaConstants.nsUserDefaultsKeys.screenToDisplay)
                    self.performSegue(withIdentifier: "transToPinResetValidation", sender: self)
                }
            } else {
                PinResetRequestManager.sharedInstance.pinResendResetRequest({ (success, pincode, message, code) in
                    Loader.Hide()
                    self.view.isUserInteractionEnabled = true

                    if success {
                        
                        setViewControllerToDisplay(ViewControllerTypeString.pinResetValidation, key: YonaConstants.nsUserDefaultsKeys.screenToDisplay)
                        self.performSegue(withIdentifier: "transToPinResetValidation", sender: self)

                    } else {
                        //TODO: Will change this after this build
                        if let message = message {
                            self.infoLabel.text = message
                        }
                    }
                })

            }
        })
    }

    func displayPincodeRemainingMessage(){
        guard let timeISOCode = UserDefaults.standard.value(forKey: YonaConstants.nsUserDefaultsKeys.timeToPinReset) as? String else {
            return
        }
        let (hour, minute, seconds) = timeISOCode.convertFromISO8601Duration()
        let localizedString = NSLocalizedString("login.user.pinResetRequestAlert", comment: "")
        let alert = NSString(format: localizedString as NSString, String(hour), String(minute), String(seconds))
        if let infolabelText = self.infoLabel {
            infolabelText.text = String(alert)
        }
    }
}

extension Selector {
    static let keyboardWasShown = #selector(ConfirmPinViewController.keyboardWasShown(_:))
    static let keyboardWillBeHidden = #selector(ConfirmPinViewController.keyboardWillBeHidden(_:))
    
}
