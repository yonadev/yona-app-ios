//
//  SendCommentControlFooter.swift
//  Yona
//
//  Created by Ben Smith on 17/08/16.
//  Copyright © 2016 Yona. All rights reserved.
//

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
    func textFieldEndEdit(commentTextField: UITextField, comment: Comment?)
}

class SendCommentControlFooter : UITableViewHeaderFooterView {
    
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
            let commentText = self.commentTextField.text{
            let messageBody: [String:AnyObject] = [
                "message": commentText
            ]
            CommentRequestManager.sharedInstance.postComment(postGoalLink, messageBody: messageBody) { (success, comment, nil, message, code) in
                if success {
                    self.delegate?.textFieldEndEdit(self.commentTextField, comment: comment)
                }
                print(comment)
            }
        }
    }
}

extension SendCommentControlFooter: UITextFieldDelegate {
    
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
        delegate?.textFieldEndEdit(commentTextField, comment: nil)
    }
}
