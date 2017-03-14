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

class YonaUserTableViewCell: PKSwipeTableViewCell {
    
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
        boldLineLabel.text = ""
        boldLineLabel.adjustsFontSizeToFitWidth = true
        avatarNameLabel.text = ""
        normalLineLabel.text = ""
        
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.height/2
        avatarImageView.layer.masksToBounds = true

        statusImageView.layer.cornerRadius = statusImageView.frame.size.height/2
        statusImageView.layer.masksToBounds = true

        avatarImageView.backgroundColor = UIColor.yiGrapeColor()
        gradientView.setGradientSmooth(UIColor.yiBgGradientTwoColor(), color2: UIColor.yiBgGradientOneColor())
        self.addRightViewInCell()
    }
    
    
    func addRightViewInCell() {
        
        //Create a view that will display when user swipe the cell in right
        let viewCall = UIView()
        viewCall.backgroundColor = UIColor.yiDarkishPinkColor()
        viewCall.frame = CGRectMake(0,0, self.frame.size.height, self.frame.size.height)
        //Add a button to perform the action when user will tap on call and add a image to display
        let btnCall = UIButton(type: UIButtonType.Custom)
        btnCall.frame = CGRectMake(0,0,viewCall.frame.size.width,viewCall.frame.size.height)
        btnCall.setImage(UIImage(named: "icnDelete"), forState: UIControlState.Normal)
        btnCall.addTarget(self, action: #selector(self.deleteMessage(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        viewCall.addSubview(btnCall)
        //Call the super addRightOptions to set the view that will display while swiping
        super.addRightOptionsView(viewCall)
        self.addSubview(gradientView)
        self.sendSubviewToBack(gradientView)
        
    }
    
    
    @IBAction func deleteMessage(sender: UIButton){
        weak var tracker = GAI.sharedInstance().defaultTracker
        tracker!.send(GAIDictionaryBuilder.createEventWithCategory("ui_action", action: "deleteMessage", label: "Delete notification message", value: nil).build() as [NSObject : AnyObject])
        
        if let yonaUserSwipeDelegate = yonaUserSwipeDelegate,
            let aMessage = aMessage{
            yonaUserSwipeDelegate.messageNeedToBeDeleted(self, message: aMessage)
        }
    }
    
    func setBuddie(aBuddie : Buddies) {
        
        // When showing the Buddy, we move the status to the right of the cell. Autolayout will then extend the size of the nameLabel as well as the nicknameLabel
        statusImageConstraint.constant = -contentView.frame.size.width
        statusImageView.setNeedsLayout()
        avatarImageView.backgroundColor = UIColor.yiGrapeColor()
        
        boldLineLabel.text = "\(aBuddie.UserRequestfirstName) \(aBuddie.UserRequestlastName)"
        let dateString = aBuddie.lastMonitoredActivityDate // change to your date format
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let convertedDate = dateFormatter.dateFromString(dateString!) {
            normalLineLabel.text = timeAgoSinceDate(convertedDate, numericDates: false)
        } else {
            normalLineLabel.text = NSLocalizedString("neverSeenOnline", comment: "")
        }
        

        // AVATAR NOT Implemented - must check for avatar image when implemented on server
        avatarNameLabel.text = "\(aBuddie.buddyNickName.capitalizedString.characters.first!)"// \(aBuddie.UserRequestlastName.capitalizedString.characters.first!)"

//        avatarNameLabel.text = "\(aBuddie.UserRequestfirstName.capitalizedString.characters.first!)"// \(aBuddie.UserRequestlastName.capitalizedString.characters.first!)"
    }
    
    // MARK: using cell as Message
    
    func setMessage(aMessage : Message) {
        self.aMessage = aMessage
        
        //if the messsage has been accepted can we delete so disable pan
        if aMessage.status == buddyRequestStatus.ACCEPTED || aMessage.status == buddyRequestStatus.REJECTED {
            self.isPanEnabled = true
        } else {
            self.isPanEnabled = false
        }
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "HH:mm"
        
        if aMessage.messageType == notificationType.GoalConflictMessage {
            boldLineLabel.text = aMessage.simpleDescription() + " " + aMessage.activityTypeName + " - " + formatter.stringFromDate(aMessage.creationTime)
        } else {
            boldLineLabel.text = aMessage.simpleDescription()
        }
        normalLineLabel.text = "\(aMessage.nickname)"
     
        var tmpnickname = ""
        tmpnickname = aMessage.nickname
        if tmpnickname.characters.count > 0 {
            avatarNameLabel.text = "\(tmpnickname.capitalizedString.characters.first!)"
        } else {
            avatarNameLabel.text = ""
        }
        

        if aMessage.isRead {
            gradientView.setGradientSmooth(UIColor.yiBgGradientOneColor(), color2: UIColor.yiBgGradientTwoColor())
        } else {
            gradientView.setSolid(UIColor.yiMessageUnreadColor())
            
            
        }
        
        statusImageView.image = aMessage.iconForStatus()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        // do nothing
    }
    
    func timeAgoSinceDate(date:NSDate, numericDates:Bool) -> String {
        let calendar = NSCalendar.currentCalendar()
        let now = NSDate()
        let earliest = now.earlierDate(date)
        let latest = (earliest == now) ? date : now
        let components:NSDateComponents = calendar.components([NSCalendarUnit.Minute , NSCalendarUnit.Hour , NSCalendarUnit.Day , NSCalendarUnit.WeekOfYear , NSCalendarUnit.Month , NSCalendarUnit.Year , NSCalendarUnit.Second], fromDate: earliest, toDate: latest, options: NSCalendarOptions())
        
        if (components.day >= 2 && components.day < 5) {
            let lastSeenText = String(format: "%@ %d %@", NSLocalizedString("lastSeen", comment: ""), components.day, NSLocalizedString("daysAgo", comment: ""))
            return lastSeenText
        } else if (components.day == 1){
            let lastSeenText = String(format: "%@ %@", NSLocalizedString("lastSeen", comment: ""),NSLocalizedString("yesterday", comment: ""))
            return lastSeenText
        }else if (components.day < 1){
            let lastSeenText = String(format: "%@ %@", NSLocalizedString("lastSeen", comment: ""),NSLocalizedString("today", comment: ""))
            return lastSeenText
        }  else {
            //Last seen on February 15, 2017
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MMMM dd, yyyy"
            let dateString = dateFormatter.stringFromDate(date)
            let lastSeenText = String(format: "%@ %@", NSLocalizedString("lastSeenOn", comment: ""),dateString)
            return lastSeenText
        }
        
    }
}

