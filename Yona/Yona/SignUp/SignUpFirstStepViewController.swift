//
//
//  SignUpFirstStepViewController.swift
//  Yona
//
//  Created by Chandan on 29/03/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

class SignUpFirstStepViewController: BaseViewController, UIScrollViewDelegate {
    var activeField : UITextField?
    var colorX : UIColor = UIColor.yiWhiteColor()
    
    @IBOutlet var firstnameTextField: UITextField!
    @IBOutlet var lastnameTextField: UITextField!
    @IBOutlet var personalQuoteLabel: UILabel!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var topView: UIView!
    
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        setupUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        IQKeyboardManager.sharedManager().enable = false
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHiden(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.sharedManager().enable = true
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == R.segue.signUpFirstStepViewController.signUpSecondStepViewController.identifier,
        
            let vc = segue.destinationViewController as? SignUpSecondStepViewController {
            vc.userFirstName = firstnameTextField.text
            vc.userLastName = lastnameTextField.text
        }
    }
    
    func keyboardWillShow(notification: NSNotification)
    {
        self.topViewHeightConstraint.constant = 96;
        let animationDiration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey]!.doubleValue!;
        let animationCurve = UIViewAnimationCurve.init(rawValue: Int(notification.userInfo![UIKeyboardAnimationCurveUserInfoKey]!.intValue!))!
        UIView.animateWithDuration(animationDiration) {
            UIView.setAnimationCurve(animationCurve)
            self.view.layoutIfNeeded()
        }
    }
    
    func keyboardWillHiden(notification: NSNotification)
    {
        self.topViewHeightConstraint.constant = 210;
        let animationDiration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey]!.doubleValue!;
        let animationCurve = UIViewAnimationCurve.init(rawValue: Int(notification.userInfo![UIKeyboardAnimationCurveUserInfoKey]!.intValue!))!
        UIView.animateWithDuration(animationDiration) {
            UIView.setAnimationCurve(animationCurve)
            self.view.layoutIfNeeded()
        }
    }
    
    private func setupUI() {
        // Text Delegates
        
        firstnameTextField.delegate = self
        lastnameTextField.delegate = self
   
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector.dismissKeyboard)
        view.addGestureRecognizer(tap)
        
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
    
    // Go Back To Previous VC
    @IBAction func back(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func unwindToFirstStep(segue: UIStoryboardSegue) {

    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if self.firstnameTextField.text!.characters.count == 0 {
            self.displayAlertMessage("Invalid First Name", alertDescription:
                "Please input a First Name.")
            return false

        } else if self.lastnameTextField.text!.characters.count == 0 {
            self.displayAlertMessage("Invalid Last Name", alertDescription:
                "Please input a Last Name.")
            return false
            
        } else {
            return true
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

    //Calls this function when the tap is recognized.
    func dismissKeyboard(){
        view.endEditing(true)
    }
}

private extension Selector {
    static let dismissKeyboard = #selector(SignUpFirstStepViewController.dismissKeyboard)
    
    static let back = #selector(SignUpFirstStepViewController.back(_:))
}
