
//
//  AddDeviceViewController.swift
//  Yona
//
//  Created by Chandan on 06/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

class AddDeviceViewController: UIViewController,UIScrollViewDelegate {
    var activeField : UITextField?
    var colorX : UIColor = UIColor.yiWhiteColor()
    var previousRange: NSRange!
    
    private let nederlandPhonePrefix = "+316 "
    
    @IBOutlet var mobileTextField: UITextField!
    @IBOutlet var passcodeTextField: UITextField!
    @IBOutlet var infoLabel: UILabel!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var loginButton: UIButton!
    
    @IBOutlet var gradientView: GradientView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dispatch_async(dispatch_get_main_queue(), {
            self.gradientView.colors = [UIColor.yiGrapeTwoColor(), UIColor.yiGrapeTwoColor()]
        })
        setupUI()
    }
    
    private func setupUI() {
        // Text Delegates
        if var label = previousRange {
            label.length = 1
        }
        
        mobileTextField.delegate = self
        passcodeTextField.delegate = self
        
        //Nav bar Back button.
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(image: R.image.icnBack, style: UIBarButtonItemStyle.Plain, target: self, action: Selector.back)
        self.navigationItem.leftBarButtonItem = newBackButton;
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        
        
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
    
    // Go Back To Previous VC
    @IBAction func back(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    // Go To Another ViewController
    @IBAction func loginPressed(sender: UIButton) {
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
                        dispatch_async(dispatch_get_main_queue()) {
                            //Update flag
                            setViewControllerToDisplay("Passcode", key: YonaConstants.nsUserDefaultsKeys.screenToDisplay)
                            if let passcode = R.storyboard.passcode.passcodeStoryboard {
                                self.navigationController?.pushViewController(passcode, animated: false)
                            }
                        }
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
    static let back = #selector(AddDeviceViewController.back(_:))
    
    static let dismissKeyboard = #selector(AddDeviceViewController.dismissKeyboard)
}
