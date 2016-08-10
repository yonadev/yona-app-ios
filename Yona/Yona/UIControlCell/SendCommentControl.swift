//
//  SendCommentControl.swift
//  Yona
//
//  Created by Ben Smith on 04/08/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

class SendCommentControl : UITableViewCell {
    
    var postGoalLink : String?
    
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var sendCommentButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func sendComment(sender: UIButton) {
        if let postGoalLink = postGoalLink {
            let messageBody: [String:AnyObject] = [
                "message": "test"
            ]
            CommentRequestManager.sharedInstance.postComment(postGoalLink, messageBody: messageBody) { (success, comment, message, code) in
                print(comment)
            }
        }
    }
}

extension SendCommentControl: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField == commentTextField {
            IQKeyboardManager.sharedManager().enableAutoToolbar = true
        } else {
            IQKeyboardManager.sharedManager().enableAutoToolbar = false
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == commentTextField) {
            commentTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard(){
        commentTextField.endEditing(true)
    }
}
