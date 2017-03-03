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

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var avatarNameLabel: UILabel!
    @IBOutlet weak var separator: UIView!
    var comment: Comment?
    var indexPath: NSIndexPath?

    override func awakeFromNib() {
        super.awakeFromNib()
        replyToComment.titleLabel?.text = NSLocalizedString("commenting.replyToComment", comment: "")
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.height/2
        avatarImageView.layer.masksToBounds = true
        avatarImageView.backgroundColor = UIColor.yiGrapeColor()
        self.isPanEnabled = false //turn off delete function
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
        btnCall.addTarget(self, action: #selector(CommentControlCell.deleteMessage), forControlEvents: UIControlEvents.TouchUpInside)
        avatarImageView.backgroundColor = UIColor.yiGrapeColor()
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
    
    func setBuddyCommentData(comment: Comment) {
        self.comment = comment
        self.commentTextView.text = comment.message
        self.name.text = comment.nickname
        
        // AVATAR NOT Implemented - must check for avatar image when implemented on server
        if let nickname = comment.nickname {
            avatarNameLabel.text = "\(nickname.capitalizedString.characters.first!)"
        }
        
    }

    func hideShowReplyButton(hide: Bool) {
        self.replyToComment.hidden = hide
        self.separator.hidden = hide
    }
    
    @IBAction func replyToCommentButton(sender: UIButton) {
        weak var tracker = GAI.sharedInstance().defaultTracker
        tracker!.send(GAIDictionaryBuilder.createEventWithCategory("ui_action", action: "replyToCommentButton", label: "Replying to comment button press", value: nil).build() as [NSObject : AnyObject])
        
        commentDelegate?.showSendComment(comment)
    }

}
