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
        let customView=UIView(frame: CGRect(x: 0, y: 0, width: ((viewWidth-60)/3)*2, height: 2))
        customView.backgroundColor=UIColor.yiDarkishPinkColor()
        self.progressView.addSubview(customView)
        
        self.navigationController?.isNavigationBarHidden = false

        self.navigationItem.setLeftBarButton(nil, animated: false)
        self.navigationItem.setHidesBackButton(true, animated: false)
        setupPincodeScreenDifferentlyWithText(NSLocalizedString("change-pin", comment: ""), headerTitleLabelText: NSLocalizedString("settings_new_pincode", comment: ""), errorLabelText: nil, infoLabelText: NSLocalizedString("settings_new_pin_message", comment: ""), avtarImageName: R.image.icnAccountCreated())

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "SetPasscodeViewController")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as! [AnyHashable: Any])
        
        codeInputView.delegate = self
        codeInputView.secure = true
        codeView.addSubview(codeInputView)
        
        //keyboard functions
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: Selector.keyboardWasShown, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        notificationCenter.addObserver(self, selector: Selector.keyboardWillBeHidden, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.codeInputView.clear()
        codeInputView.becomeFirstResponder()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    override func viewDidLayoutSubviews()
    {

        var scrollViewInsets = UIEdgeInsets.zero
        scrollViewInsets.top = 0
        scrollView.contentInset = scrollViewInsets
    }
    
    // Go Back To Previous VC
    @IBAction func back(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }

}



extension SetPasscodeViewController: CodeInputViewDelegate {
    func codeInputView(_ codeInputView: CodeInputView, didFinishWithCode code: String) {
        passcodeString = code
        performSegue(withIdentifier: R.segue.setPasscodeViewController.transToConfirmPincode, sender: self)
        self.codeInputView.clear()
    }
}

private extension Selector {
    static let back = #selector(SetPasscodeViewController.back(_:))
}


extension SetPasscodeViewController: KeyboardProtocol {
    func keyboardWasShown (_ notification: Notification) {
        
        if let activeField = self.codeView, let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
            var aRect = self.view.bounds
            aRect.origin.x = 64
            aRect.size.height -= 64
            aRect.size.height -= keyboardSize.size.height
            if (!aRect.contains(activeField.frame.origin)) {
                var frameToScrollTo = activeField.frame
                frameToScrollTo.size.height += 30
                self.scrollView.scrollRectToVisible(frameToScrollTo, animated: true)
            }
        }
    }
    
    func keyboardWillBeHidden(_ notification: Notification) {
        let contentInsets = UIEdgeInsets.zero
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
    }
}
