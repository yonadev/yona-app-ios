//
//  PinResetValidationVC.swift
//  Yona
//
//  Created by Ben Smith on 14/06/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

final class PinResetValidationVC: ValidationMasterView {
    @IBOutlet var resendOTPResetCode: UIButton!

    
    //MARK: Pin reset Count down
    var pinResetCountDownTimer: NSTimer?
    var pinResetCountDownStartTime : NSDate?
    
    @IBOutlet weak var pinResetCountDownContainer: UIView!
    @IBOutlet weak var remainingHoursLabel: UILabel!
    @IBOutlet weak var remainingMinutesLabel: UILabel!
    @IBOutlet weak var remainingSecondsLabel: UILabel!
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "PinResetValidationVC")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
        
        setBackgroundColour()
        displayPincodeRemainingMessage()
        self.codeInputView.delegate = self
        self.codeInputView.secure = true
        codeView.addSubview(self.codeInputView)
        codeView.resignFirstResponder()
        //keyboard functions
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: Selector.keyboardWasShown, name: UIKeyboardDidShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: Selector.keyboardWillBeHidden, name: UIKeyboardWillHideNotification, object: nil)
    }
    override func viewDidAppear(animated: Bool) {
        if !(pinResetCountDownTimer?.valid)! {
            codeInputView.becomeFirstResponder()
            headerTitleLabel.text = NSLocalizedString("smsvalidation.user.headerTitle", comment:"")
            infoLabel.text = NSLocalizedString("smsvalidation.user.infomessage", comment:"")

            
        }
    }
    
    @IBAction func resendPinResetRequestOTPCode(sender: UIButton) {
        Loader.Show()
        
        weak var tracker = GAI.sharedInstance().defaultTracker
        tracker!.send(GAIDictionaryBuilder.createEventWithCategory("ui_action", action: "resendPinResetRequestOTPCode", label: "Resend the OTP pin reset code", value: nil) as AnyObject as! [NSObject : AnyObject])
        
        PinResetRequestManager.sharedInstance.pinResendResetRequest{ (success, nil, message, code) in
            if success {
                Loader.Hide()
                //self.codeInputView.userInteractionEnabled = true
                
                #if DEBUG
                    print ("pincode is \(code)")
                #endif
            } else {
                PinResetRequestManager.sharedInstance.pinResetRequest({ (success, pincode, message, code) in
                    Loader.Hide()
                    if success {
                        self.displayPincodeRemainingMessage()
                       // self.codeInputView.userInteractionEnabled = true
                    } else {
                        if let message = message {
                            self.infoLabel.text = message
                        }
                    }
                })
            }
        }
    }
    
    
    override func displayPincodeRemainingMessage(){
        guard let timeISOCode = NSUserDefaults.standardUserDefaults().valueForKey(YonaConstants.nsUserDefaultsKeys.timeToPinReset) as? String else {
            return
        }
        
        let userInfo = NSMutableDictionary()
        let (hours, minutes, seconds) = timeISOCode.convertFromISO8601Duration()
        userInfo["hours"] = hours
        userInfo["minutes"] = minutes
        userInfo["seconds"] = seconds
        pinResetCountDownTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(PinResetValidationVC.executePinResetCounter(_:)), userInfo: userInfo, repeats: true)
        
        executePinResetCounter(pinResetCountDownTimer!)
        
        headerTitleLabel.text = NSLocalizedString("smsvalidation.wait.headerTitle", comment:"")
        infoLabel.text = NSLocalizedString("smsvalidation.user.infomessage", comment:"")

        headerTitleLabel.text = "Je moet even wachten"
        infoLabel.text = "Om veiligheidsredenen is je account geblokkeerd. Activeren kan 24 uur nadat je een nieuwe PIN code hebt aangevraagd."

    }
    
    func executePinResetCounter(timer: NSTimer)
    {
        let userInfo = timer.userInfo! as! NSDictionary
        let hours = userInfo["hours"]! as! Int
        let minutes = userInfo["minutes"]! as! Int
        let seconds = userInfo["seconds"]! as! Int
        
        if(pinResetCountDownStartTime == nil){
            if let startDate = NSUserDefaults.standardUserDefaults().valueForKey(YonaConstants.nsUserDefaultsKeys.timeToPinResetInitialRequestTime) as? NSDate{
                pinResetCountDownStartTime = startDate
            }else{
                pinResetCountDownStartTime = NSDate()
            }
            
        }
        updateRemainingMessageForCountDown(hours, minutes: minutes, seconds: seconds)
    }
    
    func updateRemainingMessageForCountDown(hours: Int, minutes: Int, seconds: Int)
    {
        
        let second = Int(1)
        let minute = Int(second * 60)
        let hour = Int(minute * 60)
        
        var remainingHours = hours
        var remainingMinutes = minutes
        var remainingSeconds = seconds
        
        var diff = Int(abs(pinResetCountDownStartTime!.timeIntervalSinceNow))
        
        if diff > hour{
            let diffHours = (diff / hour)
            remainingHours -= diffHours
            diff -= diffHours
        }
        
        if diff > minute{
            let diffMinutes = (diff / minute)
            remainingMinutes -= diffMinutes
            diff -= diffMinutes
        }
        
        remainingSeconds -= diff
        
        if remainingHours > 0 || remainingMinutes > 0 || remainingSeconds > 0{
            //update our labels...
            codeView.hidden = true
            resendOTPResetCode.hidden = true
            pinResetCountDownContainer.hidden = false
            remainingHoursLabel.text = "\(remainingHours)"
            remainingMinutesLabel.text = "\(remainingMinutes)"
            remainingSecondsLabel.text = "\(remainingSeconds)"
        }else{
            //allow the user to enter his pin code
            headerTitleLabel.text = NSLocalizedString("smsvalidation.user.headerTitle", comment:"")
            infoLabel.text = NSLocalizedString("smsvalidation.user.infomessage", comment:"")
            pinResetCountDownContainer.hidden = true
            codeView.hidden = false
            resendOTPResetCode.hidden = false
            pinResetCountDownTimer?.invalidate()
            codeInputView.becomeFirstResponder()
        }
        
    }
}

