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

class SendCommentControl : UITableViewCell {
    
    var postCommentLink : String?
    var postReplyLink : String?
    
    var delegate : SendCommentControlProtocol?

    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var sendCommentButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        sendCommentButton.titleLabel!.text = NSLocalizedString("commenting.sendComment", comment: "")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.setNeedsLayout()
        var fra = self.contentView.frame
        fra.size.width = frame.size.width - 50
        self.contentView.frame = fra
    }
    
    @IBAction func sendComment(sender: UIButton) {
        
        if let commentText = self.commentTextField.text{
            var messageBody: [String:AnyObject]
            if let postCommentLink = postCommentLink {
                messageBody = [
                    "message": commentText
                ]
                CommentRequestManager.sharedInstance.postComment(postCommentLink, messageBody: messageBody) { (success, comment, nil, message, code) in
                    if success {
                        self.delegate?.textFieldEndEdit(self.commentTextField, comment: comment)
                    }
                    print(comment)
                }
            } else if let postReplyLink = postReplyLink{
                messageBody = ["properties":
                    [
                        "message" : commentText
                    ]
                ]
                CommentRequestManager.sharedInstance.postReply(postReplyLink, messageBody: messageBody) { (success, comment, comments, message, code) in
                    if success {
                        self.delegate?.textFieldEndEdit(self.commentTextField, comment: comment)
                    }
                    print(comment)
                }
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
        delegate?.textFieldEndEdit(commentTextField, comment: nil)
    }
}
