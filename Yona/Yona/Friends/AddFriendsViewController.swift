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

class AddFriendsViewController: BaseViewController, UIScrollViewDelegate, UINavigationControllerDelegate, ABPeoplePickerNavigationControllerDelegate {
    
    @IBOutlet var gradientView: GradientView!
    @IBOutlet var manualTabView: UIView!
    @IBOutlet var addressBookTabView: UIView!
    @IBOutlet var manualTabBottomBorder: UIView!
    @IBOutlet var addressBookTabBottomBorder: UIView!
    @IBOutlet var firstnameTextfield: UITextField!
    @IBOutlet var lastnameTextfield: UITextField!
    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var mobileTextfield: UITextField!
    @IBOutlet var inviteFriendButton: UIButton!
    @IBOutlet var screenTitle: UILabel!
    var addressBook: ABAddressBookRef?
    var people = ABPeoplePickerNavigationController()
    var previousRange: NSRange!
    private let nederlandPhonePrefix = "+31 (0) "
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        ManualTabAction(manualTabView)
        self.setupUI()
    }
    
    // MARK: - private functions
    private func setupUI() {
        if var label = previousRange {
            label.length = 1
        }
        
        gradientView.colors = [UIColor.yiMidBlueColor(), UIColor.yiMidBlueColor()]
        
        //Nav bar Back button.
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector.dismissKeyboard)
        self.view.addGestureRecognizer(tap)
        
        //Invite friend button design.
        inviteFriendButton.backgroundColor = UIColor.clearColor()
        inviteFriendButton.layer.cornerRadius = inviteFriendButton.frame.size.height/2
        inviteFriendButton.layer.borderWidth = 1.5
        inviteFriendButton.layer.borderColor = UIColor.yiMidBlueColor().CGColor
        
        // Adding right mode image to text fields
        let firstname = UIImageView(image: R.image.icnName)
        firstname.frame = CGRectMake(0.0, 0.0, firstname.image!.size.width+10.0, firstname.image!.size.height);
        firstname.contentMode = UIViewContentMode.Center
        firstnameTextfield.rightView = firstname;
        firstnameTextfield.rightViewMode = UITextFieldViewMode.Always
        
        let lastname = UIImageView(image: R.image.icnName)
        lastname.frame = CGRectMake(0.0, 0.0, lastname.image!.size.width+10.0, lastname.image!.size.height);
        lastname.contentMode = UIViewContentMode.Center
        lastnameTextfield.rightView = lastname;
        lastnameTextfield.rightViewMode = UITextFieldViewMode.Always
        
        let email = UIImageView(image: R.image.icnMail)
        email.frame = CGRectMake(0.0, 0.0, email.image!.size.width+10.0, email.image!.size.height);
        email.contentMode = UIViewContentMode.Center
        emailTextfield.rightView = email;
        emailTextfield.rightViewMode = UITextFieldViewMode.Always
        
        let mobile = UIImageView(image: R.image.icnMobile)
        mobile.frame = CGRectMake(0.0, 0.0, mobile.image!.size.width+10.0, mobile.image!.size.height);
        mobile.contentMode = UIViewContentMode.Center
        mobileTextfield.rightView = mobile;
        mobileTextfield.rightViewMode = UITextFieldViewMode.Always
        
        //Add textfields array to manage responder
        UITextField.connectFields([firstnameTextfield, lastnameTextfield, emailTextfield, mobileTextfield])
    }
    
    func createAddressBook(){
        
        var error: Unmanaged<CFError>?
        addressBook = ABAddressBookCreateWithOptions(nil, &error).takeRetainedValue()
        
    }
    
    func peoplePickerNavigationController(peoplePicker: ABPeoplePickerNavigationController, didSelectPerson person: ABRecordRef, property: ABPropertyID, identifier: ABMultiValueIdentifier) {
        
        let multiValue: ABMultiValueRef = ABRecordCopyValue(person, property).takeRetainedValue()
        let index = ABMultiValueGetIndexForIdentifier(multiValue, identifier)
        
        //Get Name
        var firstName:String?;
        let firstNameObj = ABRecordCopyValue(person, kABPersonFirstNameProperty);
        
        if(firstNameObj != nil) {
            firstName = firstNameObj.takeRetainedValue() as? String;
        } else {
            firstName = "";
        }
        firstnameTextfield.text = firstName
        
        var lastName:String?;
        let lastNameObj = ABRecordCopyValue(person, kABPersonLastNameProperty);
        if(lastNameObj != nil) {
            lastName = lastNameObj.takeRetainedValue() as? String;
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
            mobileTextfield.text = phoneNumber;
        }
        
        //Get email
        let emails: ABMultiValueRef = ABRecordCopyValue(person, kABPersonEmailProperty).takeRetainedValue()
        if ABMultiValueGetCount(emails) > 0 {
            let index = 0 as CFIndex
            let emailAddress = ABMultiValueCopyValueAtIndex(emails, index).takeRetainedValue() as! String
            emailTextfield.text = emailAddress
        } else {
            emailTextfield.text = ""
        }
        peoplePicker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func peoplePickerNavigationControllerDidCancel(peoplePicker: ABPeoplePickerNavigationController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // Go Back To Previous VC
    @IBAction func back(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func dismissKeyboard(){
        view.endEditing(true)
    }
    
    @IBAction func addNewBuddyButtonTapped(sender: UIButton) {
        if firstnameTextfield.text!.characters.count == 0 {
            self.displayAlertMessage("", alertDescription:
                NSLocalizedString("enter-first-name-validation", comment: ""))
        }
        else if lastnameTextfield.text!.characters.count == 0 {
            self.displayAlertMessage("", alertDescription:
                NSLocalizedString("enter-last-name-validation", comment: ""))
            
        } else if emailTextfield.text!.characters.count == 0 {
            self.displayAlertMessage("", alertDescription:
                NSLocalizedString("enteremailvalidation", comment: ""))
            
        } else if mobileTextfield.text!.characters.count == 0 {
            self.displayAlertMessage("", alertDescription:
                NSLocalizedString("enter-number-validation", comment: ""))
            
            } else {
            var number = ""
            if let mobilenum = mobileTextfield.text {
                number = (nederlandPhonePrefix) + mobilenum
                
                let trimmedWhiteSpaceString = number.removeWhitespace()
                let trimmedString = trimmedWhiteSpaceString.removeBrackets()
                
                if trimmedString.validateMobileNumber() == false {
                    self.displayAlertMessage("", alertDescription:
                        NSLocalizedString("enter-number-validation", comment: ""))
                    
                }

                var number = ""
                if let mobilenum = mobileTextfield.text {
                    number = (nederlandPhonePrefix) + mobilenum
                    
                    let trimmedWhiteSpaceString = number.removeWhitespace()
                    let trimmedString = trimmedWhiteSpaceString.removeBrackets()
                    
                    if trimmedString.validateMobileNumber() == false {
                        self.displayAlertMessage("", alertDescription:
                            NSLocalizedString("enter-number-validation", comment: ""))
                        
                    }
                    let postBuddyBody: [String:AnyObject] = [
                        postBuddyBodyKeys.sendingStatus.rawValue: buddyRequestStatus.REQUESTED.rawValue,
                        postBuddyBodyKeys.receivingStatus.rawValue: buddyRequestStatus.REQUESTED.rawValue,
                        postBuddyBodyKeys.message.rawValue : "Hi there, would you want to become my buddy?",
                        postBuddyBodyKeys.embedded.rawValue: [
                            postBuddyBodyKeys.yonaUser.rawValue: [  //this is the details of the person you are adding
                                addUserKeys.emailAddress.rawValue: emailTextfield.text ?? "",
                                addUserKeys.firstNameKey.rawValue: firstnameTextfield.text ?? "",
                                addUserKeys.lastNameKeys.rawValue: lastnameTextfield.text ?? "",
                                addUserKeys.mobileNumberKeys.rawValue: trimmedString //this is the number of the person you are adding as a buddy
                            ]
                        ]
                    ]
                    
                    BuddyRequestManager.sharedInstance.requestNewbuddy(postBuddyBody, onCompletion: { (success, message, code, buddy, buddies) in
                        
                        if success {
                            self.navigationController?.popViewControllerAnimated(true)
                        } else {
                            if let message = message {
                                self.displayAlertMessage("", alertDescription:message)
                            }
                        }
                    })
                }
            }
        }
    }
    
        func addressbookAccess() {
            switch ABAddressBookGetAuthorizationStatus(){
            case .Authorized:
                print("Already authorized")
                
                createAddressBook()
                people.peoplePickerDelegate = self
                dispatch_async(dispatch_get_main_queue(), {
                    self.presentViewController(self.people, animated: true, completion: nil)
                })
                /* Access the address book */
            case .Denied:
                print("Denied access to address book")
                
            case .NotDetermined:
                createAddressBook()
                if let theBook: ABAddressBookRef = addressBook{
                    ABAddressBookRequestAccessWithCompletion(theBook,
                                                             {(granted: Bool, error: CFError!) in
                                                                
                                                                if granted{
                                                                    print("Access granted")
                                                                    self.people.peoplePickerDelegate = self
                                                                    dispatch_async(dispatch_get_main_queue(), {
                                                                        self.presentViewController(self.people, animated: true, completion: nil)
                                                                    })
                                                                } else {
                                                                    print("Access not granted")
                                                                }
                                                                
                    })
                }
                
            case .Restricted:
                print("Access restricted")
                
            default:
                print("Other Problem")
            }
        }
    }
    
    
    // MARK: Touch Event of Custom Segment
    extension AddFriendsViewController {
        
        @IBAction func ManualTabAction(sender: AnyObject) {
            addressBookTabView.alpha = 0.5
            addressBookTabBottomBorder.hidden = true
            manualTabView.alpha = 1.0
            manualTabBottomBorder.hidden = false
        }
        
        @IBAction func AddressBookTabAction(sender: AnyObject) {
            manualTabView.alpha = 0.5
            manualTabBottomBorder.hidden = true
            addressBookTabView.alpha = 1.0
            addressBookTabBottomBorder.hidden = false
            
            addressbookAccess()
            
        }
    }
    
    
    extension AddFriendsViewController: UITextFieldDelegate {
        
        func textFieldDidBeginEditing(textField: UITextField) {
            if textField == mobileTextfield {
                IQKeyboardManager.sharedManager().enableAutoToolbar = true
            } else {
                IQKeyboardManager.sharedManager().enableAutoToolbar = false
            }
        }
        
        func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
            if (textField == mobileTextfield) {
                if ((previousRange?.location >= range.location) ) {
                    if (textField.text?.utf16.count ?? 0) + string.utf16.count - range.length == YonaConstants.mobilePhoneSpace.mobileFirstSpace || (textField.text?.utf16.count ?? 0) + string.utf16.count - range.length == YonaConstants.mobilePhoneSpace.mobileMiddleSpace {
                        textField.text = String(textField.text!.characters.dropLast())
                    }
                } else  {
                    if (textField.text?.utf16.count ?? 0) + string.utf16.count - range.length ==  YonaConstants.mobilePhoneSpace.mobileFirstSpace || (textField.text?.utf16.count ?? 0) + string.utf16.count - range.length == YonaConstants.mobilePhoneSpace.mobileMiddleSpace {
                        let space = " "
                        
                        textField.text = "\(textField.text!) \(space)"
                    }
                }
                previousRange = range
                
                return (textField.text?.utf16.count ?? 0) + string.utf16.count - range.length <= YonaConstants.mobilePhoneSpace.mobileLastSpace
            }
            return true
        }
    }
    
    private extension Selector {
        static let dismissKeyboard = #selector(AddFriendsViewController.dismissKeyboard)
        static let back = #selector(AddFriendsViewController.back(_:))
}


extension UITextField {
    class func connectFields(fields:[UITextField]) -> Void {
        guard let last = fields.last else {
            return
        }
        for i in 0 ..< fields.count - 1 {
            fields[i].returnKeyType = .Next
            fields[i].addTarget(fields[i+1], action: #selector(UIResponder.becomeFirstResponder), forControlEvents: .EditingDidEndOnExit)
        }
        last.returnKeyType = .Done
        last.addTarget(last, action: #selector(UIResponder.resignFirstResponder), forControlEvents: .EditingDidEndOnExit)
    }
}


