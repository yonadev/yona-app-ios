//
//  SetPasscodeViewController.swift
//  Yona
//
//  Created by Chandan on 04/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit


class SetPasscodeViewController:  UIViewController {
    @IBOutlet var progressView:UIView!
    @IBOutlet var codeView:UIView!
    
    @IBOutlet var headerTitleLabel: UILabel!
    @IBOutlet var infoLabel: UILabel!
    
    @IBOutlet var scrollView: UIScrollView!
    
    var passcodeString: String?
    private var colorX : UIColor = UIColor.yiWhiteColor()
    private var posi:CGFloat = 0.0
    private var codeInputView: CodeInputView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Nav bar Back button.
        self.navigationItem.hidesBackButton = true

        let viewWidth = self.view.frame.size.width
        let customView=UIView(frame: CGRectMake(0, 0, ((viewWidth-60)/3)*2, 2))
        customView.backgroundColor=UIColor.yiDarkishPinkColor()
        self.progressView.addSubview(customView)
        

        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        self.infoLabel.text = NSLocalizedString("passcode.user.infomessage", comment: "").uppercaseString
        self.headerTitleLabel.text = NSLocalizedString("passcode.user.headerTitle", comment: "").uppercaseString
        
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        codeInputView = CodeInputView(frame: CGRect(x: 0, y: 0, width: 260, height: 55))
        
        if codeInputView != nil {
            codeInputView!.delegate = self
            codeView.addSubview(codeInputView!)
        }
        
        //keyboard functions
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(SetPasscodeViewController.keyboardWasShown(_:)), name: UIKeyboardDidShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(SetPasscodeViewController.keyboardWillBeHidden(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        codeInputView!.becomeFirstResponder()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == R.segue.setPasscodeViewController.confirmPasscodeSegue.identifier,
            let vc = segue.destinationViewController as? ConfirmPasscodeViewController {
            vc.passcode = passcodeString
        }
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
        
        
        let  pos = (codeView?.frame.origin.y)! + (codeView?.frame.size.height)! + 30.0
        
        
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

extension SetPasscodeViewController: CodeInputViewDelegate {
    func codeInputView(codeInputView: CodeInputView, didFinishWithCode code: String) {
        passcodeString = code
        performSegueWithIdentifier(R.segue.setPasscodeViewController.confirmPasscodeSegue, sender: self)
    }
}
