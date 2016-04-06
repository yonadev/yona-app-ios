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
        
        self.infoLabel.text = NSLocalizedString("smsvalidation.user.infomessage", comment: "").uppercaseString
        self.headerTitleLabel.text = NSLocalizedString("smsvalidation.user.headerTitle", comment: "").uppercaseString
        self.resendCodeButton .setTitle(NSLocalizedString("smsvalidation.button.resendCode", comment: "").uppercaseString, forState: UIControlState.Normal)
        
        
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

//func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//    if segue.identifier == R.segue.sMSValidationViewController.passcodeSegue.identifier,
//        let vc = segue.destinationViewController as? SetPasscodeViewController {
//        
//    }
//}

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
//        if let position = adjustTheCodeView(scrollView, view: view, codeView: codeView, notification: notification) {
//            self.view.frame.origin.y = position
//        }

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
        
        APIServiceManager.sharedInstance.confirmMobileNumber(body) { success in
            if success {
                
                dispatch_async(dispatch_get_main_queue()) {
                    codeInputView.resignFirstResponder()
                    self.performSegueWithIdentifier(R.segue.sMSValidationViewController.passcodeSegue.identifier, sender: self)
                }
            } else {
                let errorAlert = UIAlertView(title:"Invalid code", message:"Try again", delegate:nil, cancelButtonTitle:"OK")
                errorAlert.show()
                codeInputView.clear()
            }
        }
    }
}


private extension Selector {
    static let keyboardWasShown = #selector(SignUpSecondStepViewController.keyboardWasShown(_:))
    
    static let keyboardWillBeHidden = #selector(SignUpSecondStepViewController.keyboardWillBeHidden(_:))
}
