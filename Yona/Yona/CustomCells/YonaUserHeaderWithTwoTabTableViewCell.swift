//
//  YonaUserHeaderWithTwoTabTableViewCell.swift
//  Yona
//
//  Created by Anders Liebl on 15/06/2016.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation
import Kingfisher

protocol YonaUserHeaderTabProtocol {
    func didSelectProfileTab()
    func didSelectBadgesTab()
    func didAskToAddProfileImage()
}

class YonaUserHeaderWithTwoTabTableViewCell: UITableViewCell {

    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var iconAddAvatarImageView: UIImageView!
    @IBOutlet weak var iconAddAvatarButton: UIButton!
    @IBOutlet weak var avatarInitialsLabel: UILabel!
    
    @IBOutlet weak var profileTabMainView: UIView!
    @IBOutlet weak var profileTabLabel: UILabel!
    @IBOutlet weak var profileTabSelcetionView: UIView!
    
    @IBOutlet weak var badgesTabMainView: UIView!
    @IBOutlet weak var badgesTabSelectionsView: UIView!
    @IBOutlet weak var badgesTabLabel: UILabel!

    
    
    var aUser : Users?
    var aBuddy : Buddies?
    var delegate : YonaUserHeaderTabProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameLabel.text = ""
        nameLabel.textColor = UIColor.yiWhiteColor()
        nicknameLabel.text = ""
        nicknameLabel.textColor = UIColor.yiWhiteColor()
        
        avatarInitialsLabel.text = ""
        avatarInitialsLabel.textColor = UIColor.yiWhiteColor()
        
        profileTabLabel.text = NSLocalizedString("profile.tab.profile", comment: "profileTabLabel")
        badgesTabLabel.text = NSLocalizedString("profile.tab.badges", comment: "badgesTabLabel")
        
        avatarImageView.layer.borderWidth = 3.0
        avatarImageView.layer.masksToBounds = true
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width/2
        
        self.iconAddAvatarButton.frame = avatarImageView.frame
        self.iconAddAvatarButton.isEnabled = false

        iconAddAvatarImageView.alpha = 0.0
        configureColors(isBuddy: false)
        showProfileTab()
        
