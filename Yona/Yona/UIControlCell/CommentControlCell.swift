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
        replyToComment.titleLabel?.text = NSLocalizedString("commenting.replyToComment", comment: "")
    }
    
    func setData(comment: Comment) {
        self.commentTextView.text = comment.message
        self.name.text = comment.nickname
    }

}