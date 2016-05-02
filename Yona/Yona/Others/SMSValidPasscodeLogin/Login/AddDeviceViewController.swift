
//
//  AddDeviceViewController.swift
//  Yona
//
//  Created by Chandan on 06/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

class AddDeviceViewController: LoginSignupValidationMasterView, UIScrollViewDelegate {
    var activeField : UITextField?
    var previousRange: NSRange!
    
    private let nederlandPhonePrefix = "+316 "
    
    @IBOutlet var mobileTextField: UITextField!
    @IBOutlet var passcodeTextField: UITextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var infoLabel: UILabel!

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
    
    private func setupUI() {
        // Text Delegates
        if var label = previousRange {
            label.length = 1
        }
        
        mobileTextField.delegate = self
        passcodeTextField.delegate = self
        
        mobileTextField.placeholder = NSLocalizedString("adddevice.user.mobileNumber", comment: "").uppercaseString
        passcodeTextField.placeholder = NSLocalizedString("adddevice.user.passcode", comment: "").uppercaseString

        mobileTextField.text = nederlandPhonePrefix
        
        self.infoLabel.text = NSLocalizedString("adddevice.user.infoText", comment: "")
        
        
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
        
        let passcodeImage = UIImageView(image: R.image.icnName)
        passcodeImage.frame = CGRectMake(0.0, 0.0, passcodeImage.image!.size.width+10.0, passcodeImage.image!.size.height);
        mobileImage.contentMode = UIViewContentMode.Center
        self.passcodeTextField.rightView = passcodeImage;
        self.passcodeTextField.rightViewMode = UITextFieldViewMode.Always
    }
    
    // Go Back To Previous VC
    @IBAction func back(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    // Go To Another ViewController
    @IBAction func loginPressed(sender: UIButton) {
        
   
    }
}

extension AddDeviceViewController: UITextFieldDelegate {
    // Text Field Return Resign First Responder
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == mobileTextField) {
            passcodeTextField.becomeFirstResponder()
        } else {
          textField.resignFirstResponder()
        }
        return true
    }
    
    
   
    //MARK: - Add TextFieldInput Navigation Arrows above Keyboard
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        let keyboardToolBar: UIToolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 10))
        let keyboardBarButtonItems = [
            UIBarButtonItem(title: "previous", style: UIBarButtonItemStyle.Plain, target: self, action: Selector.previousTextField),
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "next", style: UIBarButtonItemStyle.Plain, target: self, action: Selector.nextTextField)
        ]
        
        keyboardToolBar.setItems(keyboardBarButtonItems, animated: false)
        keyboardToolBar.tintColor = colorx
        keyboardToolBar.barStyle = UIBarStyle.Black
        keyboardToolBar.sizeToFit()
        textField.inputAccessoryView = keyboardToolBar
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        activeField = textField
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Fade)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        activeField = nil
        
    }
    
    //MARK: -  copied from Apple developer forums - need to understand, bounced :(
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if (textField == mobileTextField) {
            if ((previousRange?.location >= range.location) ) {
                if (textField.text?.utf16.count ?? 0) + string.utf16.count - range.length == 9 || (textField.text?.utf16.count ?? 0) + string.utf16.count - range.length == 14 {
                    textField.text = String(textField.text!.characters.dropLast())
                    textField.text = String(textField.text!.characters.dropLast())
                }
            } else  {
                if (textField.text?.utf16.count ?? 0) + string.utf16.count - range.length == 9 || (textField.text?.utf16.count ?? 0) + string.utf16.count - range.length == 14 {
                    let space = " "
                    
                    textField.text = "\(textField.text!) \(space)"
                }            }
            previousRange = range
            
            if (textField.text?.utf16.count ?? 0) + string.utf16.count - range.length <= 5 {
                textField.text = nederlandPhonePrefix
            }
            
            return (textField.text?.utf16.count ?? 0) + string.utf16.count - range.length <= 18
        }
        return true
    }
    
    func nextTextField() {
        mobileTextField.resignFirstResponder()
        passcodeTextField.becomeFirstResponder()
    }
    
    func previousTextField() {
        passcodeTextField.resignFirstResponder()
        mobileTextField.becomeFirstResponder()
    }
    
}

private extension Selector {
    
    static let back = #selector(AddDeviceViewController.back(_:))
    
    static let previousTextField = #selector(AddDeviceViewController.previousTextField)
    
    static let nextTextField = #selector(AddDeviceViewController.nextTextField)
}
