//
//  SMSValidationViewController.swift
//  Yona
//
//  Created by Chandan on 01/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit


final class SMSValidationViewController:  UIViewController {
    @IBOutlet var progressView:UIView!
    @IBOutlet var codeView:UIView!
    
    @IBOutlet var headerTitleLabel: UILabel!
    @IBOutlet var infoLabel: UILabel!
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var resendCodeButton: UIButton!
    
    private var colorX : UIColor = UIColor.yiWhiteColor()
    var posi:CGFloat = 0.0
    private var codeInputView: CodeInputView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Nav bar Back button.
        self.navigationItem.hidesBackButton = true

        let viewWidth = self.view.frame.size.width
        let customView=UIView(frame: CGRectMake(0, 0, (viewWidth-60)/2, 2))
        customView.backgroundColor=UIColor.yiDarkishPinkColor()
        self.progressView.addSubview(customView)

        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        self.infoLabel.text = NSLocalizedString("smsvalidation.user.infomessage", comment: "")
        self.headerTitleLabel.text = NSLocalizedString("smsvalidation.user.headerTitle", comment: "").uppercaseString
        self.resendCodeButton .setTitle(NSLocalizedString("smsvalidation.button.resendCode", comment: ""), forState: UIControlState.Normal)
        
        #if DEBUG
        if let pincode = NSUserDefaults.standardUserDefaults().objectForKey(YonaConstants.nsUserDefaultsKeys.pincode) as? String {
            self.displayAlertMessage(pincode, alertDescription:"Pincode")
        }
        #endif
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        codeInputView = CodeInputView(frame: CGRect(x: 0, y: 0, width: 260, height: 55))
        
        if codeInputView != nil {
            codeInputView!.delegate = self
            codeView.addSubview(codeInputView!)
            let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(50)))
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                self.codeInputView!.becomeFirstResponder()
            })
        }
        
        //keyboard functions
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: Selector.keyboardWasShown, name: UIKeyboardDidShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: Selector.keyboardWillBeHidden, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

extension SMSValidationViewController: KeyboardProtocol {
    func keyboardWasShown (notification: NSNotification) {
        
        let viewHeight = self.view.frame.size.height
        let info : NSDictionary = notification.userInfo!
        let keyboardSize: CGSize = info.objectForKey(UIKeyboardFrameBeginUserInfoKey)!.CGRectValue.size
        let keyboardInset = keyboardSize.height - viewHeight/3
        
        
        let  pos = (resendCodeButton?.frame.origin.y)! + (resendCodeButton?.frame.size.height)!
        
        
        if (pos > (viewHeight-keyboardSize.height)) {
            posi = pos-(viewHeight-keyboardSize.height)
            self.view.frame.origin.y -= posi
            
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

extension SMSValidationViewController: CodeInputViewDelegate {
    func codeInputView(codeInputView: CodeInputView, didFinishWithCode code: String) {
        let body =
            [
                "code": code
            ]

        APIServiceManager.sharedInstance.confirmMobileNumber(body) { success, dict, err in
            dispatch_async(dispatch_get_main_queue()) {
                if (success) {

                        codeInputView.resignFirstResponder()
                        //Update flag
                        setViewControllerToDisplay("Passcode", key: YonaConstants.nsUserDefaultsKeys.screenToDisplay)
                        
                        if let passcode = R.storyboard.passcode.passcodeStoryboard {
                            self.navigationController?.pushViewController(passcode, animated: false)
                        }
                    
                } else {
                    if let codeMessage = dict!["code"] {
                        if(codeMessage.isEqualToString("error.too.many.wrong.attempts")){
                            self.displayAlertMessage("", alertDescription: NSLocalizedString("smsvalidation.user.pincodeattempted5times", comment: ""))
                            //for now just disable the pincode enter screen and not let them interact...
                            codeInputView.resignFirstResponder()
                            codeInputView.userInteractionEnabled = false
                        } else {
                            self.displayAlertMessage("", alertDescription: NSLocalizedString("smsvalidation.user.errormessage", comment: ""))
                        }
                    }
                    codeInputView.clear()
                }
            }
        }
    }
}

private extension Selector {
    static let keyboardWasShown = #selector(SignUpSecondStepViewController.keyboardWasShown(_:))
    static let keyboardWillBeHidden = #selector(SignUpSecondStepViewController.keyboardWillBeHidden(_:))
}
