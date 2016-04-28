//
//  LoginViewController.swift
//  Yona
//
//  Created by Chandan on 05/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet var codeView:UIView!
    @IBOutlet var infoLabel: UILabel!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var pinResetButton: UIButton!
    @IBOutlet var errorLabel: UILabel!
    
    private var colorX : UIColor = UIColor.yiWhiteColor()
    var posi:CGFloat = 0.0
    var loginAttempts:Int = 1
    private var codeInputView: CodeInputView?
    private var totalAttempts : Int = 5
    @IBOutlet var gradientView: GradientView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Nav bar Back button.
        self.navigationItem.hidesBackButton = true
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        dispatch_async(dispatch_get_main_queue(), {
            self.gradientView.colors = [UIColor.yiGrapeTwoColor(), UIColor.yiGrapeTwoColor()]
        })
        
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.pinResetButton.enabled = false
        codeInputView = CodeInputView(frame: CGRect(x: 0, y: 0, width: 260, height: 55))
        
        if codeInputView != nil {
            codeInputView!.delegate = self
            codeInputView?.secure = true
            codeView.addSubview(codeInputView!)
            
            codeInputView!.becomeFirstResponder()
        }
        
        if NSUserDefaults.standardUserDefaults().boolForKey(YonaConstants.nsUserDefaultsKeys.isBlocked) {
            self.displayAlertMessage("Login", alertDescription: NSLocalizedString("login.user.errorinfoText", comment: ""))
            codeInputView!.resignFirstResponder()
            codeInputView!.userInteractionEnabled = false
            errorLabel.hidden = false
            errorLabel.text = NSLocalizedString("login.user.errorinfoText", comment: "")
            self.pinResetButton.enabled = true
            return;
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


extension LoginViewController: KeyboardProtocol {
    func keyboardWasShown (notification: NSNotification) {
        
        let viewHeight = self.view.frame.size.height
        let info : NSDictionary = notification.userInfo!
        let keyboardSize: CGSize = info.objectForKey(UIKeyboardFrameBeginUserInfoKey)!.CGRectValue.size
        let keyboardInset = keyboardSize.height - viewHeight/3
        
        
        let  pos = (pinResetButton?.frame.origin.y)! + (pinResetButton?.frame.size.height)!
        
        
        if (pos > (viewHeight-keyboardSize.height)) {
            scrollView.setContentOffset(CGPointMake(0, pos-(viewHeight-keyboardSize.height)), animated: true)
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

extension LoginViewController: CodeInputViewDelegate {
    func codeInputView(codeInputView: CodeInputView, didFinishWithCode code: String) {
        let passcode = KeychainManager.sharedInstance.getPINCode()
        if code ==  passcode {
            codeInputView.resignFirstResponder()
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setBool(false, forKey: YonaConstants.nsUserDefaultsKeys.isBlocked)
            if let dashboardStoryboard = R.storyboard.dashboard.dashboardStoryboard {
                navigationController?.pushViewController(dashboardStoryboard, animated: true)
            }
        } else {
            errorLabel.hidden = false
            codeInputView.clear()
            if loginAttempts == totalAttempts {
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setBool(true, forKey: YonaConstants.nsUserDefaultsKeys.isBlocked)
                defaults.synchronize()
                self.displayAlertMessage("Login", alertDescription: NSLocalizedString("login.user.errorinfoText", comment: ""))
                codeInputView.userInteractionEnabled = false
                codeInputView.resignFirstResponder()
                errorLabel.hidden = false
                errorLabel.text = NSLocalizedString("login.user.errorinfoText", comment: "")
                self.pinResetButton.enabled = true
            }
            else {
                loginAttempts += 1
            }
        }
    }
    
    
    @IBAction func pinResetTapped(sender: UIButton) {
        if NSUserDefaults.standardUserDefaults().boolForKey(YonaConstants.nsUserDefaultsKeys.isBlocked) {
            
            APIServiceManager.sharedInstance.pinResetRequest({ (success, pincode, message, code) in
                if success{
                    print(pincode!)
                    if pincode != nil {
                        
                        let timeToDisplay = self.convertFromISO8601Duration(pincode)
                        if Int(timeToDisplay!)! > 0 {
                            let localizedString = NSLocalizedString("login.user.pinResetReuestAlert", comment: "")
                            let alert = NSString(format: localizedString, timeToDisplay!)
                            
                            self.displayAlertMessage("", alertDescription: String(alert))
                            
                        } else {
                            //get otp sent again
                            APIServiceManager.sharedInstance.otpResendMobile{ (success, message, code) in
                                if success {
                                    dispatch_async(dispatch_get_main_queue(), {
                                        //Update flag
                                        self.errorLabel.hidden = true
                                        self.loginAttempts = 0
                                        setViewControllerToDisplay("SMSValidation", key: YonaConstants.nsUserDefaultsKeys.screenToDisplay)
                                        
                                        if let sMSValidation = R.storyboard.sMSValidation.sMSValidationViewController {
                                            self.navigationController?.pushViewController(sMSValidation, animated: false)
                                        }
                                    })
                                    
                                }
                            }
                        }
                    }
                } else {
                    //TODO: Will change this after this build
                    self.displayAlertMessage("Error", alertDescription: "User not found")
                }
            })
            
        }
    }
}

private extension Selector {
    static let keyboardWasShown = #selector(LoginViewController.keyboardWasShown(_:))
    
    static let keyboardWillBeHidden = #selector(LoginViewController.keyboardWillBeHidden(_:))
    static let pinResetTapped = #selector(LoginViewController.pinResetTapped(_:))
}

extension LoginViewController {
    func convertFromISO8601Duration(isoValue: String?) -> String? {
        
        var displayedString: String?
        var hasHitTimeSection = false
        var isSingular = false
        
        var hours = 0
        var days = 0
        
        if let isoString = isoValue {
            
            displayedString = String()
            
            for val in isoString.characters {
                
                if val == "P" {
                    // Do nothing when parsing the 'P'
                    continue
                    
                }else if val == "T" {
                    // Indicate that we are now dealing with the 'time section' of the ISO8601 duration, then carry on.
                    hasHitTimeSection = true
                    continue
                }
                
                var tempString = String()
                
                if val >= "0" && val <= "9" {
                    
                    // We need to know whether or not the value is singular ('1') or not ('11', '23').
                    if let safeDisplayedString = displayedString as String!
                        where displayedString!.characters.count > 0 && val == "1" {
                        
                        let lastIndex = safeDisplayedString.characters.count - 1
                        
                        let lastChar = safeDisplayedString[safeDisplayedString.startIndex.advancedBy(lastIndex)]
                        
                        //test if the current last char in the displayed string is a space (" "). If it is then we will say it's singular until proven otherwise.
                        if lastChar == " " {
                            isSingular = true
                        } else {
                            isSingular = false
                        }
                    }
                    else if val == "1" {
                        // if we are just dealing with a '1' then we will say it's singular until proven otherwise.
                        isSingular = true
                    }
                    else {
                        // ...otherwise it's a plural duration.
                        isSingular = false
                    }
                    
                    tempString += "\(val)"
                    
                    displayedString! += tempString
                    
                } else {
                    
                    // handle the duration type text. Make sure to use Months & Minutes correctly.
                    switch val {
                        
                    case "Y", "y":
                        
                        if isSingular {
                            tempString += " Year "
                        } else {
                            tempString += " Years "
                        }
                        
                        break
                        
                    case "M", "m":
                        
                        if hasHitTimeSection {
                            
                            if isSingular {
                                tempString += " Minute "
                            } else {
                                tempString += " Minutes "
                            }
                        }
                        else {
                            
                            if isSingular {
                                tempString += " Month "
                            } else {
                                tempString += " Months "
                            }
                        }
                        
                        break
                        
                    case "W", "w":
                        
                        if isSingular {
                            tempString += " Week "
                        } else {
                            tempString += " Weeks "
                        }
                        
                        break
                        
                    case "D", "d":
                        
                        if isSingular {
                            tempString += " Day "
                        } else {
                            tempString += " Days "
                        }
                        days = Int(displayedString!)!
                        break
                        
                    case "H", "h":
                        
                        if isSingular {
                            tempString += " Hour "
                        } else {
                            tempString += " Hours "
                        }
                        hours = Int(displayedString!)!
                        break
                        
                    case "S", "s":
                        
                        if isSingular {
                            tempString += " Second "
                        } else {
                            tempString += " Seconds "
                        }
                        
                        break
                        
                    default:
                        break
                        
                    }
                    // reset our singular flag, since we're starting a new duration.
                    isSingular = false
                }
            }
        }
        let timeToDisplay = String(hours + (days * 24))
        return timeToDisplay
    }

}
