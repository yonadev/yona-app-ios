//
//  ConfirmPasscodeViewController.swift
//  Yona
//
//  Created by Chandan on 04/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

final class ConfirmPasscodeViewController:  LoginSignupValidationMasterView {

    var passcode: String?
    override func viewDidLoad() {
        super.viewDidLoad()
                        
        setupPincodeScreenDifferentlyWithText(NSLocalizedString("change-pin", comment: ""), headerTitleLabelText: NSLocalizedString("settings_confirm_new_pin", comment: ""), errorLabelText: nil, infoLabelText: NSLocalizedString("settings_confirm_new_pin_message", comment: ""), avtarImageName: R.image.icnAccountCreated)
        self.navigationItem.setLeftBarButtonItem(nil, animated: false)
        self.navigationItem.setHidesBackButton(true, animated: false)

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.codeInputView.delegate = self
        self.codeInputView.secure = true
        codeView.addSubview(self.codeInputView)
        
        
       
        //keyboard functions
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: Selector.keyboardWasShown, name: UIKeyboardDidShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: Selector.keyboardWillBeHidden, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        codeInputView.becomeFirstResponder()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLayoutSubviews()
    {
        var scrollViewInsets = UIEdgeInsetsZero
        scrollViewInsets.top = 0
        scrollView.contentInset = scrollViewInsets
    }

    
    // Go Back To Previous VC
    @IBAction func back(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}

extension ConfirmPasscodeViewController: CodeInputViewDelegate {
    func codeInputView(codeInputView: CodeInputView, didFinishWithCode code: String) {
        if (passcode == code) {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: YonaConstants.nsUserDefaultsKeys.isLoggedIn)
            codeInputView.resignFirstResponder()
            
            KeychainManager.sharedInstance.savePINCode(code)
            //Update flag
            setViewControllerToDisplay(ViewControllerTypeString.login, key: YonaConstants.nsUserDefaultsKeys.screenToDisplay)
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)

        } else {
            codeInputView.clear()
            navigationController?.popViewControllerAnimated(true)
        }
    }
}

private extension Selector {
    static let back = #selector(ConfirmPasscodeViewController.back(_:))
}


extension ConfirmPasscodeViewController: KeyboardProtocol {
    func keyboardWasShown (notification: NSNotification) {
        
        if let activeField = self.codeView, keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
            var aRect = self.view.bounds
            aRect.origin.x = 64
            aRect.size.height -= 64
            aRect.size.height -= keyboardSize.size.height
            if (!CGRectContainsPoint(aRect, activeField.frame.origin)) {
                var frameToScrollTo = activeField.frame
                frameToScrollTo.size.height += 30
                self.scrollView.scrollRectToVisible(frameToScrollTo, animated: true)
            }
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        let contentInsets = UIEdgeInsetsZero
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
    }
}