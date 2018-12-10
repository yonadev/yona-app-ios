//
//  CommentControlCell.swift
//  Yona
//
//  Created by Ben Smith on 04/08/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

class CommentControlCell: PKSwipeTableViewCell {
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var replyToComment: UIButton!
    @IBOutlet weak var name: UILabel!

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var avatarNameLabel: UILabel!
    @IBOutlet weak var separator: UIView!
    @IBOutlet weak var replyButtonHeightConstraint: NSLayoutConstraint!
    var comment: Comment?
    var indexPath: IndexPath?

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
        viewCall.frame = CGRect(x: 0,y: 0, width: self.frame.size.height,height: self.frame.size.height)
        //Add a button to perform the action when user will tap on call and add a image to display
        let btnCall = UIButton(type: UIButtonType.custom)
        btnCall.frame = CGRect(x: 0,y: 0,width: viewCall.frame.size.width,height: viewCall.frame.size.height)
        btnCall.setImage(UIImage(named: "icnDelete"), for: UIControlState())
        btnCall.addTarget(self, action: #selector(CommentControlCell.deleteMessage), for: UIControlEvents.touchUpInside)
        avatarImageView.backgroundColor = UIColor.yiGrapeColor()
        viewCall.addSubview(btnCall)
        //Call the super addRightOptions to set the view that will display while swiping
        super.addRightOptionsView(viewCall)
    }
    
    
    @objc func deleteMessage(){
        if let commentDelegate = commentDelegate,
            let comment = comment{
            commentDelegate.deleteComment(self, comment: comment)
        }
    }
    
    func setBuddyCommentData(_ comment: Comment) {
        self.comment = comment
        self.commentLabel.text = comment.message
        self.name.text = comment.nickname
        
        if self.isKind(of: ReplyToComment.self) {
            avatarImageView.backgroundColor = UIColor.yiWindowsBlueColor()
        } else {
            avatarImageView.backgroundColor = UIColor.yiGrapeColor()
        }
        // AVATAR NOT Implemented - must check for avatar image when implemented on server
        
        
        if let nickname = comment.nickname {
            avatarNameLabel.text = "\(nickname.capitalized.characters.first!)"
        }
        
        
        
    }

    func hideShowReplyButton(_ hide: Bool) {
        self.replyToComment.isHidden = hide
        self.separator.isHidden = hide
        if hide {
            replyButtonHeightConstraint.constant = -80
        }
    }
    
    @IBAction func replyToCommentButton(_ sender: UIButton) {
        weak var tracker = GAI.sharedInstance().defaultTracker
        tracker!.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action", action: "replyToCommentButton", label: "Replying to comment button press", value: nil).build() as! [AnyHashable: Any])
        
        commentDelegate?.showSendComment(comment)
    }

}
