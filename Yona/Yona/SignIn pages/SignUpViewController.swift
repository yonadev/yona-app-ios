//
//  SignUpViewController.swift
//  Yona
//
//  Created by Chandan on 23/03/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

// Check for valid email address
extension String {
    func isValidEmail(testStr:String) -> Bool {
        
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
}

class SignUpViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate {
    
    var activeField : UITextField?
    
    var colorX : UIColor = UIColor.yiPeaColor()
    
    // swipe to go back
    let swipeBack = UISwipeGestureRecognizer()
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var firstNameTextField: UITextField!
    @IBOutlet var lastNameTextField: UITextField!
    
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var passwordConfirmationTextField: UITextField!
    
    @IBOutlet var contactNumberTextField: UITextField!
    @IBOutlet var signUpImageView: UIImageView!
    @IBOutlet var scrollView: UIScrollView!
    
    @IBAction func back(sender: AnyObject) {
        if((self.presentingViewController) != nil){
            self.dismissViewControllerAnimated(true, completion: nil)
            NSLog("back")
        }
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    
    // Password Reveal Button
    @IBOutlet var passwordRevealBtn: UIButton!
    @IBAction func passwordRevealBtnTapped(sender: AnyObject) {
        self.passwordRevealBtn.selected = !self.passwordRevealBtn.selected
        
        if self.passwordRevealBtn.selected {
            self.passwordTextField.secureTextEntry = false
        }
            
        else {
            self.passwordTextField.secureTextEntry = true
        }
    }
    
    
    @IBOutlet var passwordConfirmationRevealBtn: UIButton!
    @IBAction func passwordConfirmationRevealBtnTapped(sender: AnyObject) {
        self.passwordRevealBtn.selected = !self.passwordRevealBtn.selected
        
        if self.passwordRevealBtn.selected {
            self.passwordConfirmationTextField.secureTextEntry = false
        }
            
        else {
            self.passwordConfirmationTextField.secureTextEntry = true
        }
    }
    
    
    
    
    // UIAlertView Alert
    func displayAlertMessage(alertTitle:String, alertDescription:String) -> Void {
        let errorAlert = UIAlertView(title:alertTitle, message:alertDescription, delegate:nil, cancelButtonTitle:"OK")
        errorAlert.show()
    }
    
    
    
    
    @IBAction func signUpButtonPressed(sender: UIButton) {
        // validate presence of all required parameters
        
        if self.emailTextField.text!.isValidEmail(self.emailTextField.text!) == false {
            self.displayAlertMessage("Invalid Email Address", alertDescription:
                "Please input valid email address. Email is Case Sensitive.")
            
        } else if self.firstNameTextField.text!.characters.count == 0 {
            self.displayAlertMessage("Invalid First Name", alertDescription:
                "Please input a First Name.")
            
        } else if self.lastNameTextField.text!.characters.count == 0 {
            self.displayAlertMessage("Invalid Last Name", alertDescription:
                "Please input a Last Name.")
            
        } else if self.passwordTextField.text!.characters.count < 8 {
            self.displayAlertMessage("Invalid Password", alertDescription:
                "Passwords must contain 8 values or more.")
            
        } else if self.passwordConfirmationTextField.text! != self.passwordTextField.text! {
            self.displayAlertMessage("Invalid Password Confirmation", alertDescription:
                "Please make sure password confirmation field is identical to password field.")
        } else {
            //            makeSignUpRequest()
        }
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // swipe to go back
        swipeBack.direction = UISwipeGestureRecognizerDirection.Right
        swipeBack.addTarget(self, action: "swipeBack:")
        self.view.addGestureRecognizer(swipeBack)
        
        //keyboard functions
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardDidShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
        
        self.firstNameTextField.delegate = self
        self.lastNameTextField.delegate = self
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        self.passwordConfirmationTextField.delegate = self
        self.contactNumberTextField.delegate = self
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        self.view.addGestureRecognizer(tap)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.firstNameTextField.resignFirstResponder()
        self.lastNameTextField.resignFirstResponder()
        self.emailTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
        self.passwordConfirmationTextField.resignFirstResponder()
        self.contactNumberTextField.resignFirstResponder()
        
        return true
    }
    
    
    //MARK: - Add TextFieldInput Navigation Arrows above Keyboard
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        let keyboardToolBar: UIToolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 50))
        let keyboardBarButtonItems = [
            UIBarButtonItem(image: UIImage(named: "upButton"), style: UIBarButtonItemStyle.Plain, target: self, action: "previousTextField"),
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil),
            UIBarButtonItem(image: UIImage(named: "downButton"), style: UIBarButtonItemStyle.Plain, target: self, action: "nextTextField")
        ]
        
        keyboardToolBar.setItems(keyboardBarButtonItems, animated: false)
        keyboardToolBar.tintColor = colorX
        keyboardToolBar.barStyle = UIBarStyle.Black
        keyboardToolBar.sizeToFit()
        textField.inputAccessoryView = keyboardToolBar
        return true
    }
    
    func nextTextField() {
        if emailTextField.isFirstResponder() == true {
            emailTextField.resignFirstResponder()
            firstNameTextField.becomeFirstResponder()
        } else if firstNameTextField.isFirstResponder() == true {
            firstNameTextField.resignFirstResponder()
            lastNameTextField.becomeFirstResponder()
        } else if lastNameTextField.isFirstResponder() == true {
            lastNameTextField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        } else if passwordTextField.isFirstResponder() == true {
            passwordTextField.resignFirstResponder()
            passwordConfirmationTextField.becomeFirstResponder()
        } else if passwordConfirmationTextField.isFirstResponder() == true {
        }
    }
    
    func previousTextField() {
        if emailTextField.isFirstResponder() == true {
        } else if firstNameTextField.isFirstResponder() == true {
            firstNameTextField.resignFirstResponder()
            emailTextField.becomeFirstResponder()
        } else if lastNameTextField.isFirstResponder() == true {
            lastNameTextField.resignFirstResponder()
            firstNameTextField.becomeFirstResponder()
        } else if passwordTextField.isFirstResponder() == true {
            passwordTextField.resignFirstResponder()
            lastNameTextField.becomeFirstResponder()
        } else if passwordConfirmationTextField.isFirstResponder() == true {
            passwordConfirmationTextField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        }
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
    
    
    func textFieldDidBeginEditing(textField: UITextField) {
        activeField = textField
        
        self.emailTextField.delegate = self
        self.firstNameTextField.delegate = self
        self.lastNameTextField.delegate = self
        self.passwordTextField.delegate = self
        self.passwordConfirmationTextField.delegate = self
        
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Fade)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        activeField = nil
        
    }
    
    
    
    //MARK:- Calls this function when the tap is recognized.
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    //MARK: Swipe to go Back Gesture
    func swipeBack(sender: UISwipeGestureRecognizer) {
        if((self.presentingViewController) != nil){
            self.dismissViewControllerAnimated(true, completion: nil)
            NSLog("back")
        }
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    
}



