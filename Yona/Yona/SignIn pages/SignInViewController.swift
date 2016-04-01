//
//  SignInViewController.swift
//  Yona
//
//  Created by Chandan on 23/03/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit
import CoreData
import LocalAuthentication
import Security

class SignInViewController: UIViewController, UITextFieldDelegate {
    
    var colorX : UIColor = UIColor.yiPeaColor()
    var fbColor : UIColor = UIColor.yiGrapeColor()
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var signInImageView: UIImageView!
    
    
    
    
    // UIAlertView Alert
    func displayAlertMessage(alertTitle:String, alertDescription:String) -> Void {
        // hide activityIndicator view and display alert message
        //        self.activityIndicatorView.hidden = true
        let errorAlert = UIAlertView(title:alertTitle, message:alertDescription, delegate:nil, cancelButtonTitle:"OK")
        errorAlert.show()
    }
    
    
    
    @IBAction func loginButtonPressed(sender: UIButton) {
        // validate presense of required parameters
        
        if self.emailTextField.text!.isValidEmail(self.emailTextField.text!) == false {
            self.displayAlertMessage("Invalid Email Address", alertDescription:
                "Please input valid email address. Email is Case Sensitive.")
        } else if self.passwordTextField.text!.characters.count < 8 {
            self.displayAlertMessage("Invalid Password", alertDescription:
                "Passwords must contain 8 values or more.")
        } else {
            //            makeSignInRequest()
        }
        
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
    
    
    // Go To Another Dashboard.storyboard
    //    @IBAction func iLoginPressed(sender: UIButton) {
    //        let storyboard = UIStoryboard(name: "Dashboard", bundle: nil)
    //        let controller = storyboard.instantiateViewControllerWithIdentifier("DashboardStoryboard")
    //        
    //        self.presentViewController(controller, animated: true, completion: nil)
    //    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Text Delegates
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        self.view.addGestureRecognizer(tap)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Text Field Return Resign First Responder
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
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
        emailTextField.resignFirstResponder()
        passwordTextField.becomeFirstResponder()
    }
    
    func previousTextField() {
        passwordTextField.resignFirstResponder()
        emailTextField.becomeFirstResponder()
    }
    
    
    
    
    //Calls this function when the tap is recognized.
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    
    
    
    
    
    
}



















