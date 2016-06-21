//
//  YonaUserTableViewCell.swift
//  Yona
//
//  Created by Anders Liebl on 18/06/2016.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

class YonaUserTableViewCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var avatarNameLabel: UILabel!
    
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var boldLineLabel: UILabel!
    @IBOutlet weak var normalLineLabel: UILabel!

    @IBOutlet weak var statusImageConstraint: NSLayoutConstraint!


    override func awakeFromNib() {
        
        boldLineLabel.text = ""
        avatarNameLabel.text = ""
        normalLineLabel.text = ""
        
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.height/2
        avatarImageView.layer.masksToBounds = true

        statusImageView.layer.cornerRadius = statusImageView.frame.size.height/2
        statusImageView.layer.masksToBounds = true

        avatarImageView.backgroundColor = UIColor.yiGrapeColor()
        
        
    }
    
    func setBuddie(aBuddie : Buddies) {
        
        // When showing the Buddy, we move the status to the right of the cell. Autolayout will then extend the size of the nameLabel as well as the nicknameLabel
        statusImageConstraint.constant = -contentView.frame.size.width
        statusImageView.setNeedsLayout()
        
        boldLineLabel.text = "\(aBuddie.UserRequestfirstName) \(aBuddie.UserRequestlastName)"
        normalLineLabel.text = aBuddie.buddyNickName

        // AVATAR NOT Implemented - must check for avatar image when implemented on server
        avatarNameLabel.text = "\(aBuddie.UserRequestfirstName.capitalizedString.characters.first!) \(aBuddie.UserRequestlastName.capitalizedString.characters.first!)"
        
        
        
    }
    
    // MARK: using cell as Message
    
    func setMessage(aMessage : Message) {
        boldLineLabel.text = aMessage.messageType.simpleDescription()
        normalLineLabel.text = "\(aMessage.UserRequestfirstName) \(aMessage.UserRequestlastName)"
        
        // AVATAR NOT Implemented - must check for avatar image when implemented on server
//        avatarNameLabel.text = "\(aMessage.UserRequestfirstName.capitalizedString.characters.first!) \(aMessage.UserRequestlastName.capitalizedString.characters.first!)"
        
        
        statusImageView.image = aMessage.messageType.iconForStatus()
    }

}

