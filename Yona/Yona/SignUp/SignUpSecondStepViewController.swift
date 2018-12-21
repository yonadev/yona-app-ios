
//
//  SignUpSecondStepViewController.swift
//  Yona
//
//  Created by Chandan on 31/03/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


class SignUpSecondStepViewController: BaseViewController,UIScrollViewDelegate {
    var activeField : UITextField?
    var colorX : UIColor = UIColor.yiWhiteColor()
    var previousRange: NSRange!
    
    var userFirstName: String?
    var userLastName: String?
        
    fileprivate let nederlandPhonePrefix = "31"
    
    @IBOutlet var mobileTextField: UITextField!
    fileprivate var mobilePrefixTextField: UITextField!
    @IBOutlet var nicknameTextField: UITextField!
    @IBOutlet var infoLabel: UILabel!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var previousButton: UIButton!
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        setupUI()
        checkUserEnteredPin()
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "SignUpSecondStepViewController")
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as? [AnyHashable: Any])
        IQKeyboardManager.shared.enable = false
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)) , name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHiden(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = true
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(_ notification: Notification)
    {
        self.topViewHeightConstraint.constant = 96;
        let animationDiration = (notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey]! as AnyObject).doubleValue!;
        let animationCurve = UIView.AnimationCurve.init(rawValue: Int((notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey]! as AnyObject).int32Value!))!
        UIView.animate(withDuration: animationDiration, animations: {
            UIView.setAnimationCurve(animationCurve)
            self.view.layoutIfNeeded()
        })
    }
    
    @objc func keyboardWillHiden(_ notification: Notification)
    {
        self.topViewHeightConstraint.constant = 210;
        let animationDiration = (notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey]! as AnyObject).doubleValue!;
        let animationCurve = UIView.AnimationCurve.init(rawValue: Int((notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey]! as AnyObject).int32Value!))!
        UIView.animate(withDuration: animationDiration, animations: {
            UIView.setAnimationCurve(animationCurve)
            self.view.layoutIfNeeded()
        }) 
    }
    
    fileprivate func setupUI() {
        // Text Delegates
        if var label = previousRange {
            label.length = 1
        }
        
        mobileTextField.delegate = self
        nicknameTextField.delegate = self
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector.dismissKeyboard)
        self.view.addGestureRecognizer(tap)
        
        // Adding right mode image to text fields
        let mobileImage = UIImageView(image: R.image.icnMobile())
        mobileImage.frame = CGRect(x: 0.0, y: 0.0, width: mobileImage.image!.size.width+10.0, height: mobileImage.image!.size.height);
        mobileImage.contentMode = UIView.ContentMode.center
        self.mobileTextField.rightView = mobileImage;
        self.mobileTextField.rightViewMode = UITextField.ViewMode.always
        
        let nicknameImage = UIImageView(image: R.image.icnNickname())
        nicknameImage.frame = CGRect(x: 0.0, y: 0.0, width: nicknameImage.image!.size.width, height: nicknameImage.image!.size.height);
        mobileImage.contentMode = UIView.ContentMode.center
        self.nicknameTextField.rightView = nicknameImage;
        self.nicknameTextField.rightViewMode = UITextField.ViewMode.always
        
        let mobileNumberView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        
        let plusLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        plusLabel.font = UIFont(name: "SFUIDisplay-Regular", size: 11)
        plusLabel.textColor = UIColor.yiBlackColor()
        plusLabel.contentMode = UIView.ContentMode.center
        plusLabel.textAlignment = NSTextAlignment.center
        plusLabel.text = "+"
        
        let prefixTextField = UITextField(frame: CGRect(x: 10, y: 0, width: 40, height: 50))
        prefixTextField.font = UIFont(name: "SFUIDisplay-Regular", size: 11)
        prefixTextField.textColor = UIColor.yiBlackColor()
        prefixTextField.contentMode = UIView.ContentMode.left
        prefixTextField.textAlignment = NSTextAlignment.left
        prefixTextField.text = nederlandPhonePrefix
        prefixTextField.leftView = plusLabel
        prefixTextField.leftViewMode = UITextField.ViewMode.always
        prefixTextField.keyboardType = UIKeyboardType.numberPad
        mobileNumberView.addSubview(prefixTextField)
        self.mobilePrefixTextField = prefixTextField
        self.mobileTextField.leftView = mobileNumberView
        self.mobilePrefixTextField.delegate = self
        self.mobileTextField.leftViewMode = UITextField.ViewMode.always
    }
    
    func checkUserEnteredPin() {
        if let userBody = UserDefaults.standard.object(forKey: YonaConstants.nsUserDefaultsKeys.userBody) as? BodyDataDictionary {
            self.userFirstName = userBody["firstName"] as? String
            self.userLastName = userBody["lastName"] as? String
        }
        
        if UserDefaults.standard.bool(forKey: YonaConstants.nsUserDefaultsKeys.confirmPinFromSignUp) {
            if UserDefaults.standard.bool(forKey: YonaConstants.nsUserDefaultsKeys.adminOverride) {
                self.sendToAdminOverrideValidation()
            } else {
                self.sendToSMSValidation()
            }
        }
    }
        
    // Go Back To Previous VC
    @IBAction func back(_ sender: AnyObject) {
        weak var tracker = GAI.sharedInstance().defaultTracker
        tracker!.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action", action: "backFromSecondStep", label: "Back to first step in signup", value: nil).build() as? [AnyHashable: Any])
        self.navigationController?.popViewController(animated: true)
    }
    
    // Go To Another ViewController
    @IBAction func nextPressed(_ sender: UIButton) {
        weak var tracker = GAI.sharedInstance().defaultTracker
        tracker!.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action", action: "nextPressedAfterSignupSecond", label: "Step 2 finished, next step in sign up", value: nil).build() as? [AnyHashable: Any])
        var number = ""
        if let mobilenum = mobileTextField.text {
            if let prefix = mobilePrefixTextField.text {
                number = "+" + prefix + mobilenum
            }
            let trimmedString = number.removeWhitespace().removeBrackets()
            if !trimmedString.isValidMobileNumber(){
                self.displayAlertMessage("", alertDescription: "Please input valid Phone number.")
            } else if self.nicknameTextField.text!.count == 0 {
                self.displayAlertMessage("", alertDescription: "Please input Nickname.")
            } else {
                Loader.Show()
                let body = ["firstName": userFirstName!, "lastName": userLastName!, "mobileNumber": trimmedString, "nickname": nicknameTextField.text ?? ""]
                UserDefaults.standard.set(body, forKey: YonaConstants.nsUserDefaultsKeys.userBody)
                KeychainManager.sharedInstance.clearKeyChain()
                UserRequestManager.sharedInstance.postUser(body as BodyDataDictionary, confirmCode: nil, onCompletion: { (success, message, code, user) in
                    Loader.Hide()
                    if success {
                        self.sendToSMSValidation()
                    } //if the user already exists asks to override
                    else if code == YonaConstants.serverCodes.errorUserExists || code == YonaConstants.serverCodes.errorAddBuddyUserExists {
                        self.showUserOverrideAlert(formattedMobileNumber: trimmedString, body: body)
                    } else {
                        if let alertMessage = message, let code = code {
                            self.displayAlertMessage(code, alertDescription: alertMessage)
                        }
                    }
                })
            }
        }
    }
    
    func showUserOverrideAlert(formattedMobileNumber:String, body:Dictionary<String, String>) {
        //alert the user ask if they want to override their account, if ok send back to SMS screen
        let localizedString = NSLocalizedString("user-override", comment: "")
        let title = NSString(format: localizedString as NSString, String(formattedMobileNumber))
        self.displayAlertOption(title as String, cancelButton: true, alertDescription: "", onCompletion: { (buttonPressed) in
            switch buttonPressed{
            case alertButtonType.ok:
                self.handleOkButtonAction(body: body)
            case alertButtonType.cancel:
                break
                //do nothing or send back to start of signup?
            }
        })
    }
    
    func handleOkButtonAction(body:Dictionary<String, String>) {
        AdminRequestManager.sharedInstance.adminRequestOverride(body["mobileNumber"]) { (success, message, code) in
            if success { //if success then the user is sent confirmation code, they are taken to this screen, get an confirmation code in text message must enter it
                UserDefaults.standard.set(body, forKey: YonaConstants.nsUserDefaultsKeys.userBody)
                UserDefaults.standard.set(true, forKey: YonaConstants.nsUserDefaultsKeys.adminOverride)
                self.sendToAdminOverrideValidation()
            } else {
                if let message = message,
                    let code = code {
                    self.displayAlertMessage(code, alertDescription: message)
                }
            }
        }
    }
    
    func sendToSMSValidation(){
        //Update flag
        setViewControllerToDisplay(ViewControllerTypeString.signUp, key: YonaConstants.nsUserDefaultsKeys.screenToDisplay)
        // update some UI
        if let smsValidation = R.storyboard.login.confirmationCodeValidationViewController(()) {
            UserDefaults.standard.set(true, forKey: YonaConstants.nsUserDefaultsKeys.confirmPinFromSignUp)
            self.navigationController?.pushViewController(smsValidation, animated: false)
        }
    }
    
    func sendToAdminOverrideValidation(){
        //Update flag
        setViewControllerToDisplay(ViewControllerTypeString.signUp, key: YonaConstants.nsUserDefaultsKeys.screenToDisplay)
        // update some UI
        if let adminOverrideVC = R.storyboard.login.adminOverrideValidationViewController(()) {
            UserDefaults.standard.set(true, forKey: YonaConstants.nsUserDefaultsKeys.confirmPinFromSignUp)
            self.navigationController?.pushViewController(adminOverrideVC, animated: false)
        }
    }
}

