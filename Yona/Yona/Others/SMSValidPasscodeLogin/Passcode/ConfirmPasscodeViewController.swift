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
        
        codeInputView.becomeFirstResponder()
       
        //keyboard functions
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: Selector.keyboardWasShown, name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: Selector.keyboardWillBeHidden, name: UIKeyboardWillHideNotification, object: nil)
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
    
    func keyboardWasShown (notification: NSNotification) {
        return
        let viewHeight = self.view.frame.size.height
        let info : NSDictionary = notification.userInfo!
        let keyboardSize: CGSize = info.objectForKey(UIKeyboardFrameBeginUserInfoKey)!.CGRectValue.size
        let keyboardInset = keyboardSize.height - viewHeight/3
        
        let  pos = (codeView?.frame.origin.y)! + (codeView?.frame.size.height)! + 30.0
        
        if (pos > (viewHeight-keyboardSize.height)) {
            posi = pos-(viewHeight-keyboardSize.height)
            UIView.animateWithDuration(0.0, animations: {
                self.view.frame.origin.y -= self.posi
            })
            
        } else {
            scrollView.setContentOffset(CGPointMake(0, keyboardInset), animated: true)
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        if let position = resetTheView(posi, scrollView: scrollView, view: view) {
            posi = position
        }
    }
}

extension ConfirmPasscodeViewController: CodeInputViewDelegate {
    func codeInputView(codeInputView: CodeInputView, didFinishWithCode code: String) {
        if (passcode == code) {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: YonaConstants.nsUserDefaultsKeys.isLoggedIn)

            KeychainManager.sharedInstance.savePINCode(code)
            
            //Update flag
            setViewControllerToDisplay(ViewControllerTypeString.login, key: YonaConstants.nsUserDefaultsKeys.screenToDisplay)
            
            if isFromSettings {
                self.navigationController?.popToRootViewControllerAnimated(true)
            } else {
                self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
            }
            

        } else {
            codeInputView.clear()
            navigationController?.popViewControllerAnimated(true)
        }
    }
}

private extension Selector {
    static let back = #selector(ConfirmPasscodeViewController.back(_:))
}