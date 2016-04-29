
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
        
        //        keyboard functions
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SignUpSecondStepViewController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SignUpSecondStepViewController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil)
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
    @IBAction func nextPressed(sender: UIButton) {
        var number = ""
        if let mobilenum = mobileTextField.text {
            number = (nederlandPhonePrefix) + mobilenum
            
            let trimmedWhiteSpaceString = number.removeWhitespace()
            let trimmedString = trimmedWhiteSpaceString.removeBrackets()
            
            if trimmedString.validateMobileNumber() == false {
                self.displayAlertMessage("", alertDescription:
                    "Please input valid Phone number.")
            } else if self.nicknameTextField.text!.characters.count == 0 {
                self.displayAlertMessage("", alertDescription:
                    "Please input Nickname.")
                
            } else {
                Loader.Show(delegate: self)
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
                            Loader.Hide(self)
                            if let smsValidation = R.storyboard.sMSValidation.sMSValidationViewController {
                                self.navigationController?.pushViewController(smsValidation, animated: false)
                            }
                        }
                    } else {
                        dispatch_async(dispatch_get_main_queue()) {
                            Loader.Hide(self)
                            self.displayAlertMessage(message!, alertDescription: "")
                        }
                    }
                })
            }
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
    
    //MARK: -  copied from Apple developer forums - need to understand, bounced :(
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
    
    func keyboardWillShow(notification:NSNotification){
        guard let userInfo = notification.userInfo else { return }
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        keyboardFrame = self.view.convertRect(keyboardFrame, fromView: nil)
        self.scrollView.contentInset.top = self.scrollView.contentInset.top 
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        self.scrollView.contentInset = contentInset
    }
    
    func keyboardWillHide(notification:NSNotification){
        
        self.scrollView.setContentOffset(CGPointZero, animated: true)
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard(){
        view.endEditing(true)
    }
}

private extension Selector {
    static let keyboardWasShown = #selector(SignUpSecondStepViewController.keyboardWillShow(_:))
    
    static let keyboardWillBeHidden = #selector(SignUpSecondStepViewController.keyboardWillHide(_:))
    
    static let dismissKeyboard = #selector(SignUpSecondStepViewController.dismissKeyboard)
    
    static let back = #selector(SignUpSecondStepViewController.back(_:))
    
}