extension SignUpSecondStepViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == mobileTextField {
            IQKeyboardManager.shared.enableAutoToolbar = true
        } else {
            IQKeyboardManager.shared.enableAutoToolbar = false
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == mobileTextField) {
            nicknameTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField == mobileTextField) {
            if ((previousRange?.location >= range.location) ) {
                if (textField.text?.utf16.count ?? 0) + string.utf16.count - range.length == YonaConstants.mobilePhoneSpace.mobileFirstSpace || (textField.text?.utf16.count ?? 0) + string.utf16.count - range.length == YonaConstants.mobilePhoneSpace.mobileMiddleSpace {
                    textField.text = String(textField.text!.dropLast())
                    textField.text = String(textField.text!.dropLast())
                }
            } else  {
                if (textField.text?.utf16.count ?? 0) + string.utf16.count - range.length ==  YonaConstants.mobilePhoneSpace.mobileFirstSpace || (textField.text?.utf16.count ?? 0) + string.utf16.count - range.length == YonaConstants.mobilePhoneSpace.mobileMiddleSpace {
                    let space = " "
                    
                    textField.text = "\(textField.text!) \(space)"
                }            }
            previousRange = range
            //The size limitation setting is only for Netherland's number, As it was already implemented.. No limit for another country
            if (mobilePrefixTextField.text == nederlandPhonePrefix) {
                return (textField.text?.utf16.count ?? 0) + string.utf16.count - range.length <= YonaConstants.mobilePhoneSpace.mobileLastSpace
            } else {
                return true
            }
        } else if (textField == mobilePrefixTextField) {
            return (textField.text?.utf16.count ?? 0) + string.utf16.count - range.length <= YonaConstants.mobilePhoneLength.prefix
        }
        return true
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
}

private extension Selector {
    static let dismissKeyboard = #selector(SignUpSecondStepViewController.dismissKeyboard)
    
    static let back = #selector(SignUpSecondStepViewController.back(_:))
    
}
