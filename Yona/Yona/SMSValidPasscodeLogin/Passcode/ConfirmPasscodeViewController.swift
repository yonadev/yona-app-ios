//
//  ConfirmPasscodeViewController.swift
//  Yona
//
//  Created by Chandan on 04/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

final class ConfirmPasscodeViewController:  UIViewController {
    @IBOutlet var progressView:UIView!
    @IBOutlet var codeView:UIView!
    
    @IBOutlet var headerTitleLabel: UILabel!
    @IBOutlet var infoLabel: UILabel!
    
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var gradientView: GradientView!
    
    var passcode: String?
    
    var colorX : UIColor = UIColor.yiWhiteColor()
    var posi:CGFloat = 0.0
    private var codeInputView: CodeInputView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Nav bar Back button.
        self.navigationItem.hidesBackButton = true
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        self.infoLabel.text = NSLocalizedString("confirmpasscode.user.infomessage", comment: "")
        self.headerTitleLabel.text = NSLocalizedString("confirmpasscode.user.headerTitle", comment: "").uppercaseString
        
        dispatch_async(dispatch_get_main_queue(), {
            self.gradientView.colors = [UIColor.yiGrapeTwoColor(), UIColor.yiGrapeTwoColor()]
        })
        
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        codeInputView = CodeInputView(frame: CGRect(x: 0, y: 0, width: 260, height: 55))
        
        if codeInputView != nil {
            codeInputView!.delegate = self
            codeInputView?.secure = true
            codeView.addSubview(codeInputView!)
        }
        //keyboard functions
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: Selector.keyboardWasShown, name: UIKeyboardDidShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: Selector.keyboardWillBeHidden, name: UIKeyboardWillHideNotification, object: nil)
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        codeInputView!.becomeFirstResponder()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // Go Back To Previous VC
    @IBAction func back(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}

extension ConfirmPasscodeViewController: KeyboardProtocol {
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
        if let position = resetTheView(posi, scrollView: scrollView, view: view) {
            posi = position
        }
    }
}

extension ConfirmPasscodeViewController: CodeInputViewDelegate {
    func codeInputView(codeInputView: CodeInputView, didFinishWithCode code: String) {
        if (passcode == code) {
            KeychainManager.sharedInstance.savePINCode(code)
            
            //Update flag
            setViewControllerToDisplay("Login", key: YonaConstants.nsUserDefaultsKeys.screenToDisplay)
            
            if let dashboardStoryboard = R.storyboard.dashboard.dashboardStoryboard {
                navigationController?.pushViewController(dashboardStoryboard, animated: true)
            }
        } else {
            codeInputView.clear()
            navigationController?.popViewControllerAnimated(true)
        }
    }
}

private extension Selector {
    static let keyboardWasShown = #selector(ConfirmPasscodeViewController.keyboardWasShown(_:))
    
    static let keyboardWillBeHidden = #selector(ConfirmPasscodeViewController.keyboardWillBeHidden(_:))
    
    static let back = #selector(ConfirmPasscodeViewController.back(_:))
}