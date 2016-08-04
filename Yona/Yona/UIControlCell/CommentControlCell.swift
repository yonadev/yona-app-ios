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
}