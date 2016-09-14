//
//  YonaUserTableViewCell.swift
//  Yona
//
//  Created by Anders Liebl on 18/06/2016.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

protocol YonaUserSwipeCellDelegate {
    func messageNeedToBeDeleted(cell: YonaUserTableViewCell, message: Message);
}

class YonaUserTableViewCell: SHSwippableTableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var avatarNameLabel: UILabel!
    
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var boldLineLabel: UILabel!
    @IBOutlet weak var normalLineLabel: UILabel!

    @IBOutlet weak var statusImageConstraint: NSLayoutConstraint!
    
    var aMessage : Message?
    internal var yonaUserSwipeDelegate:YonaUserSwipeCellDelegate?

    @IBOutlet weak var gradientView: GradientSmooth!

    override func awakeFromNib() {
        
        super.awakeFromNib()
//        gradientView.setGradientSmooth(UIColor.yiBgGradientOneColor(), color2: UIColor.yiBgGradientTwoColor())
//        gradientView.setGradientSmooth(UIColor.yiBgGradientTwoColor(), color2: UIColor.yiBgGradientOneColor())

        boldLineLabel.text = ""
        boldLineLabel.adjustsFontSizeToFitWidth = true
        avatarNameLabel.text = ""
        normalLineLabel.text = ""
        
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.height/2
        avatarImageView.layer.masksToBounds = true

        statusImageView.layer.cornerRadius = statusImageView.frame.size.height/2
        statusImageView.layer.masksToBounds = true

        avatarImageView.backgroundColor = UIColor.yiGrapeColor()
        gradientView.setGradientSmooth(UIColor.yiBgGradientOneColor(), color2: UIColor.yiBgGradientTwoColor())

    }
    
    @IBAction func deleteMessage(sender: UIButton){
        if let yonaUserSwipeDelegate = yonaUserSwipeDelegate,
            let aMessage = aMessage{
            yonaUserSwipeDelegate.messageNeedToBeDeleted(self, message: aMessage)
        }
    }
    
    func setBuddie(aBuddie : Buddies) {
        
        // When showing the Buddy, we move the status to the right of the cell. Autolayout will then extend the size of the nameLabel as well as the nicknameLabel
        statusImageConstraint.constant = -contentView.frame.size.width
        statusImageView.setNeedsLayout()
        
        boldLineLabel.text = "\(aBuddie.UserRequestfirstName) \(aBuddie.UserRequestlastName)"
        normalLineLabel.text = aBuddie.buddyNickName

        // AVATAR NOT Implemented - must check for avatar image when implemented on server
        avatarNameLabel.text = "\(aBuddie.buddyNickName.capitalizedString.characters.first!)"// \(aBuddie.UserRequestlastName.capitalizedString.characters.first!)"

//        avatarNameLabel.text = "\(aBuddie.UserRequestfirstName.capitalizedString.characters.first!)"// \(aBuddie.UserRequestlastName.capitalizedString.characters.first!)"
    }
    
    // MARK: using cell as Message
    
    func setMessage(aMessage : Message) {
        self.aMessage = aMessage
        
        //if the messsage has been accepted can we delete so disable pan
        if aMessage.status == buddyRequestStatus.ACCEPTED || aMessage.status == buddyRequestStatus.REJECTED {
            self.allowsSwipeAction = true
        } else {
            self.allowsSwipeAction = false
        }
        
        boldLineLabel.text = aMessage.simpleDescription()
        normalLineLabel.text = "\(aMessage.nickname)"
     
//        var tmpFirst = ""
//        var tmpLast = ""
        var tmpnickname = ""
        tmpnickname = aMessage.nickname
        if tmpnickname.characters.count > 0 {
            avatarNameLabel.text = "\(tmpnickname.capitalizedString.characters.first!)"
        } else {
            avatarNameLabel.text = ""
        }
        
//        if aMessage.UserRequestfirstName.characters.count > 0 {
//            tmpFirst = aMessage.UserRequestfirstName
//        } else {
//            tmpnickname = aMessage.nickname
//        }
//        if aMessage.UserRequestlastName.characters.count > 0 {
//            tmpLast = aMessage.UserRequestlastName
//        }
//        if tmpFirst.characters.count > 0 && tmpLast.characters.count > 0 {
//            // AVATAR NOT Implemented - must check for avatar image when implemented on server
//            avatarNameLabel.text = "\(tmpFirst.capitalizedString.characters.first!)"//\(tmpLast.capitalizedString.characters.first!)"
//        } else {
  
//        avatarNameLabel.text = "\(tmpnickname.capitalizedString.characters.first!)"
//        }
        
        
        statusImageView.image = aMessage.iconForStatus()
    }

}

