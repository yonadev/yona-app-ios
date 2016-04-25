
//
//  SignUpSecondStepViewController.swift
//  Yona
//
//  Created by Chandan on 31/03/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

class SignUpSecondStepViewController: UIViewController,UIScrollViewDelegate {
    var activeField : UITextField?
    var colorX : UIColor = UIColor.yiWhiteColor()
    var previousRange: NSRange!
    
    var userFirstName: String?
    var userLastName: String?
    
    @IBOutlet var gradientView: GradientView!
    
    private let nederlandPhonePrefix = "+31 (0) "
    
    @IBOutlet var mobileTextField: UITextField!
    @IBOutlet var nicknameTextField: UITextField!
    @IBOutlet var infoLabel: UILabel!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var previousButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dispatch_async(dispatch_get_main_queue(), {
            self.gradientView.colors = [UIColor.yiGrapeTwoColor(), UIColor.yiGrapeTwoColor()]
        })
        setupUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //keyboard functions
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: Selector.keyboardWasShown, name: UIKeyboardDidShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: Selector.keyboardWillBeHidden, name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    private func setupUI() {
        // Text Delegates
        if var label = previousRange {
            label.length = 1
        }
        
        mobileTextField.delegate = self
        nicknameTextField.delegate = self
        mobileTextField.placeholder = NSLocalizedString("signup.user.mobileNumber", comment: "").uppercaseString
        nicknameTextField.placeholder = NSLocalizedString("signup.user.nickname", comment: "").uppercaseString

        mobileTextField.text = nederlandPhonePrefix
        
        infoLabel.text = NSLocalizedString("signup.user.infoText", comment: "")
        
        self.nextButton.setTitle(NSLocalizedString("signup.button.next", comment: "").uppercaseString, forState: UIControlState.Normal)
        self.previousButton.setTitle(NSLocalizedString("signup.button.previous", comment: "").uppercaseString, forState: UIControlState.Normal)
        
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector.dismissKeyboard)
        self.view.addGestureRecognizer(tap)
        
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
        
        let nicknameImage = UIImageView(image: R.image.icnNickname)
        nicknameImage.frame = CGRectMake(0.0, 0.0, nicknameImage.image!.size.width, nicknameImage.image!.size.height);
        mobileImage.contentMode = UIViewContentMode.Center
        self.nicknameTextField.rightView = nicknameImage;
        self.nicknameTextField.rightViewMode = UITextFieldViewMode.Always
    }
    
    // Go Back To Previous VC
    @IBAction func back(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    // Go To Another ViewController
    @IBAction func nextPressed(sender: UIButton) {
        guard let trimmedWhiteSpaceString = mobileTextField.text?.removeWhitespace() else { return }
        let trimmedString = trimmedWhiteSpaceString.removeBrackets()
        
        if trimmedString.validateMobileNumber() == false {
            self.displayAlertMessage("", alertDescription:
                "Please input valid Phone number.")
        } else if self.nicknameTextField.text!.characters.count == 0 {
            self.displayAlertMessage("", alertDescription:
                "Please input Nickname.")
            
        } else {
            let body =
                ["firstName": userFirstName!,
                 "lastName": userLastName!,
                 "mobileNumber": trimmedString,
                 "nickname": nicknameTextField.text ?? ""]
            
            APIServiceManager.sharedInstance.postUser(body, onCompletion: { (success, message, code, user) in
                if success {
                    //Update flag
                    setViewControllerToDisplay("SMSValidation", key: YonaConstants.nsUserDefaultsKeys.screenToDisplay)
                    dispatch_async(dispatch_get_main_queue()) {
                        // update some UI
                        if let smsValidation = R.storyboard.sMSValidation.sMSValidationViewController {
                            self.navigationController?.pushViewController(smsValidation, animated: false)
                        }
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.displayAlertMessage(message!, alertDescription: "")
                    }
                }
            })
        }
    }
}

