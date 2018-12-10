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
    var pinResetCountDownTimer: Timer?
    var pinResetCountDownStartTime : Date?
    
    @IBOutlet weak var pinResetCountDownContainer: UIView!
    @IBOutlet weak var remainingHoursLabel: UILabel!
    @IBOutlet weak var remainingMinutesLabel: UILabel!
    @IBOutlet weak var remainingSecondsLabel: UILabel!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "PinResetValidationVC")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as! [AnyHashable: Any])
        
        setBackgroundColour()
        displayPincodeRemainingMessage()
        self.codeInputView.delegate = self
        self.codeInputView.secure = true
        codeView.addSubview(self.codeInputView)
        codeView.resignFirstResponder()
        //keyboard functions
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: Selector.keyboardWasShown, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        notificationCenter.addObserver(self, selector: Selector.keyboardWillBeHidden, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        if !(pinResetCountDownTimer?.isValid)! {
            codeInputView.becomeFirstResponder()
            headerTitleLabel.text = NSLocalizedString("login-accountBlocked-title", comment:"")
            infoLabel.text = NSLocalizedString("smsvalidation.user.infomessage", comment:"")
        }
    }
    
    @IBAction func resendPinResetRequestOTPCode(_ sender: UIButton) {
        Loader.Show()
        
        weak var tracker = GAI.sharedInstance().defaultTracker
        tracker!.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action", action: "resendPinResetRequestOTPCode", label: "Resend the OTP pin reset code", value: nil).build() as! [AnyHashable: Any])
        
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
        guard let timeISOCode = UserDefaults.standard.value(forKey: YonaConstants.nsUserDefaultsKeys.timeToPinReset) as? String else {
            return
        }
        
        let userInfo = NSMutableDictionary()
        let (hours, minutes, seconds) = timeISOCode.convertFromISO8601Duration()
        userInfo["hours"] = hours
        userInfo["minutes"] = minutes
        userInfo["seconds"] = seconds
        pinResetCountDownTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(PinResetValidationVC.executePinResetCounter(_:)), userInfo: userInfo, repeats: true)
        
        executePinResetCounter(pinResetCountDownTimer!)

        headerTitleLabel.text = NSLocalizedString("smsvalidation.wait.headerTitle", comment:"")// "Je moet even wachten"
        infoLabel.text = NSLocalizedString("smsvalidation.user.countdownmessage", comment:"") //"Om veiligheidsredenen is je account geblokkeerd. Activeren kan 24 uur nadat je een nieuwe PIN code hebt aangevraagd."

    }
    
    @objc func executePinResetCounter(_ timer: Timer)
    {
        let userInfo = timer.userInfo! as! NSDictionary
        let hours = userInfo["hours"]! as! Int
        let minutes = userInfo["minutes"]! as! Int
        let seconds = userInfo["seconds"]! as! Int
        
        if(pinResetCountDownStartTime == nil){
            if let startDate = UserDefaults.standard.value(forKey: YonaConstants.nsUserDefaultsKeys.timeToPinResetInitialRequestTime) as? Date{
                pinResetCountDownStartTime = startDate
            }else{
                pinResetCountDownStartTime = Date()
            }
            
        }
        updateRemainingMessageForCountDown(hours, minutes: minutes, seconds: seconds)
    }
    
    func updateRemainingMessageForCountDown(_ hours: Int, minutes: Int, seconds: Int)
    {
        
        let second = Int(1)
        let minute = Int(second * 60)
        let hour = Int(minute * 60)
        
        var remainingHours = hours
        var remainingMinutes = minutes
        var remainingSeconds = seconds
        
        let diff = Int(abs(pinResetCountDownStartTime!.timeIntervalSinceNow))
        let totalremain = hours*hour+minutes*minute+seconds
        let master = Double(diff - totalremain)
    
        let differenceSeconds = Double(abs(diff - totalremain))
        let days = Int(differenceSeconds/(3600.0*24.00))
        let diffDay = differenceSeconds-(Double(days)*3600*24)
        let h=Int(diffDay/3600.00)
        let diffMin=diffDay-(Double(h)*3600.0)
        let m=Int(diffMin/60.0)
        let s=Int(diffMin-(Double(m)*60))

        
    remainingHours = h
    remainingMinutes = m
    remainingSeconds = s
    if (remainingHours > 0 || remainingMinutes > 0 || remainingSeconds > 0) && master < 0{
            //update our labels...
            codeView.isHidden = true
            resendOTPResetCode.isHidden = true
            pinResetCountDownContainer.isHidden = false
            remainingHoursLabel.text = "\(remainingHours)"
            remainingMinutesLabel.text = "\(remainingMinutes)"
            remainingSecondsLabel.text = "\(remainingSeconds)"
        }else{
            //allow the user to enter his pin code
            headerTitleLabel.text = NSLocalizedString("smsvalidation.user.headerTitle", comment:"")
            infoLabel.text = NSLocalizedString("smsvalidation.user.infomessage", comment:"")
            pinResetCountDownContainer.isHidden = true
            codeView.isHidden = false
            resendOTPResetCode.isHidden = false
            pinResetCountDownTimer?.invalidate()
            codeInputView.becomeFirstResponder()
        }
        
    }
}

extension PinResetValidationVC: CodeInputViewDelegate {
    
    func codeInputView(_ codeInputView: CodeInputView, didFinishWithCode code: String) {
        self.codeInputView.isUserInteractionEnabled = true
        let body = ["code": code]
        Loader.Show()
        PinResetRequestManager.sharedInstance.pinResetVerify(body as BodyDataDictionary, onCompletion: { (success, nil, message, code) in
            Loader.Hide()
            if success {
                //pin verify succeeded, unblock app
                UserDefaults.standard.set(false, forKey: YonaConstants.nsUserDefaultsKeys.isBlocked)
                //clear pincode when reset is verified
                PinResetRequestManager.sharedInstance.pinResetClear({ (success, nil, message, code) in
                    //Now send user back to pinreset screen, let them enter pincode and password again
                    self.codeInputView.resignFirstResponder()
                    //Update flag
                    setViewControllerToDisplay(ViewControllerTypeString.passcode, key: YonaConstants.nsUserDefaultsKeys.screenToDisplay)
                    self.performSegue(withIdentifier: R.segue.pinResetValidationVC.transToSetPincode, sender: self)
                    self.codeInputView.clear()
                })
            } else {//pin reset verify code is wrong
                self.checkCodeMessageShowAlert(message, serverMessageCode: code, codeInputView: codeInputView)
                UserDefaults.standard.set(true, forKey: YonaConstants.nsUserDefaultsKeys.isBlocked)
                self.codeInputView.clear()
            }
        })
    }
}

extension PinResetValidationVC: KeyboardProtocol {
    func keyboardWasShown (_ notification: Notification) {
        
        if let activeField = self.resendOTPResetCode, let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
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
