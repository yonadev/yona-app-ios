//
//  CommentControlCell.swift
//  Yona
//
//  Created by Ben Smith on 04/08/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

class CommentControlCell: UITableViewCell {
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var replyToComment: UIButton!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var userImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    func getMessageData(commentLink: String?) {
        CommentRequestManager.sharedInstance.getComments(commentLink!, size: 3, page: 3) { (success, comment, comments, serverMessage, serverCode) in
            if success {
                if comments != nil {
                    for comment in comments! as Array<Comment> {
                        self.commentTextView.text = comment.message
                        self.name.text = comment.nickname
                    }
                }
                
                if let comment = comment {
                    self.commentTextView.text = comment.message
                    self.name.text = comment.nickname
                }
            }
        }
    }

}