//
//  YonaUserTableViewCell.swift
//  Yona
//
//  Created by Anders Liebl on 18/06/2016.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

class YonaUserTableViewCell: PKSwipeTableViewCell {
    
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
        addRightViewInCell()
        
    }
    
    func addRightViewInCell() {
        
        //Create a view that will display when user swipe the cell in right
        let viewCall = UIView()
        viewCall.backgroundColor = UIColor.lightGrayColor()
        viewCall.frame = CGRectMake(0,0, 100,100)
        //Add a button to perform the action when user will tap on call and add a image to display
        let btnCall = UIButton(type: UIButtonType.Custom)
        btnCall.frame = CGRectMake(0,0,viewCall.frame.size.width,viewCall.frame.size.height)
        btnCall.setImage(UIImage(named: "icnDelete"), forState: UIControlState.Normal)
//        btnCall.addTarget(self, action: "callButtonClicked", forControlEvents: UIControlEvents.TouchUpInside)
        
        viewCall.addSubview(btnCall)
        //Call the super addRightOptions to set the view that will display while swiping
        super.addRightOptionsView(viewCall)
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
        boldLineLabel.text = aMessage.simpleDescription()
        normalLineLabel.text = "\(aMessage.nickname)"
     
        var tmpFirst = ""
        var tmpLast = ""
        if aMessage.UserRequestfirstName.characters.count > 0 {
            tmpFirst = aMessage.UserRequestfirstName
        }
        if aMessage.UserRequestlastName.characters.count > 0 {
            tmpLast = aMessage.UserRequestlastName
        }
        if tmpFirst.characters.count > 0 && tmpLast.characters.count > 0 {
        // AVATAR NOT Implemented - must check for avatar image when implemented on server
            avatarNameLabel.text = "\(tmpFirst.capitalizedString.characters.first!) \(tmpLast.capitalizedString.characters.first!)"
        }
        
        
        statusImageView.image = aMessage.iconForStatus()
    }

}

