
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
    @IBOutlet var nextButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Text Delegates
        
        self.firstnameTextField.delegate = self
        self.lastnameTextField.delegate = self
        self.firstnameTextField.placeholder = NSLocalizedString("signup.user.firstname", comment: "").uppercaseString
        self.lastnameTextField.placeholder = NSLocalizedString("signup.user.lastname", comment: "").uppercaseString
        
        self.nextButton.setTitle(NSLocalizedString("signup.button.next", comment: "").uppercaseString, forState: UIControlState.Normal)
        
        
        //keyboard functions
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(SignUpFirstStepViewController.keyboardWasShown(_:)), name: UIKeyboardDidShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(SignUpFirstStepViewController.keyboardWillBeHidden(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignUpFirstStepViewController.DismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        //Nav bar Back button.

        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        
        // Adding right mode image to text fields
        let firstname = UIImageView(image: UIImage(named: "icnName"))
        firstname.frame = CGRectMake(0.0, 0.0, firstname.image!.size.width+10.0, firstname.image!.size.height);
        firstname.contentMode = UIViewContentMode.Center
        self.firstnameTextField.rightView = firstname;
        self.firstnameTextField.rightViewMode = UITextFieldViewMode.Always
        
        
        let lastname = UIImageView(image: UIImage(named: "icnName"))
        lastname.frame = CGRectMake(0.0, 0.0, lastname.image!.size.width+10.0, lastname.image!.size.height);
        lastname.contentMode = UIViewContentMode.Center
        self.lastnameTextField.rightView = lastname;
        self.lastnameTextField.rightViewMode = UITextFieldViewMode.Always
        
    }
    
    
    // UIAlertView Alert
    func displayAlertMessage(alertTitle:String, alertDescription:String) -> Void {
        let errorAlert = UIAlertView(title:alertTitle, message:alertDescription, delegate:nil, cancelButtonTitle:"OK")
        errorAlert.show()
    }
    
    // Go To Another SignUpViewController2
    @IBAction func nextPressed(sender: UIButton) {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("SignUpSecondStepViewController")
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    
    // Text Field Return Resign First Responder
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == firstnameTextField) {
            lastnameTextField.becomeFirstResponder()
            
        } else {
            textField.resignFirstResponder()
        }
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
    
    func textFieldDidBeginEditing(textField: UITextField) {
        activeField = textField
        
        self.firstnameTextField.delegate = self
        self.lastnameTextField.delegate = self
        
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Fade)
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
