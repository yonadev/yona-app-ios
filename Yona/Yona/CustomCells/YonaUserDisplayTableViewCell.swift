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
    @IBOutlet weak var theTextField: UITextField!
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
                theTextField.text = controller.aUser?.UserRequestmobileNumber
            }
            
        }
    }
    
    func setData (delegate theDelegate: AnyObject, cellType : ProfileCategoryHeader){
        theCellType = cellType
        //theUserModel = userModel
        delegate = theDelegate
        theTitleLable.text = cellType.headerText()
        theIconImage.image = cellType.imageType()

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
                theTextField.text = controller.aUser?.mobileNumber
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
        return self.editing
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
//    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
//        if (theCellType == .CellNumber) {
//            if ((previousRange?.location >= range.location) ) {
//                if (textField.text?.utf16.count ?? 0) + string.utf16.count - range.length == YonaConstants.mobilePhoneSpace.mobileFirstSpace || (textField.text?.utf16.count ?? 0) + string.utf16.count - range.length == YonaConstants.mobilePhoneSpace.mobileMiddleSpace {
//                    textField.text = String(textField.text!.characters.dropLast())
//                }
//            } else  {
//                if (textField.text?.utf16.count ?? 0) + string.utf16.count - range.length ==  YonaConstants.mobilePhoneSpace.mobileFirstSpace || (textField.text?.utf16.count ?? 0) + string.utf16.count - range.length == YonaConstants.mobilePhoneSpace.mobileMiddleSpace {
//                    let space = " "
//                    
//                    textField.text = "\(textField.text!) \(space)"
//                }
//            }
//            previousRange = range
//            
//            return (textField.text?.utf16.count ?? 0) + string.utf16.count - range.length <= YonaConstants.mobilePhoneSpace.mobileLastSpace
//        }
//        return true
//    }
//    
    
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
    
}