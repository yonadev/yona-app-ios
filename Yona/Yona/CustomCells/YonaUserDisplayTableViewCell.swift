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
    //var theUserModel :Users?
    
    var delegate : YonaUserProfileViewController?
    override func awakeFromNib() {
        theTitleLable.text = ""
        theTextField.text = ""
        
        
    }
    func setData (delegate theDelegate: YonaUserProfileViewController, cellType : ProfileCategoryHeader){
        theCellType = cellType
        //theUserModel = userModel
        delegate = theDelegate
        theTitleLable.text = cellType.headerText()
        theIconImage.image = cellType.imageType()

        switch cellType {
        case ProfileCategoryHeader.FirstName:
            theTextField.text = delegate?.aUser?.firstName
        case ProfileCategoryHeader.LastName:
            theTextField.text = delegate?.aUser?.lastName
        case ProfileCategoryHeader.NickName:
            theTextField.text = delegate?.aUser?.nickname
        case ProfileCategoryHeader.CellNumber:
            theTextField.text = delegate?.aUser?.mobileNumber
        }

    
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        delegate?.userDidStartEdit()
    }
    func textFieldDidEndEditing(textField: UITextField) {
        if let txt = textField.text {
            updateUser(txt)
        }

        delegate?.userDidEndEdit()
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return self.editing
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func updateUser(textToSet :String) {
        switch theCellType! {
        case .FirstName:
            delegate?.aUser?.firstName = textToSet
        case ProfileCategoryHeader.LastName:
            delegate?.aUser?.lastName = textToSet
        case ProfileCategoryHeader.NickName:
            delegate?.aUser?.nickname = textToSet
        case ProfileCategoryHeader.CellNumber:
            delegate?.aUser?.mobileNumber = textToSet
        }
      
    }
    
}