        // add gestures to tabs
        let profilegesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showProfileTab))
        profileTabMainView.addGestureRecognizer(profilegesture)

        let badgegesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showBadgesTab))
        badgesTabMainView.addGestureRecognizer(badgegesture)

    }
    
    
    func configureColors(isBuddy: Bool = false) {
        if isBuddy {
            self.avatarImageView.layer.borderColor = UIColor.yiWhiteColor().cgColor
            self.avatarImageView.layer.borderWidth = 1.0
            self.avatarImageView.backgroundColor = UIColor.yiWindowsBlueColor()
            contentView.backgroundColor = UIColor.yiWindowsBlueColor()
            profileTabMainView.backgroundColor = UIColor.yiWindowsBlueColor()
            badgesTabMainView.backgroundColor = UIColor.yiWindowsBlueColor()
        } else {
            avatarImageView.layer.borderColor = UIColor.yiGrapeTwoColor().cgColor
            self.avatarImageView.backgroundColor = UIColor.yiGrapeColor()
            contentView.backgroundColor = UIColor.yiGrapeColor()
            profileTabMainView.backgroundColor = UIColor.yiGrapeColor()
            badgesTabMainView.backgroundColor = UIColor.yiGrapeColor()
            self.avatarImageView.layer.borderColor = UIColor.yiWhiteColor().cgColor
            self.avatarImageView.layer.borderWidth = 1.0
        }
    
    }
    
    func setMessage (_ aMessage : Message) {
        configureColors(isBuddy: true)
        nameLabel.text = "\(aMessage.UserRequestfirstName) \(aMessage.UserRequestlastName)"
        nicknameLabel.text = aMessage.nickname
        if aMessage.UserRequestfirstName.count > 0 && aMessage.UserRequestlastName.count > 0{
            avatarInitialsLabel.text =  "\(aMessage.UserRequestfirstName.capitalized.first!) \(aMessage.UserRequestlastName.capitalized.first!)"
        }

        
    }
    
    func setUser(_ userModel : Users){
        configureColors(isBuddy: false)
        aUser = userModel
        if let firstName = aUser?.firstName, let lastName = aUser?.lastName {
            nameLabel.text = "\(firstName) \(lastName)"
        }
        if let nickName = aUser?.nickname {
            nicknameLabel.text = nickName
        }
        if let link = userModel.userAvatarLink, let URL = URL(string: link) {
            avatarImageView.kf.setImage(with: URL)
        } else {
            avatarInitialsLabel.text =  "\(userModel.firstName.capitalized.first!) \(userModel.lastName.capitalized.first!)"
        }
    }

    
    func setBuddy(_ buddy : Buddies){
        configureColors(isBuddy: true)
        aBuddy = buddy
        if let firstName = aBuddy?.UserRequestfirstName, let lastName = aBuddy?.UserRequestlastName {
            nameLabel.text = "\(firstName) \(lastName)"
        }
        if let nickName = aBuddy?.buddyNickName {
            nicknameLabel.text = nickName
        }
        if let link = buddy.buddyAvatarURL, let URL = URL(string: link) {
            avatarImageView.kf.setImage(with: URL)
        } else {
            avatarInitialsLabel.text =  "\(buddy.UserRequestfirstName.capitalized.first!) \(buddy.UserRequestlastName.capitalized.first!)"
        }
    }

    
    @objc func showProfileTab () {
        profileTabLabel.alpha = 1.0
        profileTabSelcetionView.isHidden = false
        
        badgesTabSelectionsView.isHidden = true
        badgesTabLabel.alpha = 0.5
        delegate?.didSelectProfileTab()
    }
    
    @IBAction func showBadgesTab (_ sender : AnyObject) {
        profileTabLabel.alpha = 0.5
        profileTabSelcetionView.isHidden = true
        
        badgesTabSelectionsView.isHidden = false
        badgesTabLabel.alpha = 1.0
        delegate?.didSelectBadgesTab()
    }

    @IBAction func addProfileImage (_ sender : AnyObject) {
        //if self.badgesTabMainView.hidden == true {
            delegate?.didAskToAddProfileImage()
        //}
    }

    
    
    // MARK: - hide both tabs
    
    func setAcceptFriendsMode () {
        profileTabMainView.isHidden = true
        badgesTabMainView.isHidden = true
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
        
        
        UIView.animate(withDuration: 0.2, animations: {
            self.avatarImageView.frame = avatarframe
            self.iconAddAvatarButton.frame = avatarframe
            self.iconAddAvatarButton.isEnabled = true
            self.avatarImageView.alpha = 0.3
            self.nameLabel.alpha = 0.0
            self.nicknameLabel.alpha = 0.0
            self.badgesTabMainView.alpha = 0
            self.profileTabMainView.alpha = 0
            self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width/2
            self.iconAddAvatarImageView.frame = iconframe
            self.iconAddAvatarImageView.alpha = 1.0
            self.avatarInitialsLabel.alpha = 0.0
            
            }, completion: {finished in
                self.badgesTabMainView.isHidden = true
                self.profileTabMainView.isHidden = true
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
        
        
        UIView.animate(withDuration: 0.2, animations: {
            self.avatarImageView.frame = avatarframe
            self.avatarImageView.alpha = 1.0
            self.iconAddAvatarButton.frame = avatarframe
            self.iconAddAvatarButton.isEnabled = false
            self.nameLabel.alpha = 1.0
            self.nicknameLabel.alpha = 1.0
            self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width/2
            self.iconAddAvatarImageView.frame = iconframe
            self.iconAddAvatarImageView.alpha = 0.0
            
            self.avatarInitialsLabel.alpha = 1.0
            self.badgesTabMainView.alpha = 1.0
            self.profileTabMainView.alpha = 1.0
            }, completion: {finished in
                self.badgesTabMainView.isHidden = false
                self.profileTabMainView.isHidden = false
        })
     
     }
    
    
}