extension PinResetValidationVC: CodeInputViewDelegate {
    
    func codeInputView(codeInputView: CodeInputView, didFinishWithCode code: String) {
        self.codeInputView.userInteractionEnabled = true
        let body = ["code": code]
        Loader.Show()
        PinResetRequestManager.sharedInstance.pinResetVerify(body, onCompletion: { (success, nil, message, code) in
            Loader.Hide()
            if success {
                //pin verify succeeded, unblock app
                NSUserDefaults.standardUserDefaults().setBool(false, forKey: YonaConstants.nsUserDefaultsKeys.isBlocked)
                //clear pincode when reset is verified
                PinResetRequestManager.sharedInstance.pinResetClear({ (success, nil, message, code) in
                    //Now send user back to pinreset screen, let them enter pincode and password again
                    self.codeInputView.resignFirstResponder()
                    //Update flag
                    setViewControllerToDisplay(ViewControllerTypeString.passcode, key: YonaConstants.nsUserDefaultsKeys.screenToDisplay)
                    self.performSegueWithIdentifier(R.segue.pinResetValidationVC.transToSetPincode, sender: self)
                    self.codeInputView.clear()
                })
            } else {//pin reset verify code is wrong
                self.checkCodeMessageShowAlert(message, serverMessageCode: code, codeInputView: codeInputView)
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: YonaConstants.nsUserDefaultsKeys.isBlocked)
                self.codeInputView.clear()
            }
        })
    }
}

extension PinResetValidationVC: KeyboardProtocol {
    func keyboardWasShown (notification: NSNotification) {
        
        if let activeField = self.resendOTPResetCode, keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
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
