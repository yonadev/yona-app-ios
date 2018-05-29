
//
//  AddDeviceViewController.swift
//  Yona
//
//  Created by Chandan on 06/04/16.
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


class AddDeviceViewController: BaseViewController, UIScrollViewDelegate {
    var activeField : UITextField?
    var colorX : UIColor = UIColor.yiWhiteColor()
    var previousRange: NSRange!
    
    fileprivate let nederlandPhonePrefix = "31"
    
    @IBOutlet var mobileTextField: UITextField!
    fileprivate var mobilePrefixTextField: UITextField!
    @IBOutlet var passcodeTextField: UITextField!
    @IBOutlet var infoLabel: UILabel!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var loginButton: UIButton!
    
    @IBOutlet var gradientView: GradientView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "AddDeviceViewController")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as! [AnyHashable: Any])
    }
    
    fileprivate func setupUI() {
        // Text Delegates
        if var label = previousRange {
            label.length = 1
        }
        
        mobileTextField.delegate = self
        passcodeTextField.delegate = self
        
        // Adding right mode image to text fields
        let mobileImage = UIImageView(image: R.image.icnMobile())
        mobileImage.frame = CGRect(x: 0.0, y: 0.0, width: mobileImage.image!.size.width+10.0, height: mobileImage.image!.size.height);
        mobileImage.contentMode = UIViewContentMode.center
        self.mobileTextField.rightView = mobileImage;
        self.mobileTextField.rightViewMode = UITextFieldViewMode.always
        
        let passcodeImage = UIImageView(image: R.image.icnName())
        passcodeImage.frame = CGRect(x: 0.0, y: 0.0, width: passcodeImage.image!.size.width+10.0, height: passcodeImage.image!.size.height);
        mobileImage.contentMode = UIViewContentMode.center
        self.passcodeTextField.rightView = passcodeImage;
        self.passcodeTextField.rightViewMode = UITextFieldViewMode.always
        
        let mobileNumberView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        
        let plusLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        plusLabel.font = UIFont(name: "SFUIDisplay-Regular", size: 11)
        plusLabel.textColor = UIColor.yiBlackColor()
        plusLabel.contentMode = UIViewContentMode.center
        plusLabel.textAlignment = NSTextAlignment.center
        plusLabel.text = "+"
        
        let prefixTextField = UITextField(frame: CGRect(x: 10, y: 0, width: 40, height: 50))
        prefixTextField.font = UIFont(name: "SFUIDisplay-Regular", size: 11)
        prefixTextField.textColor = UIColor.yiBlackColor()
        prefixTextField.contentMode = UIViewContentMode.left
        prefixTextField.textAlignment = NSTextAlignment.left
        prefixTextField.text = nederlandPhonePrefix
        prefixTextField.leftView = plusLabel
        prefixTextField.leftViewMode = UITextFieldViewMode.always
        prefixTextField.keyboardType = UIKeyboardType.numberPad
        mobileNumberView.addSubview(prefixTextField)
        self.mobilePrefixTextField = prefixTextField
        self.mobileTextField.leftView = mobileNumberView
        self.mobilePrefixTextField.delegate = self
        self.mobileTextField.leftViewMode = UITextFieldViewMode.always
    }
    
    // Go To Another ViewController
    @IBAction func loginPressed(_ sender: UIButton) {
        weak var tracker = GAI.sharedInstance().defaultTracker
        tracker!.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action", action: "loginPressed", label: "AddDeviceViewController login pressed", value: nil).build() as! [AnyHashable: Any])
        
        var number = ""
        if let mobilenum = mobileTextField.text {
            if let prefix = mobilePrefixTextField.text {
                number = "+" + prefix + mobilenum
            }
            
            let trimmedWhiteSpaceString = number.removeWhitespace()
            let trimmedString = trimmedWhiteSpaceString.removeBrackets()
            
            if trimmedString.validateMobileNumber() == false {
                let localizedString = NSLocalizedString("adddevice.user.InputValidCode", comment: "")
                self.displayAlertMessage("", alertDescription:
                    localizedString)
            } else if self.passcodeTextField.text!.characters.count == 0 {
                let localizedString = NSLocalizedString("adddevice.user.InputPassCode", comment: "")
                self.displayAlertMessage("", alertDescription:
                    localizedString)
                
            } else {
                NewDeviceRequestManager.sharedInstance.getNewDevice(self.passcodeTextField.text!, mobileNumber: trimmedString) { (success, message, server, user) in
                    if success {
                        //Update flag
                        UserRequestManager.sharedInstance.getUser(GetUserRequest.allowed , onCompletion: { (success, bool, code, user) in
                            setViewControllerToDisplay(ViewControllerTypeString.passcode, key: YonaConstants.nsUserDefaultsKeys.screenToDisplay)
                            if let passcode = R.storyboard.login.passcodeViewController(()) {
                                self.navigationController?.pushViewController(passcode, animated: false)
                            }
                        })
                    } else {
                        self.displayAlertMessage("", alertDescription: message!)
                    }
                }
            }
        }
    }


}

extension AddDeviceViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == mobileTextField {
            IQKeyboardManager.shared.enableAutoToolbar = true
        } else {
            IQKeyboardManager.shared.enableAutoToolbar = false
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == mobileTextField) {
            passcodeTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
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
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
}


private extension Selector {
    static let dismissKeyboard = #selector(AddDeviceViewController.dismissKeyboard)
}
