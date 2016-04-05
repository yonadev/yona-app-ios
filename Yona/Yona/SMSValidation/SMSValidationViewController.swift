//
//  SMSValidationViewController.swift
//  Yona
//
//  Created by Chandan on 01/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit


class SMSValidationViewController:  UIViewController {
    @IBOutlet var progressView:UIView!
    @IBOutlet var codeView:UIView!
    
    @IBOutlet var headerTitleLabel: UILabel!
    @IBOutlet var infoLabel: UILabel!
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var resendCodeButton: UIButton!
    
    private var colorX : UIColor = UIColor.yiWhiteColor()
    private var posi:CGFloat = 0.0
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
            
            codeInputView!.becomeFirstResponder()
        }
        
        //keyboard functions
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(SMSValidationViewController.keyboardWasShown(_:)), name: UIKeyboardDidShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(SMSValidationViewController.keyboardWillBeHidden(_:)), name: UIKeyboardWillHideNotification, object: nil)
        

    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    //MARK: - Keyboard Functions
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
        self.scrollView.setContentOffset(CGPointMake(0, 0), animated: true)
        if (posi > 0) {
            self.view.frame.origin.y += posi
            posi = 0.0
        }
    }
}

extension SMSValidationViewController: CodeInputViewDelegate {
    func codeInputView(codeInputView: CodeInputView, didFinishWithCode code: String) {
        let title = code == "1234" ? "Correct!" : "Wrong!"
        
        if (title == "Correct!") {
            print("go to next view")
            codeInputView.resignFirstResponder()
            performSegueWithIdentifier(R.segue.sMSValidationViewController.passcodeSegue, sender: self)
        } else {
            print("incorrect sms code")
            let errorAlert = UIAlertView(title:"Invalid code", message:"Try again", delegate:nil, cancelButtonTitle:"OK")
            errorAlert.show()
            codeInputView.clear()
//            (self.view.viewWithTag(111) as! CodeInputView).clear()
            
        }
    }
}
