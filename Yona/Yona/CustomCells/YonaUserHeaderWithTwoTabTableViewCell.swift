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
    @IBOutlet weak var avatraInitialsLabel: UILabel!
    
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
        
        avatraInitialsLabel.text = ""
        avatraInitialsLabel.textColor = UIColor.yiWhiteColor()
        
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
        if aMessage.UserRequestfirstName.characters.count > 0 && aMessage.UserRequestlastName.characters.count > 0{
            avatraInitialsLabel.text =  "\(aMessage.UserRequestfirstName.capitalized.characters.first!) \(aMessage.UserRequestlastName.capitalized.characters.first!)"
        }

        
    }
    
    func setUser(_ userModel : Users){
        configureColors(isBuddy: false)
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
   
        if let link = userModel.userAvatarLink,
            let URL = URL(string: link) {
            avatarImageView.kf.setImage(with: URL)
        } else {
            if userModel.firstName.characters.count > 0 && userModel.lastName.characters.count > 0{
                avatraInitialsLabel.text =  "\(userModel.firstName.capitalized.characters.first!) \(userModel.lastName.capitalized.characters.first!)"
            }
        }
        
    }

    
    func setBuddy(_ buddy : Buddies){
        configureColors(isBuddy: true)
        aBuddy = buddy
        var tmpFirst = ""
        var tmpLast = ""
        if let txt = aBuddy?.UserRequestfirstName {
            tmpFirst = txt
        }
        if let txt = aBuddy?.UserRequestlastName {
            tmpLast = txt
        }
        nameLabel.text = "\(tmpFirst) \(tmpLast)"
        if let txt = aBuddy?.buddyNickName {
            nicknameLabel.text = txt
        }
        avatraInitialsLabel.text =  "\(buddy.UserRequestfirstName.capitalized.characters.first!) \(buddy.UserRequestlastName.capitalized.characters.first!)"
        
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
            self.avatraInitialsLabel.alpha = 0.0
            
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
            
            self.avatraInitialsLabel.alpha = 1.0
            self.badgesTabMainView.alpha = 1.0
            self.profileTabMainView.alpha = 1.0
            }, completion: {finished in
                self.badgesTabMainView.isHidden = false
                self.profileTabMainView.isHidden = false
        })
     
     }
    
    
}
