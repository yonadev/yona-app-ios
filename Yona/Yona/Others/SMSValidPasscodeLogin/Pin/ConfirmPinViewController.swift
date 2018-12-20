//
//  ConfirmPinViewController.swift
//  Yona
//
//  Created by Chandan on 04/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

final class ConfirmPinViewController:  LoginSignupValidationMasterView {

    var pin: String?
    var newUser: Users?
    
    override func viewDidLoad() {
        super.viewDidLoad()
                        
        setupPincodeScreenDifferentlyWithText(NSLocalizedString("change-pin", comment: ""), headerTitleLabelText: NSLocalizedString("settings_confirm_new_pin", comment: ""), errorLabelText: nil, infoLabelText: NSLocalizedString("settings_confirm_new_pin_message", comment: ""), avtarImageName: R.image.icnAccountCreated())
        self.navigationItem.setLeftBarButton(nil, animated: false)
        self.navigationItem.setHidesBackButton(true, animated: false)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "ConfirmPinViewController")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as? [AnyHashable: Any])
        
        self.codeInputView.delegate = self
        self.codeInputView.secure = true
        codeView.addSubview(self.codeInputView)
        
        
       
        //keyboard functions
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(_:)) , name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)    }
    
    override func viewDidAppear(_ animated: Bool) {
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
        weak var tracker = GAI.sharedInstance().defaultTracker
        tracker!.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action", action: "ConfirmPasscodeBack", label: "Back from confirm passcode pressed", value: nil).build() as? [AnyHashable: Any])
        
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension ConfirmPinViewController: CodeInputViewDelegate {
    //post open app event after successfully signup
    func postOpenAppEvent() {
        if let savedUser = UserDefaults.standard.object(forKey: YonaConstants.nsUserDefaultsKeys.savedUser) {
            let user = UserRequestManager.sharedInstance.convertToDictionary(text: savedUser as! String)
            self.newUser = Users.init(userData: user! as BodyDataDictionary)
            UserRequestManager.sharedInstance.postOpenAppEvent(self.newUser!, onCompletion: { (success, message, code) in
                if !success{
                    self.displayAlertMessage(code!, alertDescription: message!)
                }
            })
        }
    }
    
    func codeInputView(_ codeInputView: CodeInputView, didFinishWithCode code: String) {
        if (pin == code) {
            codeInputView.resignFirstResponder()
            KeychainManager.sharedInstance.savePINCode(code)
            UserDefaults.standard.set(true, forKey: YonaConstants.nsUserDefaultsKeys.isLoggedIn)
            postOpenAppEvent()
            //Update flag
            setViewControllerToDisplay(ViewControllerTypeString.login, key: YonaConstants.nsUserDefaultsKeys.screenToDisplay)
            self.navigationController?.dismiss(animated: true, completion: nil)
        } else {
            codeInputView.clear()
            navigationController?.popViewController(animated: true)
        }
    }
}

private extension Selector {
    static let back = #selector(ConfirmPinViewController.back(_:))
}


extension ConfirmPinViewController: KeyboardProtocol {
    @objc func keyboardWasShown (_ notification: Notification) {
        
        if let activeField = self.codeView, let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
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
    
    @objc func keyboardWillBeHidden(_ notification: Notification) {
        let contentInsets = UIEdgeInsets.zero
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
    }
}
