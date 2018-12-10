//
//  SendCommentControl.swift
//  Yona
//
//  Created by Ben Smith on 04/08/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

protocol SendCommentControlProtocol {
    func textFieldBeginEdit(_ textField: UITextField, commentTextField: UITextField)
    func textFieldEndEdit(_ commentTextField: UITextField, comment: Comment?)
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

    fileprivate func nibSetup() {
        backgroundColor = .clear
        
        let view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.translatesAutoresizingMaskIntoConstraints = true
        
        addSubview(view)
    }
    
    
    fileprivate func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let nibView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        
        return nibView
    }
    
    func setLinks(_ replyLink: String?, commentLink: String?) {
        if replyLink != nil {
            postReplyLink = replyLink
        }
        postCommentLink = commentLink
    }
    
    @IBAction func sendComment(_ sender: UIButton) {
        
        weak var tracker = GAI.sharedInstance().defaultTracker
        tracker!.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action", action: "sendComment", label: "Send comment button pressed", value: nil).build() as! [AnyHashable: Any])
        
        if let commentText = self.commentTextField.text{
            if commentText.characters.count == 0 {
                return
            }
            
            sender.isEnabled = false
            var messageBody: [String:AnyObject]
            if let postCommentLink = postCommentLink {
                messageBody = [
                    "message": commentText as AnyObject
                ]
                CommentRequestManager.sharedInstance.postComment(postCommentLink, messageBody: messageBody) { (success, comment, nil, message, code) in
                    
                    if let _ = message {
                        sender.isEnabled = true
                    }
                    
                    if success {
                        sender.isEnabled = true
                        self.commentControlDelegate?.textFieldEndEdit(self.commentTextField, comment: comment)
                    }
                    print(comment)
                }
            } else if let postReplyLink = postReplyLink{
                messageBody = ["properties":
                    [
                        "message" : commentText
                    ]
                    ] as [String : AnyObject]
                CommentRequestManager.sharedInstance.postReply(postReplyLink, messageBody: messageBody) { (success, comment, comments, message, code) in
                    
                    if let _ = message {
                        sender.isEnabled = true
                    }
                    
                    if success {
                        sender.isEnabled = true
                        self.commentControlDelegate?.textFieldEndEdit(self.commentTextField, comment: comment)
                    }
                    print(comment)
                }
            }
        }
    }
}

extension SendCommentControl: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        commentControlDelegate?.textFieldBeginEdit(textField, commentTextField: commentTextField)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard(){
        commentControlDelegate?.textFieldEndEdit(commentTextField, comment: nil)
    }
}
