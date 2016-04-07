
//
//  SignUpFirstStepViewController.swift
//  Yona
//
//  Created by Chandan on 29/03/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

class SignUpFirstStepViewController: UIViewController,UIScrollViewDelegate {
    var activeField : UITextField?
    var colorX : UIColor = UIColor.yiWhiteColor()
    
    
    @IBOutlet var firstnameTextField: UITextField!
    @IBOutlet var lastnameTextField: UITextField!
    @IBOutlet var personalQuoteLabel: UILabel!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == R.segue.signUpFirstStepViewController.signUpSeconStepSegue.identifier,
            let vc = segue.destinationViewController as? SignUpSecondStepViewController {
            vc.userFirstName = firstnameTextField.text
            vc.userLastName = lastnameTextField.text
        }
    }
    
    private func setupUI() {
        // Text Delegates
       
       firstnameTextField.delegate = self
       lastnameTextField.delegate = self
       firstnameTextField.placeholder = NSLocalizedString("signup.user.firstname", comment: "").uppercaseString
       lastnameTextField.placeholder = NSLocalizedString("signup.user.lastname", comment: "").uppercaseString
       
       nextButton.setTitle(NSLocalizedString("signup.button.next", comment: "").uppercaseString, forState: UIControlState.Normal)
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignUpFirstStepViewController.DismissKeyboard))
        view.addGestureRecognizer(tap)
        
        //Nav bar Back button.
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        
        // Adding right mode image to text fields
        let firstname = UIImageView(image: R.image.icnName)
        firstname.frame = CGRectMake(0.0, 0.0, firstname.image!.size.width+10.0, firstname.image!.size.height);
        firstname.contentMode = UIViewContentMode.Center
        self.firstnameTextField.rightView = firstname;
        self.firstnameTextField.rightViewMode = UITextFieldViewMode.Always
        
        
        let lastname = UIImageView(image: R.image.icnName)
        lastname.frame = CGRectMake(0.0, 0.0, lastname.image!.size.width+10.0, lastname.image!.size.height);
        lastname.contentMode = UIViewContentMode.Center
        self.lastnameTextField.rightView = lastname;
        self.lastnameTextField.rightViewMode = UITextFieldViewMode.Always
    }
    
    @IBAction func nextPressed(sender: UIButton) {
        if self.firstnameTextField.text!.characters.count == 0 {
            self.displayAlertMessage("Invalid First Name", alertDescription:
                "Please input a First Name.")
            
        } else if self.lastnameTextField.text!.characters.count == 0 {
            self.displayAlertMessage("Invalid Last Name", alertDescription:
                "Please input a Last Name.")
            
        } else {
            performSegueWithIdentifier(R.segue.signUpFirstStepViewController.signUpSeconStepSegue, sender: self)
        }
    }
}

//MARK: - UITextFieldDelegate

extension SignUpFirstStepViewController: UITextFieldDelegate {
    // Text Field Return Resign First Responder
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == firstnameTextField) {
            lastnameTextField.becomeFirstResponder()
            
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    
    
    //MARK: Add TextFieldInput Navigation Arrows above Keyboard
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        let keyboardToolBar: UIToolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 50))
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
    
    
    //MARK: Keyboard Functions
    func keyboardWasShown (notification: NSNotification) {
        let viewHeight = self.view.frame.size.height
        let info : NSDictionary = notification.userInfo!
        let keyboardSize: CGSize = info.objectForKey(UIKeyboardFrameBeginUserInfoKey)!.CGRectValue.size
        let keyboardInset = keyboardSize.height - viewHeight/3
        
        //TODO: 260 is top view's height, need to improve this :(
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
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
}

private extension Selector {
    static let keyboardWasShown = #selector(SignUpSecondStepViewController.keyboardWasShown(_:))
    
    static let keyboardWillBeHidden = #selector(SignUpSecondStepViewController.keyboardWillBeHidden(_:))
    
    static let previousTextField = #selector(SignUpSecondStepViewController.previousTextField)
    
    static let nextTextField = #selector(SignUpSecondStepViewController.nextTextField)
}
