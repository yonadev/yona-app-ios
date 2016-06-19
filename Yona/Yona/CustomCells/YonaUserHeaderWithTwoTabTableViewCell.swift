//
//  YonaUserHeaderWithTwoTabTableViewCell.swift
//  Yona
//
//  Created by Anders Liebl on 15/06/2016.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

protocol YonaUserHeaderTabProtocol {
    func didSelectProfileTab()
    func didSelectBadgesTab()
}

class YonaUserHeaderWithTwoTabTableViewCell: UITableViewCell {

    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var iconAddAvatarImageView: UIImageView!
 
    @IBOutlet weak var profileTabMainView: UIView!
    @IBOutlet weak var profileTabLabel: UILabel!
    @IBOutlet weak var profileTabSelcetionView: UIView!
    
    @IBOutlet weak var badgesTabMainView: UIView!
    @IBOutlet weak var badgesTabSelectionsView: UIView!
    @IBOutlet weak var badgesTabLabel: UILabel!

    var aUser : Users?
    var delegate : YonaUserHeaderTabProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameLabel.text = ""
        nameLabel.textColor = UIColor.yiWhiteColor()
        nicknameLabel.text = ""
        nicknameLabel.textColor = UIColor.yiWhiteColor()
        
        profileTabLabel.text = NSLocalizedString("profile.tab.profile", comment: "profileTabLabel")
        badgesTabLabel.text = NSLocalizedString("profile.tab.badges", comment: "badgesTabLabel")
        
        avatarImageView.layer.borderWidth = 3.0
        avatarImageView.layer.borderColor = UIColor.yiGrapeTwoColor().CGColor
        avatarImageView.layer.masksToBounds = true
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width/2
        
        
        iconAddAvatarImageView.alpha = 0.0
        
        showProfileTab()
        
        // add gestures to tabs
        let profilegesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showProfileTab))
        profileTabMainView.addGestureRecognizer(profilegesture)

        let badgegesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showBadgesTab))
        badgesTabMainView.addGestureRecognizer(badgegesture)

    }
    
    func setData (userModel userModel : Users){
        aUser = userModel
        var tmpFirst = ""
        var tmpLast = ""
        if let txt = aUser?.firstName {
            tmpFirst = txt
        }
        if let txt = aUser?.lastName {
            tmpLast = txt
        }
        nameLabel.text = "\(tmpFirst) \(tmpLast)"
        if let txt = aUser?.nickname {
            nicknameLabel.text = txt
        }
   
    
    }
    
    
    func showProfileTab () {
        profileTabLabel.alpha = 1.0
        profileTabSelcetionView.hidden = false
        
        badgesTabSelectionsView.hidden = true
        badgesTabLabel.alpha = 0.5
        delegate?.didSelectProfileTab()
    }
    @IBAction func showBadgesTab (sender : AnyObject) {
        profileTabLabel.alpha = 0.5
        profileTabSelcetionView.hidden = true
        
        badgesTabSelectionsView.hidden = false
        badgesTabLabel.alpha = 1.0
        delegate?.didSelectBadgesTab()
    }

    
    // MARK:  - edit positioning metods
    
     func setTopViewInEditMode () {
        var avatarframe = avatarImageView.frame
        avatarframe.size.width = 125
        avatarframe.size.height = 125
        avatarframe.origin.y = 50
        avatarframe.origin.x = contentView.frame.size.width/2 - avatarframe.size.width/2
        
        var iconframe = iconAddAvatarImageView.frame
        iconframe.origin.x = avatarframe.origin.x + (avatarframe.size.width/2-iconframe.size.width/2)+5 // 5 is to offset due to image
        iconframe.origin.y = avatarframe.origin.y + (avatarframe.size.height/2-iconframe.size.height/2)
        
        
        UIView.animateWithDuration(0.2, animations: {
            self.avatarImageView.frame = avatarframe
            self.avatarImageView.alpha = 0.3
            self.nameLabel.alpha = 0.0
            self.nicknameLabel.alpha = 0.0
            self.badgesTabMainView.alpha = 0
            self.profileTabMainView.alpha = 0
            self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width/2
            self.iconAddAvatarImageView.frame = iconframe
            self.iconAddAvatarImageView.alpha = 1.0
            }, completion: {finished in
                self.badgesTabMainView.hidden = true
                self.profileTabMainView.hidden = true
        })
     
     }
     
     
     func setTopViewInNormalMode () {
        var avatarframe = avatarImageView.frame
        avatarframe.size.width = 80
        avatarframe.size.height = 80
        avatarframe.origin.y = 9
        avatarframe.origin.x = contentView.frame.size.width/2 - avatarframe.size.width/2
        
        var iconframe = iconAddAvatarImageView.frame
        iconframe.origin.x = avatarframe.origin.x + (avatarframe.size.width/2-iconframe.size.width/2)
        iconframe.origin.y = avatarframe.origin.y + (avatarframe.size.height/2-iconframe.size.height/2)
        
        
        UIView.animateWithDuration(0.2, animations: {
            self.avatarImageView.frame = avatarframe
            self.avatarImageView.alpha = 1.0
            self.nameLabel.alpha = 1.0
            self.nicknameLabel.alpha = 1.0
            self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width/2
            self.iconAddAvatarImageView.frame = iconframe
            self.iconAddAvatarImageView.alpha = 0.0
            
            self.badgesTabMainView.alpha = 1.0
            self.profileTabMainView.alpha = 1.0
            }, completion: {finished in
                self.badgesTabMainView.hidden = false
                self.profileTabMainView.hidden = false
        })
     
     }
    

}