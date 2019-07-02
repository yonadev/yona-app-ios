
//
//  AddFriendsViewController.swift
//  Yona
//
//  Created by Chandan on 11/05/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit
import AddressBook
import AddressBookUI
import IQKeyboardManagerSwift
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


class AddFriendsViewController: UIViewController, UIScrollViewDelegate, UINavigationControllerDelegate, ABPeoplePickerNavigationControllerDelegate, UIAlertViewDelegate {
    
    @IBOutlet var gradientSmooth: GradientSmooth!
    @IBOutlet var gradientSmooth1: GradientSmooth!
    @IBOutlet var gradientSmooth2: GradientSmooth!
    @IBOutlet var gradientSmooth3: GradientSmooth!

    @IBOutlet var manualTabView: UIView!
    @IBOutlet var addressBookTabView: UIView!
    @IBOutlet var manualTabBottomBorder: UIView!
    @IBOutlet var addressBookTabBottomBorder: UIView!
    @IBOutlet var firstnameTextfield: UITextField!
    @IBOutlet var lastnameTextfield: UITextField!
    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var mobileTextfield: UITextField!
    fileprivate var mobilePrefixTextField: UITextField!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var inviteFriendButton: UIButton!
    @IBOutlet var screenTitle: UILabel!
    var addressBook: ABAddressBook?
    var people = ABPeoplePickerNavigationController()
    var previousRange: NSRange!
    fileprivate let nederlandPhonePrefix = "31"

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        gradientSmooth.setGradientSmooth(UIColor.yiBgGradientTwoColor(), color2: UIColor.yiBgGradientOneColor())
        gradientSmooth1.setGradientSmooth(UIColor.yiBgGradientTwoColor(), color2: UIColor.yiBgGradientOneColor())
        gradientSmooth2.setGradientSmooth(UIColor.yiBgGradientTwoColor(), color2: UIColor.yiBgGradientOneColor())
        gradientSmooth3.setGradientSmooth(UIColor.yiBgGradientTwoColor(), color2: UIColor.yiBgGradientOneColor())
        ManualTabAction(manualTabView)
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "AddFriendsViewController")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as? [AnyHashable: Any])
        ManualTabAction(UIButton())
//        UIToolbar.appearance().tintColor = UIColor.yellowColor()
//        UINavigationBar.appearance().tintColor = UIColor.yellowColor()
//        UINavigationBar.appearance().barTintColor = UIColor.yellowColor()
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.yiWhiteColor(),
                                                            NSAttributedString.Key.font: UIFont(name: "SFUIDisplay-Bold", size: 14)!]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        UIToolbar.appearance().tintColor = UIColor.yellowColor()
