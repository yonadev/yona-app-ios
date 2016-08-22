//
//  ReplyToComment.swift
//  Yona
//
//  Created by Ben Smith on 18/08/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation


class ReplyToComment: CommentControlCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.isPanEnabled = false //turn off delete function
        
    }
 

}
