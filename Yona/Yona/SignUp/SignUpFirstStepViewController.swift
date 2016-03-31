
//
//  SignUpFirstStepViewController.swift
//  Yona
//
//  Created by Chandan on 29/03/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

class SignUpFirstStepViewController: UIViewController, UITextFieldDelegate,UIScrollViewDelegate {
    var activeField : UITextField?
    var colorX : UIColor = UIColor.yiWhiteColor()
    
    
    @IBOutlet var firstnameTextField: UITextField!
    @IBOutlet var lastnameTextField: UITextField!
    @IBOutlet var personalQuoteLabel: UILabel!
    @IBOutlet var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Text Delegates
        
        self.firstnameTextField.delegate = self
        self.lastnameTextField.delegate = self
        self.firstnameTextField.placeholder = NSLocalizedString("signup.user.firstname", comment: "").uppercaseString
        self.lastnameTextField.placeholder = NSLocalizedString("signup.user.lastname", comment: "").uppercaseString
        
        //keyboard functions
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(SignUpFirstStepViewController.keyboardWasShown(_:)), name: UIKeyboardDidShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(SignUpFirstStepViewController.keyboardWillBeHidden(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignUpFirstStepViewController.DismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        //Nav bar Back button.
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(image: UIImage(named: "icnBack")!, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(SignUpFirstStepViewController.back(_:)))
        self.navigationItem.leftBarButtonItem = newBackButton;
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
    }
    
    
    // UIAlertView Alert
    func displayAlertMessage(alertTitle:String, alertDescription:String) -> Void {
        // hide activityIndicator view and display alert message
        //        self.activityIndicatorView.hidden = true
        let errorAlert = UIAlertView(title:alertTitle, message:alertDescription, delegate:nil, cancelButtonTitle:"OK")
        errorAlert.show()
    }
    
    
    
    @IBAction func loginButtonPressed(sender: UIButton) {
        // validate presense of required parameters
        
//        if self.emailTextField.text!.isValidEmail(self.emailTextField.text!) == false {
//            self.displayAlertMessage("Invalid Email Address", alertDescription:
//                "Please input valid email address. Email is Case Sensitive.")
//        } else if self.passwordTextField.text!.characters.count < 8 {
//            self.displayAlertMessage("Invalid Password", alertDescription:
//                "Passwords must contain 8 values or more.")
//        } else {
//            //            makeSignInRequest()
//        }
        
    }
    
    func makeSignInRequest() {
        
        // update userLoggedInFlag
        self.updateUserLoggedInFlag()
        
        // save API AuthToken and ExpiryDate in Keychain
    }
    
    // Update the NSUserDefaults flag
    func updateUserLoggedInFlag() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject("loggedIn", forKey: "userLoggedIn")
        defaults.synchronize()
    }
    
    
    // Go Back To Previous VC
    @IBAction func back(sender: AnyObject) {
        if((self.presentingViewController) != nil){
            self.dismissViewControllerAnimated(true, completion: nil)
            NSLog("back")
        }
    }
    
    
    // Go To Another SignUpViewController2
        @IBAction func nextPressed(sender: UIButton) {

//            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("SignUpViewController2")
//
//            self.presentViewController(controller, animated: true, completion: nil)
        }
    
    
    // Text Field Return Resign First Responder
    func textFieldShouldReturn(textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
        if (textField == firstnameTextField) {
            lastnameTextField.becomeFirstResponder()

        } else {
          textField.resignFirstResponder()
        }
//        firstnameTextField.resignFirstResponder()
//        lastnameTextField.becomeFirstResponder()
        return true
    }
    
    
   
    //MARK: - Add TextFieldInput Navigation Arrows above Keyboard
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        let keyboardToolBar: UIToolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 50))
        let keyboardBarButtonItems = [
            UIBarButtonItem(title: "previous", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(SignUpFirstStepViewController.previousTextField)),
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "next", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(SignUpFirstStepViewController.nextTextField))
        ]
        
        keyboardToolBar.setItems(keyboardBarButtonItems, animated: false)
        keyboardToolBar.tintColor = colorX
        keyboardToolBar.barStyle = UIBarStyle.Black
        keyboardToolBar.sizeToFit()
        textField.inputAccessoryView = keyboardToolBar
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        activeField = nil
        
    }
    
    func nextTextField() {
        firstnameTextField.resignFirstResponder()
        lastnameTextField.becomeFirstResponder()
    }
    
    func previousTextField() {
        lastnameTextField.resignFirstResponder()
        firstnameTextField.becomeFirstResponder()
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
