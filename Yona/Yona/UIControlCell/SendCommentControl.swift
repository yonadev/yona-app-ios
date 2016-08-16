//
//  SendCommentControl.swift
//  Yona
//
//  Created by Ben Smith on 04/08/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

protocol SendCommentControlProtocol {
    func textFieldBeginEdit(textField: UITextField, commentTextField: UITextField)
    func textFieldEndEdit(commentTextField: UITextField)
}

class SendCommentControl : UITableViewCell {
    
    var postGoalLink : String?
    
    var delegate : SendCommentControlProtocol?

    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var sendCommentButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        sendCommentButton.titleLabel!.text = NSLocalizedString("commenting.sendComment", comment: "")
    }
    
    @IBAction func sendComment(sender: UIButton) {
        if let postGoalLink = postGoalLink ,
         let comment = self.commentTextField.text{
            let messageBody: [String:AnyObject] = [
                "message": comment
            ]
            CommentRequestManager.sharedInstance.postComment(postGoalLink, messageBody: messageBody) { (success, comment, nil, message, code) in
                print(comment)
            }
        }
    }
}

extension SendCommentControl: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(textField: UITextField) {
        delegate?.textFieldBeginEdit(textField, commentTextField: commentTextField)
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
        delegate?.textFieldEndEdit(commentTextField)
    }
}
