
//
//  SignUpSecondStepViewController.swift
//  Yona
//
//  Created by Chandan on 31/03/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

class SignUpSecondStepViewController: BaseViewController,UIScrollViewDelegate {
    var activeField : UITextField?
    var colorX : UIColor = UIColor.yiWhiteColor()
    var previousRange: NSRange!
    
    var userFirstName: String?
    var userLastName: String?
        
    private let nederlandPhonePrefix = "31"
    
    @IBOutlet var mobileTextField: UITextField!
    private var mobilePrefixTextField: UITextField!
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
    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "SignUpSecondStepViewController")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
        
        IQKeyboardManager.sharedManager().enable = false
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHiden(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.sharedManager().enable = true
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    
    func keyboardWillShow(notification: NSNotification)
    {
        self.topViewHeightConstraint.constant = 96;
        let animationDiration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey]!.doubleValue!;
        let animationCurve = UIViewAnimationCurve.init(rawValue: Int(notification.userInfo![UIKeyboardAnimationCurveUserInfoKey]!.intValue!))!
        UIView.animateWithDuration(animationDiration) {
            UIView.setAnimationCurve(animationCurve)
            self.view.layoutIfNeeded()
        }
        
        
        
    }
    func keyboardWillHiden(notification: NSNotification)
    {
        self.topViewHeightConstraint.constant = 210;
        let animationDiration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey]!.doubleValue!;
        let animationCurve = UIViewAnimationCurve.init(rawValue: Int(notification.userInfo![UIKeyboardAnimationCurveUserInfoKey]!.intValue!))!
        UIView.animateWithDuration(animationDiration) {
            UIView.setAnimationCurve(animationCurve)
            self.view.layoutIfNeeded()
        }
    }
    
    private func setupUI() {
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
        let mobileImage = UIImageView(image: R.image.icnMobile)
        mobileImage.frame = CGRectMake(0.0, 0.0, mobileImage.image!.size.width+10.0, mobileImage.image!.size.height);
        mobileImage.contentMode = UIViewContentMode.Center
        self.mobileTextField.rightView = mobileImage;
        self.mobileTextField.rightViewMode = UITextFieldViewMode.Always
        
        let nicknameImage = UIImageView(image: R.image.icnNickname)
        nicknameImage.frame = CGRectMake(0.0, 0.0, nicknameImage.image!.size.width, nicknameImage.image!.size.height);
        mobileImage.contentMode = UIViewContentMode.Center
        self.nicknameTextField.rightView = nicknameImage;
        self.nicknameTextField.rightViewMode = UITextFieldViewMode.Always
        
        let mobileNumberView = UIView(frame: CGRectMake(0, 0, 50, 50))
        
        let plusLabel = UILabel(frame: CGRectMake(0, 0, 10, 50))
        plusLabel.font = UIFont(name: "SFUIDisplay-Regular", size: 11)
        plusLabel.textColor = UIColor.yiBlackColor()
        plusLabel.contentMode = UIViewContentMode.Center
        plusLabel.textAlignment = NSTextAlignment.Center
        plusLabel.text = "+"
        
        let prefixTextField = UITextField(frame: CGRectMake(10, 0, 40, 50))
        prefixTextField.font = UIFont(name: "SFUIDisplay-Regular", size: 11)
        prefixTextField.textColor = UIColor.yiBlackColor()
        prefixTextField.contentMode = UIViewContentMode.Left
        prefixTextField.textAlignment = NSTextAlignment.Left
        prefixTextField.text = nederlandPhonePrefix
        prefixTextField.leftView = plusLabel
        prefixTextField.leftViewMode = UITextFieldViewMode.Always
        prefixTextField.keyboardType = UIKeyboardType.NumberPad
        mobileNumberView.addSubview(prefixTextField)
        self.mobilePrefixTextField = prefixTextField
        self.mobileTextField.leftView = mobileNumberView
        self.mobilePrefixTextField.delegate = self
        self.mobileTextField.leftViewMode = UITextFieldViewMode.Always
    }
        
    // Go Back To Previous VC
    @IBAction func back(sender: AnyObject) {
        weak var tracker = GAI.sharedInstance().defaultTracker
        tracker!.send(GAIDictionaryBuilder.createEventWithCategory("ui_action", action: "backFromSecondStep", label: "Back to first step in signup", value: nil).build() as [NSObject : AnyObject])
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    // Go To Another ViewController
    @IBAction func nextPressed(sender: UIButton) {
        weak var tracker = GAI.sharedInstance().defaultTracker
        tracker!.send(GAIDictionaryBuilder.createEventWithCategory("ui_action", action: "nextPressedAfterSignupSecond", label: "Step 2 finished, next step in sign up", value: nil).build() as [NSObject : AnyObject])
        
        var number = ""
        if let mobilenum = mobileTextField.text {
            if let prefix = mobilePrefixTextField.text {
                number = "+" + prefix + mobilenum
            }
            
            let trimmedWhiteSpaceString = number.removeWhitespace()
            let trimmedString = trimmedWhiteSpaceString.removeBrackets()
            
            if trimmedString.validateMobileNumber() == false {
                self.displayAlertMessage("", alertDescription:
                    "Please input valid Phone number.")
            } else if self.nicknameTextField.text!.characters.count == 0 {
                self.displayAlertMessage("", alertDescription:
                    "Please input Nickname.")
                
            } else {
                Loader.Show()
                let body =
                    ["firstName": userFirstName!,
                     "lastName": userLastName!,
                     "mobileNumber": trimmedString,
                     "nickname": nicknameTextField.text ?? ""]
                
                UserRequestManager.sharedInstance.postUser(body, confirmCode: nil, onCompletion: { (success, message, code, user) in
                    if success {
                        self.sendToSMSValidation()
                    } //if the user already exists asks to override
                    else if code == YonaConstants.serverCodes.errorUserExists || code == YonaConstants.serverCodes.errorAddBuddyUserExists {
                        Loader.Hide()
                        //alert the user ask if they want to override their account, if ok send back to SMS screen
                        number = (self.nederlandPhonePrefix) + mobilenum
                        
                        let trimmedWhiteSpaceString = number.removeWhitespace()
                        let trimmedString = trimmedWhiteSpaceString.removeBrackets()
                        
                        let localizedString = NSLocalizedString("user-override", comment: "")
                        let title = NSString(format: localizedString, String(trimmedString))
                        
                        
                        self.displayAlertOption(title as String, cancelButton: true, alertDescription: "", onCompletion: { (buttonPressed) in
                            switch buttonPressed{
                            case alertButtonType.OK:
                                AdminRequestManager.sharedInstance.adminRequestOverride(body["mobileNumber"]) { (success, message, code) in
                                    //if success then the user is sent OTP code, they are taken to this screen, get an OTP in text message must enter it
                                    if success {
                                        NSUserDefaults.standardUserDefaults().setObject(body, forKey: YonaConstants.nsUserDefaultsKeys.userToOverride)
                                        NSUserDefaults.standardUserDefaults().setBool(true, forKey: YonaConstants.nsUserDefaultsKeys.adminOverride)
                                        self.sendToAdminOverrideValidation()
                                    } else {
                                        if let message = message,
                                            let code = code {
                                            self.displayAlertMessage(code, alertDescription: message)
                                        }
                                    }
                                }
                                
                            case alertButtonType.cancel:
                                break
                                //do nothing or send back to start of signup?
                            }
                        })
                        
                    } else {
                        Loader.Hide()
                        if let alertMessage = message,
                            let code = code {
                            self.displayAlertMessage(code, alertDescription: alertMessage)
                        }
                    }
                })
            }
        }
    }
    
    func sendToSMSValidation(){
        //Update flag
        setViewControllerToDisplay(ViewControllerTypeString.confirmMobileValidation, key: YonaConstants.nsUserDefaultsKeys.screenToDisplay)
        // update some UI
        Loader.Hide()
        if let smsValidation = R.storyboard.login.confirmPinValidationViewController {
            self.navigationController?.pushViewController(smsValidation, animated: false)
        }
    }
    
    func sendToAdminOverrideValidation(){
        //Update flag
        setViewControllerToDisplay(ViewControllerTypeString.adminOverrideValidation, key: YonaConstants.nsUserDefaultsKeys.screenToDisplay)
        // update some UI
        Loader.Hide()
        if let adminOverrideVC = R.storyboard.login.adminOverrideValidationViewController {
            self.navigationController?.pushViewController(adminOverrideVC, animated: false)
        }
        
    }
}

extension SignUpSecondStepViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField == mobileTextField {
            IQKeyboardManager.sharedManager().enableAutoToolbar = true
        } else {
            IQKeyboardManager.sharedManager().enableAutoToolbar = false
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == mobileTextField) {
            nicknameTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if (textField == mobileTextField) {
            if ((previousRange?.location >= range.location) ) {
                if (textField.text?.utf16.count ?? 0) + string.utf16.count - range.length == YonaConstants.mobilePhoneSpace.mobileFirstSpace || (textField.text?.utf16.count ?? 0) + string.utf16.count - range.length == YonaConstants.mobilePhoneSpace.mobileMiddleSpace {
                    textField.text = String(textField.text!.characters.dropLast())
                    textField.text = String(textField.text!.characters.dropLast())
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
    func dismissKeyboard(){
        view.endEditing(true)
    }
}

private extension Selector {
    static let dismissKeyboard = #selector(SignUpSecondStepViewController.dismissKeyboard)
    
    static let back = #selector(SignUpSecondStepViewController.back(_:))
    
}