extension SignUpSecondStepViewController: UITextFieldDelegate {
    // Text Field Return Resign First Responder
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == mobileTextField) {
            nicknameTextField.becomeFirstResponder()
        } else {
          textField.resignFirstResponder()
        }
        return true
    }
    
    
   
    //MARK: - Add TextFieldInput Navigation Arrows above Keyboard
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        let keyboardToolBar: UIToolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 10))
        let keyboardBarButtonItems = [
            UIBarButtonItem(title: "previous", style: UIBarButtonItemStyle.Plain, target: self, action: Selector.previousTextField),
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "next", style: UIBarButtonItemStyle.Plain, target: self, action: Selector.nextTextField)
        ]
        
        keyboardToolBar.setItems(keyboardBarButtonItems, animated: false)
        keyboardToolBar.tintColor = colorX
        keyboardToolBar.barStyle = UIBarStyle.Black
        keyboardToolBar.sizeToFit()
        textField.inputAccessoryView = keyboardToolBar
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        activeField = textField
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Fade)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        activeField = nil
        
    }
    
    //MARK: -  copied from Apple developer forums - need to understand, bounced :(
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if (textField == mobileTextField) {
            if ((previousRange?.location >= range.location) ) {
                if (textField.text?.utf16.count ?? 0) + string.utf16.count - range.length == 12 || (textField.text?.utf16.count ?? 0) + string.utf16.count - range.length == 17 {
                    textField.text = String(textField.text!.characters.dropLast())
                    textField.text = String(textField.text!.characters.dropLast())
                }
            } else  {
                if (textField.text?.utf16.count ?? 0) + string.utf16.count - range.length == 12 || (textField.text?.utf16.count ?? 0) + string.utf16.count - range.length == 17 {
                    let space = " "
                    
                    textField.text = "\(textField.text!) \(space)"
                }            }
            previousRange = range
            
            if (textField.text?.utf16.count ?? 0) + string.utf16.count - range.length <= 8 {
                textField.text = nederlandPhonePrefix
            }
            
            return (textField.text?.utf16.count ?? 0) + string.utf16.count - range.length <= 21
        }
        return true
    }
    
    func nextTextField() {
        if nicknameTextField.isFirstResponder() {
            mobileTextField.resignFirstResponder()
            nicknameTextField.resignFirstResponder()
        } else {
            mobileTextField.resignFirstResponder()
            nicknameTextField.becomeFirstResponder()
        }
    }
    
    func previousTextField() {
        nicknameTextField.resignFirstResponder()
        mobileTextField.becomeFirstResponder()
    }
    
    
    //MARK: - Keyboard Functions
    func keyboardWasShown (notification: NSNotification) {
        let viewHeight = self.view.frame.size.height
        let info : NSDictionary = notification.userInfo!
        let keyboardSize: CGSize = info.objectForKey(UIKeyboardFrameBeginUserInfoKey)!.CGRectValue.size
        let keyboardInset = keyboardSize.height - viewHeight/3
        
        let  txtpos = (activeField?.frame.origin.y)! + (activeField?.frame.size.height)! + 260
        
        
        if (txtpos > (viewHeight-keyboardSize.height)) {
            scrollView.setContentOffset(CGPointMake(0, txtpos-(viewHeight-keyboardSize.height)), animated: true)
        } else {
            scrollView.setContentOffset(CGPointMake(0, keyboardInset), animated: true)
        }
    }
    
    
    func keyboardWillBeHidden(notification: NSNotification) {
        self.scrollView.setContentOffset(CGPointMake(0, 0), animated: true)
        
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
}

private extension Selector {
    static let keyboardWasShown = #selector(SignUpSecondStepViewController.keyboardWasShown(_:))
    
    static let keyboardWillBeHidden = #selector(SignUpSecondStepViewController.keyboardWillBeHidden(_:))
    
    static let dismissKeyboard = #selector(SignUpSecondStepViewController.dismissKeyboard)
    
    static let back = #selector(SignUpSecondStepViewController.back(_:))
    
    static let previousTextField = #selector(SignUpSecondStepViewController.previousTextField)
    
    static let nextTextField = #selector(SignUpSecondStepViewController.nextTextField)
}
