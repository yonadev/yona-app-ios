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
            CommentRequestManager.sharedInstance.postComment(postGoalLink) { (success, message, code) in
                print(message)
            }
        }
    }
    

}
