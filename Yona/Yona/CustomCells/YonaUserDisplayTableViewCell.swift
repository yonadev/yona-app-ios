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
    
    var previousRange: NSRange!
    var delegate : AnyObject?
    override func awakeFromNib() {
        theTitleLable.text = ""
        theTextField.text = ""
        
        
    }
    func setBuddyData (delegate theDelegate: AnyObject, cellType : FriendsProfileCategoryHeader){
        buddyCellType = cellType
        //theUserModel = userModel
        delegate = theDelegate
        theTitleLable.text = cellType.headerText()
        theIconImage.image = cellType.imageType()
        if delegate is FriendsProfileViewController {
            let controller = delegate as! FriendsProfileViewController
            theTextField.keyboardType = UIKeyboardType.Default
            switch buddyCellType! {
            
            case FriendsProfileCategoryHeader.Name:
                var tmpFirst = ""
                var tmpLast = ""
                if let txt = controller.aUser?.UserRequestfirstName {
                    tmpFirst = txt
                }
                if let txt = controller.aUser?.UserRequestlastName {
                    tmpLast = txt
                }
                theTextField.text = "\(tmpFirst) \(tmpLast)"
                
            case FriendsProfileCategoryHeader.NickName:
                theTextField.text = controller.aUser?.buddyNickName
            case FriendsProfileCategoryHeader.CellNumber:
                theTextField.formatting = .PhoneNumber
                theTextField.text = ""
                theTextField.text = controller.aUser?.formattetMobileNumber
                theTextField.keyboardType = UIKeyboardType.PhonePad
            }
            
        }
    }
    
    func setData (delegate theDelegate: AnyObject, cellType : ProfileCategoryHeader){
        theCellType = cellType
        //theUserModel = userModel
        delegate = theDelegate
        theTitleLable.text = cellType.headerText()
        theIconImage.image = cellType.imageType()
        theTextField.keyboardType = UIKeyboardType.Default
        if delegate is YonaUserProfileViewController {
            let controller = delegate as! YonaUserProfileViewController
            switch theCellType! {
            case .FirstName:
                theTextField.text = controller.aUser?.firstName
            case ProfileCategoryHeader.LastName:
                theTextField.text = controller.aUser?.lastName
            case ProfileCategoryHeader.NickName:
                theTextField.text = controller.aUser?.nickname
            case ProfileCategoryHeader.CellNumber:
                theTextField.formatting = .PhoneNumber
                theTextField.text = ""
                theTextField.text = controller.aUser?.formatetMobileNumber
                //theTextField.text = num?.stringByReplacingOccurrencesOfString("+31", withString: nederlandPhonePrefix)
                theTextField.keyboardType = UIKeyboardType.PhonePad
            }
        }

    
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if delegate is YonaUserProfileViewController {
            let controller = delegate as! YonaUserProfileViewController
            controller.userDidStartEdit()
        }
        
    }
    func textFieldDidEndEditing(textField: UITextField) {
        if let txt = textField.text {
            updateUser(txt)
        }
        if delegate is YonaUserProfileViewController {
            let controller = delegate as! YonaUserProfileViewController
            controller.userDidEndEdit()
        }
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        if theCellType == ProfileCategoryHeader.CellNumber {
        // Create a button bar for the number pad
            let keyboardDoneButtonView = UIToolbar()
            keyboardDoneButtonView.sizeToFit()
            
            // Setup the buttons to be put in the system.
            let item1 = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil)
            let item = UIBarButtonItem(title: NSLocalizedString("Done", comment: "done text"), style: UIBarButtonItemStyle.Bordered, target: self, action: #selector(YonaUserDisplayTableViewCell.endEditingNow) )
            let toolbarButtons = [item1,item]
            
            //Put the buttons into the ToolBar and display the tool bar
            keyboardDoneButtonView.setItems(toolbarButtons, animated: false)
            textField.inputAccessoryView = keyboardDoneButtonView
        } else {
        textField.inputAccessoryView = nil
        }
        return self.editing

        
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    func updateUser(textToSet :String) {
        if delegate is FriendsProfileViewController {
            let controller = delegate as! FriendsProfileViewController
            switch buddyCellType! {
            case .Name:
                controller.aUser?.UserRequestfirstName = textToSet
            case .NickName:
                controller.aUser?.buddyNickName = textToSet
            case .CellNumber:
                controller.aUser?.UserRequestmobileNumber = textToSet
            }
        
        } else if delegate is YonaUserProfileViewController {
            let controller = delegate as! YonaUserProfileViewController
            switch theCellType! {
            case .FirstName:
                controller.aUser?.firstName = textToSet
            case ProfileCategoryHeader.LastName:
                controller.aUser?.lastName = textToSet
            case ProfileCategoryHeader.NickName:
                controller.aUser?.nickname = textToSet
            case ProfileCategoryHeader.CellNumber:
                controller.aUser?.mobileNumber = textToSet
            }
        }
    }
    
    
    
    //MARK: - Helper Methods
    

    func endEditingNow(){
        theTextField.resignFirstResponder()
    }
    
    
    
}