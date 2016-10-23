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

class SendCommentControl : UIView {
    
    var postCommentLink : String?
    var postReplyLink : String?
    
    var commentControlDelegate : SendCommentControlProtocol?

    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var sendCommentButton: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        nibSetup()
        if let title = sendCommentButton.titleLabel {
            title.text = NSLocalizedString("commenting.sendComment", comment: "")
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        nibSetup()
        
        if let title = sendCommentButton.titleLabel {
            title.text = NSLocalizedString("commenting.sendComment", comment: "")
        }
    }

    private func nibSetup() {
        backgroundColor = .clearColor()
        
        let view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        view.translatesAutoresizingMaskIntoConstraints = true
        
        addSubview(view)
    }
    
    
    private func loadViewFromNib() -> UIView {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: String(self.dynamicType), bundle: bundle)
        let nibView = nib.instantiateWithOwner(self, options: nil).first as! UIView
        
        return nibView
    }
    
    func setLinks(replyLink: String?, commentLink: String?) {
        if replyLink != nil {
            postReplyLink = replyLink
        }
        postCommentLink = commentLink
    }
    
    @IBAction func sendComment(sender: UIButton) {
        weak var tracker = GAI.sharedInstance().defaultTracker
        tracker!.send(GAIDictionaryBuilder.createEventWithCategory("ui_action", action: "sendComment", label: "Send comment button pressed", value: nil).build() as [NSObject : AnyObject])
        
        if let commentText = self.commentTextField.text{
            if commentText.characters.count == 0 {
                return
            }
            var messageBody: [String:AnyObject]
            if let postCommentLink = postCommentLink {
                messageBody = [
                    "message": commentText
                ]
                CommentRequestManager.sharedInstance.postComment(postCommentLink, messageBody: messageBody) { (success, comment, nil, message, code) in
                    if success {
                        self.commentControlDelegate?.textFieldEndEdit(self.commentTextField, comment: comment)
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
                        self.commentControlDelegate?.textFieldEndEdit(self.commentTextField, comment: comment)
                    }
                    print(comment)
                }
            }
        }
    }
}

extension SendCommentControl: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(textField: UITextField) {
        commentControlDelegate?.textFieldBeginEdit(textField, commentTextField: commentTextField)
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
        commentControlDelegate?.textFieldEndEdit(commentTextField, comment: nil)
    }
}
