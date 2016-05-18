//
//  SetPasscodeViewController.swift
//  Yona
//
//  Created by Chandan on 04/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit


class SetPasscodeViewController: LoginSignupValidationMasterView {
    
    var passcodeString: String?
    
    @IBOutlet var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Nav bar Back button.
        self.navigationItem.hidesBackButton = true
        
        let viewWidth = self.view.frame.size.width
        let customView=UIView(frame: CGRectMake(0, 0, ((viewWidth-60)/3)*2, 2))
        customView.backgroundColor=UIColor.yiDarkishPinkColor()
        self.progressView.addSubview(customView)
        

        self.navigationController?.setNavigationBarHidden(true, animated: false)
                
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        
        setupPincodeScreenDifferentlyWithText(NSLocalizedString("settings_new_pincode", comment: ""), screenNameText: NSLocalizedString("change-pin", comment: ""), infoLabelText: NSLocalizedString("settings_new_pin_message", comment: ""))
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
        super.viewDidAppear(animated)
        self.codeInputView.clear()
        UIView.animateWithDuration(0.1) {
            self.codeInputView.becomeFirstResponder()
        }
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.codeInputView.resignFirstResponder()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // Go Back To Previous VC
    @IBAction func back(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}

extension SetPasscodeViewController: KeyboardProtocol {
    func keyboardWasShown (notification: NSNotification) {
        
        let viewHeight = self.view.frame.size.height
        let info : NSDictionary = notification.userInfo!
        let keyboardSize: CGSize = info.objectForKey(UIKeyboardFrameBeginUserInfoKey)!.CGRectValue.size
        let keyboardInset = keyboardSize.height - viewHeight/3
        
        
        let  pos = (codeView?.frame.origin.y)! + (codeView?.frame.size.height)! + 30.0
        
        
        if (pos > (viewHeight-keyboardSize.height)) {
            posi = pos-(viewHeight-keyboardSize.height)
            UIView.animateWithDuration(0.2, animations: {
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

extension SetPasscodeViewController: CodeInputViewDelegate {
    func codeInputView(codeInputView: CodeInputView, didFinishWithCode code: String) {
        passcodeString = code
        if let passcode = R.storyboard.confirmPasscode.confirmPasscodeStoryboard {
            passcode.passcode = code
            if isFromSettings {
                passcode.isFromSettings = self.isFromSettings
            }
            self.navigationController?.pushViewController(passcode, animated: false)
        }
        self.codeInputView.clear()
    }
}

private extension Selector {
    static let back = #selector(SetPasscodeViewController.back(_:))
}
