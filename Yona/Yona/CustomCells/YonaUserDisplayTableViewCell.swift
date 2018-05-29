//
//  YonaUserDisplayTableViewCell.swift
//  Yona
//
//  Created by Anders Liebl on 13/06/2016.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

class YonaUserDisplayTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var theTitleLable: UILabel!
    @IBOutlet weak var theTextField: VSTextField!
    @IBOutlet weak var theIconImage: UIImageView!
    
    var theCellType : ProfileCategoryHeader?
    var buddyCellType : FriendsProfileCategoryHeader?
    @IBOutlet var gradientView: GradientSmooth!
    var previousRange: NSRange!
    var delegate : AnyObject?
    override func awakeFromNib() {
        gradientView.setGradientSmooth(UIColor.yiBgGradientTwoColor(), color2: UIColor.yiBgGradientOneColor())
        theTitleLable.text = ""
        theTextField.text = ""
        
    }
    func setActive (){
        theTextField.becomeFirstResponder()
    }
    
    func setBuddyData (delegate theDelegate: AnyObject, cellType : FriendsProfileCategoryHeader){
        buddyCellType = cellType
        //theUserModel = userModel
        delegate = theDelegate
        theTitleLable.text = cellType.headerText()
        theIconImage.image = cellType.imageType()
        if delegate is FriendsProfileViewController {
            let controller = delegate as! FriendsProfileViewController
            theTextField.keyboardType = UIKeyboardType.default
            switch buddyCellType! {
            
            case FriendsProfileCategoryHeader.name:
                var tmpFirst = ""
                if let txt = controller.aUser?.UserRequestfirstName {
                    tmpFirst = txt
                }
                theTextField.text = tmpFirst
            case FriendsProfileCategoryHeader.lastName:
                var tmpLast = ""
                if let txt = controller.aUser?.UserRequestlastName {
                    tmpLast = txt
                }
                theTextField.text = tmpLast
                
            case FriendsProfileCategoryHeader.nickName:
                theTextField.text = controller.aUser?.buddyNickName
            case FriendsProfileCategoryHeader.cellNumber:
                theTextField.formatting = .phoneNumber
                theTextField.text = ""
                theTextField.text = controller.aUser?.formattetMobileNumber
                theTextField.keyboardType = UIKeyboardType.phonePad
            }
            
        }
    }
    
    func setData (delegate theDelegate: AnyObject, cellType : ProfileCategoryHeader){
        theCellType = cellType
        //theUserModel = userModel
        delegate = theDelegate
        theTitleLable.text = cellType.headerText()
        theIconImage.image = cellType.imageType()
        theTextField.keyboardType = UIKeyboardType.default
        if delegate is YonaUserProfileViewController {
            let controller = delegate as! YonaUserProfileViewController
            switch theCellType! {
            case .firstName:
                theTextField.text = controller.aUser?.firstName
            case ProfileCategoryHeader.lastName:
                theTextField.text = controller.aUser?.lastName
            case ProfileCategoryHeader.nickName:
                theTextField.text = controller.aUser?.nickname
            case ProfileCategoryHeader.cellNumber:
                theTextField.text = ""
                theTextField.text = controller.aUser?.formatetMobileNumber
                //theTextField.text = num?.stringByReplacingOccurrencesOfString("+31", withString: nederlandPhonePrefix)
                theTextField.keyboardType = UIKeyboardType.phonePad
            }
        }

    
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if delegate is YonaUserProfileViewController {
            let controller = delegate as! YonaUserProfileViewController
            controller.userDidStartEdit()
        }
        
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let txt = textField.text {
            updateUser(txt)
        }
        if delegate is YonaUserProfileViewController {
            let controller = delegate as! YonaUserProfileViewController
            controller.userDidEndEdit()
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if theCellType == ProfileCategoryHeader.cellNumber {
        // Create a button bar for the number pad
            let keyboardDoneButtonView = UIToolbar()
            keyboardDoneButtonView.sizeToFit()
            
            // Setup the buttons to be put in the system.
            let item1 = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
            let item = UIBarButtonItem(title: NSLocalizedString("Done", comment: "done text"), style: UIBarButtonItemStyle.bordered, target: self, action: #selector(YonaUserDisplayTableViewCell.endEditingNow) )
            item.tintColor = UIColor.yiBlackColor()
            let toolbarButtons = [item1,item]
            
            //Put the buttons into the ToolBar and display the tool bar
            keyboardDoneButtonView.setItems(toolbarButtons, animated: false)
            textField.inputAccessoryView = keyboardDoneButtonView
        } else {
        textField.inputAccessoryView = nil
        }
        return self.isEditing

        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    func updateUser(_ textToSet :String) {
        if delegate is FriendsProfileViewController {
            let controller = delegate as! FriendsProfileViewController
            switch buddyCellType! {
            case .name:
                controller.aUser?.UserRequestfirstName = textToSet
            case .lastName:
                controller.aUser?.UserRequestlastName = textToSet
            case .nickName:
                controller.aUser?.buddyNickName = textToSet
            case .cellNumber:
                controller.aUser?.UserRequestmobileNumber = textToSet
            }
        
        } else if delegate is YonaUserProfileViewController {
            let controller = delegate as! YonaUserProfileViewController
            switch theCellType! {
            case .firstName:
                controller.aUser?.firstName = textToSet
            case ProfileCategoryHeader.lastName:
                controller.aUser?.lastName = textToSet
            case ProfileCategoryHeader.nickName:
                controller.aUser?.nickname = textToSet
            case ProfileCategoryHeader.cellNumber:
                controller.aUser?.mobileNumber = textToSet
            }
        }
    }
    
    //MARK: - Helper Methods
    @objc func endEditingNow(){
        theTextField.resignFirstResponder()
    }
    
    
    
}
