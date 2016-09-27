
//
//  AddDeviceViewController.swift
//  Yona
//
//  Created by Chandan on 06/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

class AddDeviceViewController: BaseViewController, UIScrollViewDelegate {
    var activeField : UITextField?
    var colorX : UIColor = UIColor.yiWhiteColor()
    var previousRange: NSRange!
    
    private let nederlandPhonePrefix = "+31 (0) "
    
    @IBOutlet var mobileTextField: UITextField!
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
    
    override func viewWillAppear(animated: Bool) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "AddDeviceViewController")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    private func setupUI() {
        // Text Delegates
        if var label = previousRange {
            label.length = 1
        }
        
        mobileTextField.delegate = self
        passcodeTextField.delegate = self
        
        // Adding right mode image to text fields
        let mobileImage = UIImageView(image: R.image.icnMobile)
        mobileImage.frame = CGRectMake(0.0, 0.0, mobileImage.image!.size.width+10.0, mobileImage.image!.size.height);
        mobileImage.contentMode = UIViewContentMode.Center
        self.mobileTextField.rightView = mobileImage;
        self.mobileTextField.rightViewMode = UITextFieldViewMode.Always
        
        let passcodeImage = UIImageView(image: R.image.icnName)
        passcodeImage.frame = CGRectMake(0.0, 0.0, passcodeImage.image!.size.width+10.0, passcodeImage.image!.size.height);
        mobileImage.contentMode = UIViewContentMode.Center
        self.passcodeTextField.rightView = passcodeImage;
        self.passcodeTextField.rightViewMode = UITextFieldViewMode.Always
        
        let label = UILabel(frame: CGRectMake(0, 0, 50, 50))
        label.font = UIFont(name: "SFUIDisplay-Regular", size: 11)
        label.textColor = UIColor.yiBlackColor()
        label.contentMode = UIViewContentMode.Center
        label.textAlignment = NSTextAlignment.Center
        label.text = nederlandPhonePrefix
        self.mobileTextField.leftView = label
        self.mobileTextField.leftViewMode = UITextFieldViewMode.Always
    }
    
    // Go To Another ViewController
    @IBAction func loginPressed(sender: UIButton) {
        weak var tracker = GAI.sharedInstance().defaultTracker
        tracker!.send(GAIDictionaryBuilder.createEventWithCategory("ui_action", action: "loginPressed", label: "AddDeviceViewController login pressed", value: nil) as AnyObject as! [NSObject : AnyObject])
        
        var number = ""
        if let mobilenum = mobileTextField.text {
            number = (nederlandPhonePrefix) + mobilenum
            
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
                            if let passcode = R.storyboard.login.passcodeViewController {
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
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField == mobileTextField {
            IQKeyboardManager.sharedManager().enableAutoToolbar = true
        } else {
            IQKeyboardManager.sharedManager().enableAutoToolbar = false
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == mobileTextField) {
            passcodeTextField.becomeFirstResponder()
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
            
            return (textField.text?.utf16.count ?? 0) + string.utf16.count - range.length <= YonaConstants.mobilePhoneSpace.mobileLastSpace
        }
        return true
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard(){
        view.endEditing(true)
    }
}


private extension Selector {
    static let dismissKeyboard = #selector(AddDeviceViewController.dismissKeyboard)
}