//        UINavigationBar.appearance().tintColor = UIColor.yiWhiteColor()
//        UINavigationBar.appearance().barTintColor = UIColor.yiWhiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.yiWhiteColor(),
                                                            NSAttributedString.Key.font: UIFont(name: "SFUIDisplay-Bold", size: 14)!]
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UINavigationBar.appearance().tintColor = UIColor.yiWhiteColor()
        UINavigationBar.appearance().barTintColor = UIColor.yiWhiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.yiWhiteColor(),
                                                            NSAttributedString.Key.font: UIFont(name: "SFUIDisplay-Bold", size: 14)!]
    
        
    //This is an ugly hack to handle the situation where the app returns from the Addresbook, and BaseTabViewController kicks in
    UserDefaults.standard.set(false, forKey: YonaConstants.nsUserDefaultsKeys.fromAddressBook)

    }
    
    // MARK: - private functions
    fileprivate func setupUI() {
        if var label = previousRange {
            label.length = 1
        }
        
        //Nav bar Back button.
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: false)
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector.dismissKeyboard)
        self.view.addGestureRecognizer(tap)
        
        //Invite friend button design.
        inviteFriendButton.backgroundColor = UIColor.clear
        inviteFriendButton.layer.cornerRadius = inviteFriendButton.frame.size.height/2
        inviteFriendButton.layer.borderWidth = 1.5
        inviteFriendButton.layer.borderColor = UIColor.yiMidBlueColor().cgColor
        
        // Adding right mode image to text fields
        let firstname = UIImageView(image: R.image.icnName())
        firstname.frame = CGRect(x: 0.0, y: 0.0, width: firstname.image!.size.width+10.0, height: firstname.image!.size.height);
        firstname.contentMode = UIView.ContentMode.center
        firstnameTextfield.rightView = firstname;
        firstnameTextfield.rightViewMode = UITextField.ViewMode.always
       
        let lastname = UIImageView(image: R.image.icnName())
        lastname.frame = CGRect(x: 0.0, y: 0.0, width: lastname.image!.size.width+10.0, height: lastname.image!.size.height);
        lastname.contentMode = UIView.ContentMode.center
        lastnameTextfield.rightView = lastname;
        lastnameTextfield.rightViewMode = UITextField.ViewMode.always
        
        let email = UIImageView(image: R.image.icnMail())
        email.frame = CGRect(x: 0.0, y: 0.0, width: email.image!.size.width+10.0, height: email.image!.size.height);
        email.contentMode = UIView.ContentMode.center
        emailTextfield.rightView = email;
        emailTextfield.rightViewMode = UITextField.ViewMode.always
        
        let mobile = UIImageView(image: R.image.icnMobile())
        mobile.frame = CGRect(x: 0.0, y: 0.0, width: mobile.image!.size.width+10.0, height: mobile.image!.size.height);
        mobile.contentMode = UIView.ContentMode.center
        mobileTextfield.rightView = mobile;
        mobileTextfield.rightViewMode = UITextField.ViewMode.always

        
        let messageToUser = UIImageView(image: R.image.icnName())
        messageToUser.frame = CGRect(x: 0.0, y: 0.0, width: mobile.image!.size.width+10.0, height: mobile.image!.size.height);
        messageToUser.contentMode = UIView.ContentMode.center
        messageTextfield.rightView = messageToUser;
        messageTextfield.rightViewMode = UITextField.ViewMode.always

        let mobileNumberView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        
        let plusLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        plusLabel.font = UIFont(name: "SFUIDisplay-Regular", size: 11)
        plusLabel.textColor = UIColor.yiBlackColor()
        plusLabel.contentMode = UIView.ContentMode.center
        plusLabel.textAlignment = NSTextAlignment.center
        plusLabel.text = "+"
        
        let prefixTextField = UITextField(frame: CGRect(x: 10, y: 0, width: 40, height: 50))
        prefixTextField.font = UIFont(name: "SFUIDisplay-Regular", size: 11)
        prefixTextField.textColor = UIColor.yiBlackColor()
        prefixTextField.contentMode = UIView.ContentMode.left
        prefixTextField.textAlignment = NSTextAlignment.left
        prefixTextField.text = nederlandPhonePrefix
        prefixTextField.leftView = plusLabel
        prefixTextField.leftViewMode = UITextField.ViewMode.always
        prefixTextField.keyboardType = UIKeyboardType.numberPad
        mobileNumberView.addSubview(prefixTextField)
        self.mobilePrefixTextField = prefixTextField
        self.mobileTextfield.leftView = mobileNumberView
        self.mobilePrefixTextField.delegate = self
        self.mobileTextfield.leftViewMode = UITextField.ViewMode.always
        
        UITextField.connectFields([firstnameTextfield, lastnameTextfield, emailTextfield, mobileTextfield])
        
    }
    
    func createAddressBook(){
        
        var error: Unmanaged<CFError>?
        addressBook = ABAddressBookCreateWithOptions(nil, &error).takeRetainedValue()
        
    }
    
    func peoplePickerNavigationController(_ peoplePicker: ABPeoplePickerNavigationController, didSelectPerson person: ABRecord, property: ABPropertyID, identifier: ABMultiValueIdentifier) {
        
        UINavigationBar.appearance().tintColor = UIColor.black
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.yiWhiteColor(),
                                                            NSAttributedString.Key.font: UIFont(name: "SFUIDisplay-Bold", size: 14)!]
        UINavigationBar.appearance().barTintColor = UIColor.yiWhiteColor()


        
        let multiValue: ABMultiValue = ABRecordCopyValue(person, property).takeRetainedValue()
        let index = ABMultiValueGetIndexForIdentifier(multiValue, identifier)
        
        //Get Name
        var firstName:String?;
        let firstNameObj = ABRecordCopyValue(person, kABPersonFirstNameProperty);
        
        if(firstNameObj != nil) {
            firstName = firstNameObj?.takeRetainedValue() as? String;
        } else {
            firstName = "";
        }
        firstnameTextfield.text = firstName
        
        var lastName:String?;
        let lastNameObj = ABRecordCopyValue(person, kABPersonLastNameProperty);
        if(lastNameObj != nil) {
            lastName = lastNameObj?.takeRetainedValue() as? String;
        } else {
            lastName = "";
        }
        lastnameTextfield.text = lastName
        
        //Get phone number
        var phoneNumber:String?;
        let unmanagedPhones:Unmanaged? = ABRecordCopyValue(person, kABPersonPhoneProperty);
        if(unmanagedPhones != nil) {
            let phoneNumbers = unmanagedPhones?.takeRetainedValue();
            if(ABMultiValueGetCount(phoneNumbers) > 0) {
                phoneNumber = ABMultiValueCopyValueAtIndex(phoneNumbers, index).takeRetainedValue() as? String;
            } else {
                phoneNumber = "";
            }
            if let strippedPhoneNumber = phoneNumber {
                let tempNumber = strippedPhoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
                var index = 9
                if tempNumber.count < 9 {
                    index = tempNumber.count
                }
                index *= -1
                phoneNumber = tempNumber.substring(from: tempNumber.index(tempNumber.endIndex, offsetBy: index))
            }
            
            mobileTextfield.text = phoneNumber;
        }
        
        //Get email
        let emails: ABMultiValue = ABRecordCopyValue(person, kABPersonEmailProperty).takeRetainedValue()
        if ABMultiValueGetCount(emails) > 0 {
            let index = 0 as CFIndex
            let emailAddress = ABMultiValueCopyValueAtIndex(emails, index).takeRetainedValue() as! String
            emailTextfield.text = emailAddress
        } else {
            emailTextfield.text = ""
        }
        UserDefaults.standard.set(true, forKey: YonaConstants.nsUserDefaultsKeys.fromAddressBook)
        peoplePicker.dismiss(animated: true, completion: nil)
    }
    
    func peoplePickerNavigationControllerDidCancel(_ peoplePicker: ABPeoplePickerNavigationController) {
        UINavigationBar.appearance().tintColor = UIColor.yiWhiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white,
                                                            NSAttributedString.Key.font: UIFont(name: "SFUIDisplay-Bold", size: 14)!]
        UINavigationBar.appearance().barTintColor = UIColor.yiWhiteColor()
        //dismissViewControllerAnimated(true, completion: nil)
        UserDefaults.standard.set(true, forKey: YonaConstants.nsUserDefaultsKeys.fromAddressBook)
    }
 
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    @IBAction func addNewBuddyButtonTapped(_ sender: UIButton) {
        weak var tracker = GAI.sharedInstance().defaultTracker
        tracker!.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action", action: "addNewBuddyButtonTapped", label: "Add new buddy button pressed", value: nil).build() as? [AnyHashable: Any])
        
        if firstnameTextfield.text!.count == 0 {
            self.displayAlertMessage("", alertDescription:
                NSLocalizedString("enter-first-name-validation", comment: ""))
        }
        else if lastnameTextfield.text!.count == 0 {
            self.displayAlertMessage("", alertDescription:
                NSLocalizedString("enter-last-name-validation", comment: ""))
            
        } else if !emailTextfield.text!.isValidEmail() {
            self.displayAlertMessage("", alertDescription:
                NSLocalizedString("enteremailvalidation", comment: ""))
            
        } else if mobileTextfield.text!.count == 0 {
            self.displayAlertMessage("", alertDescription:
                NSLocalizedString("enter-number-validation", comment: ""))
            
            } else {
            var number = ""
                if let mobileNum = mobileTextfield.text, let prefix = mobilePrefixTextField.text {
                    number = mobileNum.formatNumber(prefix: prefix)
                    
                    if !number.isValidMobileNumber(){
                        self.displayAlertMessage("", alertDescription:
                            NSLocalizedString("enter-number-validation", comment: ""))
                        return
                    }
                
                    let postBuddyBody: [String:AnyObject] = [
                        postBuddyBodyKeys.sendingStatus.rawValue: buddyRequestStatus.REQUESTED.rawValue as AnyObject,
                        postBuddyBodyKeys.receivingStatus.rawValue: buddyRequestStatus.REQUESTED.rawValue as AnyObject,
                        postBuddyBodyKeys.message.rawValue : messageTextfield.text as AnyObject ,//"Hi there, would you want to become my buddy?",
                        postBuddyBodyKeys.embedded.rawValue: [
                            postBuddyBodyKeys.yonaUser.rawValue: [  //this is the details of the person you are adding
                                addUserKeys.emailAddress.rawValue: emailTextfield.text ?? "",
                                addUserKeys.firstNameKey.rawValue: firstnameTextfield.text ?? "",
                                addUserKeys.lastNameKeys.rawValue: lastnameTextfield.text ?? "",
                                addUserKeys.mobileNumberKeys.rawValue: number //this is the number of the person you are adding as a buddy
                            ]
                        ]as AnyObject
                    ]
                    Loader.Show()
                    BuddyRequestManager.sharedInstance.requestNewbuddy(postBuddyBody, onCompletion: { (success, message, code, buddy, buddies) in
                        
                        if success {
                            self.navigationController?.popViewController(animated: true)
                        } else {
                            Loader.Hide()
                            if let message = message {
                                self.displayAlertMessage("", alertDescription:message)
                            }
                        }
                    })
                }
            }
    }
    
    
    
    func addressbookAccess() {
        switch ABAddressBookGetAuthorizationStatus(){
        case .authorized:
            print("Already authorized")
            
            createAddressBook()
            people.peoplePickerDelegate = self
            DispatchQueue.main.async(execute: {
                self.people.topViewController?.view.backgroundColor = .yiMidBlueColor()
                UINavigationBar.appearance().tintColor = UIColor.yiMidBlueColor()
                UIBarButtonItem.appearance().tintColor = UIColor.yiMidBlueColor()
                self.present(self.people, animated: true, completion: nil)
            })
            /* Access the address book */
        case .denied:
                let alert = UIAlertController(title: NSLocalizedString("addfriend.alert.title.text", comment:""), message: NSLocalizedString("addfriend.alert.text", comment:""), preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alert.addAction(cancelAction)
                let settingsAction = UIAlertAction(title:  NSLocalizedString("addfriend.alert.settings.text", comment:""), style: .default , handler:{(alert : UIAlertAction!) in
                    let settingsURL = UIApplication.openSettingsURLString
                    UIApplication.shared.openURL(URL(string: settingsURL)!)
                    
                })
                alert.addAction(settingsAction)
                present(alert, animated: true, completion:nil )
        case .notDetermined:
            createAddressBook()
            if let theBook: ABAddressBook = addressBook{
                ABAddressBookRequestAccessWithCompletion(theBook,
                                                         {(granted: Bool, error: CFError!) in
                                                            
                                                            if granted{
                                                                print("Access granted")
                                                                self.people.peoplePickerDelegate = self
                                                                UINavigationBar.appearance().tintColor = UIColor.yiMidBlueColor()
                                                                UIBarButtonItem.appearance().tintColor = UIColor.yiMidBlueColor()

                                                                DispatchQueue.main.async(execute: {
                                                                    self.present(self.people, animated: true, completion: nil)
                                                                })
                                                            } else {
                                                                print("Access not granted")
                                                            }
                                                            
                })
            }
            
        case .restricted:
            print("Access restricted")
        }
    }
}


    // MARK: Touch Event of Custom Segment
    extension AddFriendsViewController {
        
        @IBAction func ManualTabAction(_ sender: AnyObject) {
            weak var tracker = GAI.sharedInstance().defaultTracker
            tracker!.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action", action: "ManualTabAction", label: "Tap on a tab", value: nil).build() as? [AnyHashable: Any])
            
            addressBookTabView.alpha = 0.5
            addressBookTabBottomBorder.isHidden = true
            manualTabView.alpha = 1.0
            manualTabBottomBorder.isHidden = false
        }
        
        @IBAction func AddressBookTabAction(_ sender: AnyObject) {
            weak var tracker = GAI.sharedInstance().defaultTracker
            tracker!.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action", action: "AddressBookTabAction", label: "Tap on a tab", value: nil).build() as? [AnyHashable: Any])
            
            manualTabView.alpha = 0.5
            manualTabBottomBorder.isHidden = true
            addressBookTabView.alpha = 1.0
            addressBookTabBottomBorder.isHidden = false
            
            addressbookAccess()
            
        }
    }
    
    // MARK: UITextFieldDelegate
    extension AddFriendsViewController: UITextFieldDelegate {
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            if textField == mobileTextfield {
                IQKeyboardManager.shared.enableAutoToolbar = true
            } else {
                IQKeyboardManager.shared.enableAutoToolbar = false
            }
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            if (textField == mobileTextfield) {
                if ((previousRange?.location >= range.location) ) {
                    if (textField.text?.utf16.count ?? 0) + string.utf16.count - range.length == YonaConstants.mobilePhoneSpace.mobileFirstSpace || (textField.text?.utf16.count ?? 0) + string.utf16.count - range.length == YonaConstants.mobilePhoneSpace.mobileMiddleSpace {
                        textField.text = String(textField.text!.dropLast())
                    }
                } else  {
                    if (textField.text?.utf16.count ?? 0) + string.utf16.count - range.length ==  YonaConstants.mobilePhoneSpace.mobileFirstSpace || (textField.text?.utf16.count ?? 0) + string.utf16.count - range.length == YonaConstants.mobilePhoneSpace.mobileMiddleSpace {
                        let space = " "
                        
                        textField.text = "\(textField.text!) \(space)"
                    }
                }
                previousRange = range
                
                //The size limitation setting is only for Netherland's number, As it was already implemented.. No limit for another country
                if (mobilePrefixTextField.text == nederlandPhonePrefix) {
                    return (textField.text?.utf16.count ?? 0) + string.utf16.count - range.length <= YonaConstants.mobilePhoneSpace.mobileLastSpace
                } else {
                    return true
                }
            } else if (textField == mobilePrefixTextField) {
                return (textField.text?.utf16.count ?? 0) + string.utf16.count - range.length <= YonaConstants.mobilePhoneLength.prefix
            }
            return true
        }
}

    private extension Selector {
        static let dismissKeyboard = #selector(AddFriendsViewController.dismissKeyboard)
}


extension UITextField {
    class func connectFields(_ fields:[UITextField]) -> Void {
        guard let last = fields.last else {
            return
        }
        for i in 0 ..< fields.count - 1 {
            fields[i].returnKeyType = .next
            fields[i].addTarget(fields[i+1], action: #selector(UIResponder.becomeFirstResponder), for: .editingDidEndOnExit)
        }
        last.returnKeyType = .done
        last.addTarget(last, action: #selector(UIResponder.resignFirstResponder), for: .editingDidEndOnExit)
    }
}


