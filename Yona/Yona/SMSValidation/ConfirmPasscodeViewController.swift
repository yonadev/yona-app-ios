//
//  ConfirmPasscodeViewController.swift
//  Yona
//
//  Created by Chandan on 04/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit


class ConfirmPasscodeViewController:  UIViewController,CodeInputViewDelegate {
    
    var colorX : UIColor = UIColor.yiWhiteColor()
    var posi:CGFloat!
    @IBOutlet var progressView:UIView!
    @IBOutlet var codeView:UIView!
    
    @IBOutlet var headerTitleLabel: UILabel!
    @IBOutlet var infoLabel: UILabel!
    
    @IBOutlet var scrollView: UIScrollView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        posi = 0.0
        let codeInputView = CodeInputView(frame: CGRect(x: 0, y: 0, width: 260, height: 55))
        
        codeInputView.delegate = self
        codeInputView.tag = 111
        codeView.addSubview(codeInputView)
        
        codeInputView.becomeFirstResponder()
  
        

               //Nav bar Back button.
        self.navigationItem.hidesBackButton = true

        let viewWidth = self.view.frame.size.width
        let customView=UIView(frame: CGRectMake(0, 0, ((viewWidth-60)/3)*2, 2))
        customView.backgroundColor=UIColor.yiDarkishPinkColor()
        self.progressView.addSubview(customView)
        

        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        self.infoLabel.text = NSLocalizedString("confirmpasscode.user.infomessage", comment: "").uppercaseString
        self.headerTitleLabel.text = NSLocalizedString("confirmpasscode.user.headerTitle", comment: "").uppercaseString
        
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        
        
        
    }
    
    func codeInputView(codeInputView: CodeInputView, didFinishWithCode code: String) {
        let title = code == "1234" ? "Correct!" : "Wrong!"
        if (title == "Correct!") {
            print("go to next view")
        } else {
            print("incorrect sms code")
            let errorAlert = UIAlertView(title:"Invalid code", message:"Try again", delegate:nil, cancelButtonTitle:"OK")
            errorAlert.show()

        }
    }


    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //keyboard functions
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(ConfirmPasscodeViewController.keyboardWasShown(_:)), name: UIKeyboardDidShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(ConfirmPasscodeViewController.keyboardWillBeHidden(_:)), name: UIKeyboardWillHideNotification, object: nil)
        

    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    // UIAlertView Alert
    private func displayAlertMessage(alertTitle:String, alertDescription:String) -> Void {
       
        let errorAlert = UIAlertView(title:alertTitle, message:alertDescription, delegate:nil, cancelButtonTitle:"OK")
        errorAlert.show()
    }
    
    
    //MARK: - Keyboard Functions
    func keyboardWasShown (notification: NSNotification) {
        
        let viewHeight = self.view.frame.size.height
        let info : NSDictionary = notification.userInfo!
        let keyboardSize: CGSize = info.objectForKey(UIKeyboardFrameBeginUserInfoKey)!.CGRectValue.size
        let keyboardInset = keyboardSize.height - viewHeight/3
        
        
        let  pos = (codeView?.frame.origin.y)! + (codeView?.frame.size.height)!
        
        
        if (pos > (viewHeight-keyboardSize.height)) {
            posi = pos-(viewHeight-keyboardSize.height)-10
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
