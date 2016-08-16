//
//  CommentControlCell.swift
//  Yona
//
//  Created by Ben Smith on 04/08/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

class CommentControlCell: PKSwipeTableViewCell {
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var replyToComment: UIButton!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    var comment: Comment?
    var indexPath: NSIndexPath?

    override func awakeFromNib() {
        super.awakeFromNib()
        replyToComment.titleLabel?.text = NSLocalizedString("commenting.replyToComment", comment: "")
        addRightViewInCell()
        
    }
    
    func addRightViewInCell() {
        
        //Create a view that will display when user swipe the cell in right
        let viewCall = UIView()
        viewCall.backgroundColor = UIColor.yiDarkishPinkColor()
        viewCall.frame = CGRectMake(0,0, self.frame.size.height,self.frame.size.height)
        //Add a button to perform the action when user will tap on call and add a image to display
        let btnCall = UIButton(type: UIButtonType.Custom)
        btnCall.frame = CGRectMake(0,0,viewCall.frame.size.width,viewCall.frame.size.height)
        btnCall.setImage(UIImage(named: "icnDelete"), forState: UIControlState.Normal)
        btnCall.addTarget(self, action: "deleteMessage", forControlEvents: UIControlEvents.TouchUpInside)
        
        viewCall.addSubview(btnCall)
        //Call the super addRightOptions to set the view that will display while swiping
        super.addRightOptionsView(viewCall)
    }
    
    
    func deleteMessage(){
        if let commentDelegate = commentDelegate,
            let comment = comment{
            commentDelegate.deleteComment(self, comment: comment)
        }
    }
    
    func setData(comment: Comment) {
        self.comment = comment
        self.commentTextView.text = comment.message
        self.name.text = comment.nickname
    }

}