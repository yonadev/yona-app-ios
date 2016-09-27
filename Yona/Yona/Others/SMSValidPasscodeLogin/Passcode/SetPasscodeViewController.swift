//
//  SetPasscodeViewController.swift
//  Yona
//
//  Created by Chandan on 04/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit



class SetPasscodeViewController: LoginSignupValidationMasterView {
    
    @IBOutlet weak var bottomViewLayout: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewWidth = self.view.frame.size.width
        let customView=UIView(frame: CGRectMake(0, 0, ((viewWidth-60)/3)*2, 2))
        customView.backgroundColor=UIColor.yiDarkishPinkColor()
        self.progressView.addSubview(customView)
        
        self.navigationController?.navigationBarHidden = false

        self.navigationItem.setLeftBarButtonItem(nil, animated: false)
        self.navigationItem.setHidesBackButton(true, animated: false)
        setupPincodeScreenDifferentlyWithText(NSLocalizedString("change-pin", comment: ""), headerTitleLabelText: NSLocalizedString("settings_new_pincode", comment: ""), errorLabelText: nil, infoLabelText: NSLocalizedString("settings_new_pin_message", comment: ""), avtarImageName: R.image.icnAccountCreated)

    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "SetPasscodeViewController")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
        
        codeInputView.delegate = self
        codeInputView.secure = true
        codeView.addSubview(codeInputView)
        
        //keyboard functions
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: Selector.keyboardWasShown, name: UIKeyboardDidShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: Selector.keyboardWillBeHidden, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.codeInputView.clear()
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



extension SetPasscodeViewController: CodeInputViewDelegate {
    func codeInputView(codeInputView: CodeInputView, didFinishWithCode code: String) {
        passcodeString = code
        performSegueWithIdentifier(R.segue.setPasscodeViewController.transToConfirmPincode, sender: self)
        self.codeInputView.clear()
    }
}

private extension Selector {
    static let back = #selector(SetPasscodeViewController.back(_:))
}


extension SetPasscodeViewController: KeyboardProtocol {
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