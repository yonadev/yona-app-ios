//
//
//  SignUpFirstStepViewController.swift
//  Yona
//
//  Created by Chandan on 29/03/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "SignUpFirstStepViewController")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as! [AnyHashable: Any])
        
        IQKeyboardManager.shared.enable = false
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHiden(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = true
        NotificationCenter.default.removeObserver(self)
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == R.segue.signUpFirstStepViewController.signUpSecondStepViewController.identifier,
            let vc = segue.destination as? SignUpSecondStepViewController {
            weak var tracker = GAI.sharedInstance().defaultTracker
            tracker!.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action", action: "nextSignupSecondStep", label: "Go to step 2 signup", value: nil).build() as! [AnyHashable: Any])
            vc.userFirstName = firstnameTextField.text
            vc.userLastName = lastnameTextField.text
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification)
    {
        self.topViewHeightConstraint.constant = 96;
        let animationDiration = (notification.userInfo![UIKeyboardAnimationDurationUserInfoKey]! as AnyObject).doubleValue!;
        let animationCurve = UIViewAnimationCurve.init(rawValue: Int((notification.userInfo![UIKeyboardAnimationCurveUserInfoKey]! as AnyObject).int32Value!))!
        UIView.animate(withDuration: animationDiration, animations: {
            UIView.setAnimationCurve(animationCurve)
            self.view.layoutIfNeeded()
        }) 
    }
    
    @objc func keyboardWillHiden(_ notification: Notification)
    {
        self.topViewHeightConstraint.constant = 210;
        let animationDiration = (notification.userInfo![UIKeyboardAnimationDurationUserInfoKey]! as AnyObject).doubleValue!;
        let animationCurve = UIViewAnimationCurve.init(rawValue: Int((notification.userInfo![UIKeyboardAnimationCurveUserInfoKey]! as AnyObject).int32Value!))!
        UIView.animate(withDuration: animationDiration, animations: {
            UIView.setAnimationCurve(animationCurve)
            self.view.layoutIfNeeded()
        }) 
    }
    
    fileprivate func setupUI() {
        // Text Delegates
        firstnameTextField.delegate = self
        lastnameTextField.delegate = self
   
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector.dismissKeyboard)
        view.addGestureRecognizer(tap)
        
        // Adding right mode image to text fields
        let firstname = UIImageView(image: R.image.icnName())
        firstname.frame = CGRect(x: 0.0, y: 0.0, width: firstname.image!.size.width+10.0, height: firstname.image!.size.height);
        firstname.contentMode = UIViewContentMode.center
        self.firstnameTextField.rightView = firstname;
        self.firstnameTextField.rightViewMode = UITextFieldViewMode.always
        
        
        let lastname = UIImageView(image: R.image.icnName())
        lastname.frame = CGRect(x: 0.0, y: 0.0, width: lastname.image!.size.width+10.0, height: lastname.image!.size.height);
        lastname.contentMode = UIViewContentMode.center
        self.lastnameTextField.rightView = lastname;
        self.lastnameTextField.rightViewMode = UITextFieldViewMode.always
        
    }
    
    // Go Back To Previous VC
    @IBAction func back(_ sender: AnyObject) {
        weak var tracker = GAI.sharedInstance().defaultTracker
        tracker!.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action", action: "backActionSignUpFirstStep", label: "Back from first step signup", value: nil).build() as! [AnyHashable: Any])
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func unwindToFirstStep(_ segue: UIStoryboardSegue) {

    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == firstnameTextField) {
            lastnameTextField.becomeFirstResponder()
            
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == firstnameTextField || textField == lastnameTextField {
            IQKeyboardManager.shared.enableAutoToolbar = true
        } else {
            IQKeyboardManager.shared.enableAutoToolbar = false
        }
    }

    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
}

private extension Selector {
    static let dismissKeyboard = #selector(SignUpFirstStepViewController.dismissKeyboard)
    
    static let back = #selector(SignUpFirstStepViewController.back(_:))
}
