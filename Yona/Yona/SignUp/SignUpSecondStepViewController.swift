
//
//  SignUpSecondStepViewController.swift
//  Yona
//
//  Created by Chandan on 31/03/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

class SignUpSecondStepViewController: UIViewController, UITextFieldDelegate,UIScrollViewDelegate {
    var activeField : UITextField?
    var colorX : UIColor = UIColor.yiWhiteColor()
    var previousRange: NSRange!
    
    @IBOutlet var mobileTextField: UITextField!
    @IBOutlet var nicknameTextField: UITextField!
    @IBOutlet var infoLabel: UILabel!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var previousButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Text Delegates
//        self.previousRange!.location = 0
        if var label = self.previousRange{
            label.length = 1
        }
//        self.previousRange?.length = 1
        self.mobileTextField.delegate = self
        self.nicknameTextField.delegate = self
        self.mobileTextField.placeholder = NSLocalizedString("signup.user.mobileNumber", comment: "").uppercaseString
        self.nicknameTextField.placeholder = NSLocalizedString("signup.user.nickname", comment: "").uppercaseString
        
        self.infoLabel.text = NSLocalizedString("signup.user.infoText", comment: "").uppercaseString
        
        self.nextButton.setTitle(NSLocalizedString("signup.button.next", comment: "").uppercaseString, forState: UIControlState.Normal)
        self.previousButton.setTitle(NSLocalizedString("signup.button.previous", comment: "").uppercaseString, forState: UIControlState.Normal)
        
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignUpSecondStepViewController.DismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        //Nav bar Back button.
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(image: UIImage(named: "icnBack")!, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(SignUpSecondStepViewController.back(_:)))
        self.navigationItem.leftBarButtonItem = newBackButton;
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        
        
        // Adding right mode image to text fields
        let mobileImage = UIImageView(image: UIImage(named: "icnMobile"))
        mobileImage.frame = CGRectMake(0.0, 0.0, mobileImage.image!.size.width+10.0, mobileImage.image!.size.height);
        mobileImage.contentMode = UIViewContentMode.Center
        self.mobileTextField.rightView = mobileImage;
        self.mobileTextField.rightViewMode = UITextFieldViewMode.Always
        
        let nicknameImage = UIImageView(image: UIImage(named: "icnNickname"))
        nicknameImage.frame = CGRectMake(0.0, 0.0, nicknameImage.image!.size.width+10.0, nicknameImage.image!.size.height);
        mobileImage.contentMode = UIViewContentMode.Center
        self.nicknameTextField.rightView = nicknameImage;
        self.nicknameTextField.rightViewMode = UITextFieldViewMode.Always
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //keyboard functions
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(SignUpSecondStepViewController.keyboardWasShown(_:)), name: UIKeyboardDidShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(SignUpSecondStepViewController.keyboardWillBeHidden(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // UIAlertView Alert
    func displayAlertMessage(alertTitle:String, alertDescription:String) -> Void {
        // hide activityIndicator view and display alert message
        //        self.activityIndicatorView.hidden = true
        let errorAlert = UIAlertView(title:alertTitle, message:alertDescription, delegate:nil, cancelButtonTitle:"OK")
        errorAlert.show()
    }
    
    
    // Go Back To Previous VC
    @IBAction func back(sender: AnyObject) {
        if((self.presentingViewController) != nil){
            self.dismissViewControllerAnimated(true, completion: nil)
            NSLog("back")
        }
    }
    
    
    // Go To Another ViewController
        @IBAction func nextPressed(sender: UIButton) {

//            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("SignUpViewController2")
//
//            self.presentViewController(controller, animated: true, completion: nil)
        }
    
    
    // Text Field Return Resign First Responder
    func textFieldShouldReturn(textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
        if (textField == mobileTextField) {
            nicknameTextField.becomeFirstResponder()

        } else {
          textField.resignFirstResponder()
        }
//        firstnameTextField.resignFirstResponder()
//        lastnameTextField.becomeFirstResponder()
        return true
    }
    
    
   
    //MARK: - Add TextFieldInput Navigation Arrows above Keyboard
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        let keyboardToolBar: UIToolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 10))
        let keyboardBarButtonItems = [
            UIBarButtonItem(title: "previous", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(SignUpSecondStepViewController.previousTextField)),
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "next", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(SignUpSecondStepViewController.nextTextField))
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
        if (activeField == mobileTextField) {
            
            mobileTextField.text = "+316 "
//            textRange =  mobileTextField.characterRangeAtPoint(<#T##point: CGPoint##CGPoint#>)
        }
        self.mobileTextField.delegate = self
        self.nicknameTextField.delegate = self
        
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Fade)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        activeField = nil
        
    }
    
    //MARK: -  copied from Apple developer forums - need to understand, bounced :(
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    print((range.location))
//        if ((previousRange?.location >= range.location) ) {
//            print("back")
//        }else  {
//            print("next")
//        }
//        previousRange = range
        if (textField == mobileTextField) {
            if ((previousRange?.location >= range.location) ) {
                if (textField.text?.utf16.count ?? 0) + string.utf16.count - range.length == 9 || (textField.text?.utf16.count ?? 0) + string.utf16.count - range.length == 14 {
                    textField.text = String(textField.text!.characters.dropLast())
                    textField.text = String(textField.text!.characters.dropLast())
//                    textField.text = "\(textField.text!) \(space)"
                }
            
            }else  {
                if (textField.text?.utf16.count ?? 0) + string.utf16.count - range.length == 9 || (textField.text?.utf16.count ?? 0) + string.utf16.count - range.length == 14 {
                    let space = " "
                    
                    textField.text = "\(textField.text!) \(space)"
                }            }
            previousRange = range
            
            if (textField.text?.utf16.count ?? 0) + string.utf16.count - range.length <= 5 {
                textField.text = "+315 "
            }
            
                return (textField.text?.utf16.count ?? 0) + string.utf16.count - range.length <= 18
        }
        return true
    }
    func nextTextField() {
        mobileTextField.resignFirstResponder()
        nicknameTextField.becomeFirstResponder()
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
        
        self.scrollView.setContentOffset(CGPointMake(0, keyboardInset), animated: true)
        
    }
    
    
    func keyboardWillBeHidden(notification: NSNotification) {
        self.scrollView.setContentOffset(CGPointMake(0, 0), animated: true)
        
    }
    
    //Calls this function when the tap is recognized.
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
}
