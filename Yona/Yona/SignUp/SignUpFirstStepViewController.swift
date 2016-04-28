//
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
    
    @IBOutlet var gradientView: GradientView!
    @IBOutlet var firstnameTextField: UITextField!
    @IBOutlet var lastnameTextField: UITextField!
    @IBOutlet var personalQuoteLabel: UILabel!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var nextButton: UIButton!
    
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SignUpFirstStepViewController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SignUpFirstStepViewController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil)
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
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector.dismissKeyboard)
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
    
    //MARK: Keyboard Functions
    
    func keyboardWillShow(notification:NSNotification){
        
        var userInfo = notification.userInfo!
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
    static let dismissKeyboard = #selector(SignUpFirstStepViewController.dismissKeyboard)
    
    static let keyboardWasShown = #selector(SignUpFirstStepViewController.keyboardWillShow(_:))
    
    static let keyboardWillBeHidden = #selector(SignUpFirstStepViewController.keyboardWillHide(_:))
}
