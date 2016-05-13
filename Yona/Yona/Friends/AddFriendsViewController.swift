//
//  AddFriendsViewController.swift
//  Yona
//
//  Created by Chandan on 11/05/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

class AddFriendsViewController: UIViewController, UIScrollViewDelegate {
    
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
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        ManualTabAction(manualTabView)
        self.setupUI()
    }
    
    // MARK: - private functions
    private func setupUI() {
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
    
    // Go Back To Previous VC
    @IBAction func back(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func dismissKeyboard(){
        view.endEditing(true)
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

