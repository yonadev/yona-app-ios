//
//  YonaUserTableViewCell.swift
//  Yona
//
//  Created by Anders Liebl on 18/06/2016.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

protocol YonaUserSwipeCellDelegate {
    func messageNeedToBeDeleted(_ cell: YonaUserTableViewCell, message: Message);
}

class YonaUserTableViewCell: PKSwipeTableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var avatarNameLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var boldLineLabel: UILabel!
    @IBOutlet weak var normalLineLabel: UILabel!
    @IBOutlet weak var statusImageConstraint: NSLayoutConstraint!
    @IBOutlet weak var gradientView: GradientSmooth!

    var aMessage : Message?
    internal var yonaUserSwipeDelegate:YonaUserSwipeCellDelegate?

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
        viewCall.frame = CGRect(x: 0,y: 0, width: self.frame.size.height, height: self.frame.size.height)
        //Add a button to perform the action when user will tap on call and add a image to display
        let btnCall = UIButton(type: UIButtonType.custom)
        btnCall.frame = CGRect(x: 0,y: 0,width: viewCall.frame.size.width,height: viewCall.frame.size.height)
        btnCall.setImage(UIImage(named: "icnDelete"), for: UIControlState())
        btnCall.addTarget(self, action: #selector(self.deleteMessage(_:)), for: UIControlEvents.touchUpInside)
        
        viewCall.addSubview(btnCall)
        //Call the super addRightOptions to set the view that will display while swiping
        super.addRightOptionsView(viewCall)        
    }
    
    @IBAction func deleteMessage(_ sender: UIButton){
        weak var tracker = GAI.sharedInstance().defaultTracker
        tracker!.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action", action: "deleteMessage", label: "Delete notification message", value: nil).build() as! [AnyHashable: Any])
        
        if let yonaUserSwipeDelegate = yonaUserSwipeDelegate,
            let aMessage = aMessage{
            yonaUserSwipeDelegate.messageNeedToBeDeleted(self, message: aMessage)
        }
    }
    
    func setBuddie(_ aBuddie : Buddies) {
        // When showing the Buddy, we move the status to the right of the cell. Autolayout will then extend the size of the nameLabel as well as the nicknameLabel
        statusImageConstraint.constant = -contentView.frame.size.width
        statusImageView.setNeedsLayout()
        statusImageView.backgroundColor = UIColor.yiGrapeColor()
        
        boldLineLabel.text = "\(aBuddie.UserRequestfirstName) \(aBuddie.UserRequestlastName)"
        let dateString = aBuddie.lastMonitoredActivityDate // change to your date format
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let convertedDate = dateFormatter.date(from: dateString!) {
            normalLineLabel.text = timeAgoSinceDate(convertedDate, numericDates: false)
        } else {
            normalLineLabel.text = NSLocalizedString("neverSeenOnline", comment: "")
        }
        avatarImageView.backgroundColor = UIColor.yiWindowsBlueColor()
        // AVATAR NOT Implemented - must check for avatar image when implemented on server
        avatarNameLabel.text = "\(aBuddie.buddyNickName.capitalized.first!)"
    }
    
    // MARK: using cell as Message
    
    func setMessage(_ aMessage : Message) {
        self.aMessage = aMessage
        avatarImageView.backgroundColor = UIColor.yiWindowsBlueColor()
        //if the messsage has been accepted can we delete so disable pan
        if aMessage.status == buddyRequestStatus.ACCEPTED || aMessage.status == buddyRequestStatus.REJECTED {
            self.isPanEnabled = true
        } else {
            self.isPanEnabled = false
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        if aMessage.messageType == notificationType.GoalConflictMessage {
            boldLineLabel.text = aMessage.simpleDescription() + " " + aMessage.activityTypeName + " - " + formatter.string(from: aMessage.creationTime as Date)
            avatarImageView.image = R.image.adultSad()
        } else {
            boldLineLabel.text = aMessage.simpleDescription()
            if let link = aMessage.userPhotoLink,
                let URL = URL(string: link) {
                avatarImageView.kf.setImage(with: URL)
            } else {
                avatarImageView.image = nil
            }
        }
        
        normalLineLabel.text = "\(aMessage.nickname)"
     
        if aMessage.nickname.count > 0 && aMessage.userPhotoLink == nil {
            avatarNameLabel.text = "\(aMessage.nickname.capitalized.first!)"
        } else {
            avatarNameLabel.text = ""
        }
        
        if aMessage.messageType == notificationType.SystemMessage {
            avatarImageView.backgroundColor = UIColor.yiMango95Color()
            normalLineLabel.text = "\(aMessage.message)"
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
    
    func timeAgoSinceDate(_ date:Date, numericDates:Bool) -> String {
        let calendar = Calendar.current
        let now = Date()
        let earliest = (now as NSDate).earlierDate(date)
        let latest = (earliest == now) ? date : now
        let components:DateComponents = (calendar as NSCalendar).components([NSCalendar.Unit.minute , NSCalendar.Unit.hour , NSCalendar.Unit.day , NSCalendar.Unit.weekOfYear , NSCalendar.Unit.month , NSCalendar.Unit.year , NSCalendar.Unit.second], from: earliest, to: latest, options: NSCalendar.Options())
        
        if (components.day! >= 2 && components.day! < 5) {
            let lastSeenText = String(format: "%@ %d %@", NSLocalizedString("lastSeen", comment: ""), components.day!, NSLocalizedString("daysAgo", comment: ""))
            return lastSeenText
        } else if (components.day == 1){
            let lastSeenText = String(format: "%@ %@", NSLocalizedString("lastSeen", comment: ""),NSLocalizedString("yesterday", comment: ""))
            return lastSeenText
        }else if (components.day! < 1){
            let lastSeenText = String(format: "%@ %@", NSLocalizedString("lastSeen", comment: ""),NSLocalizedString("today", comment: ""))
            return lastSeenText
        }  else {
            //Last seen on February 15, 2017
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM dd, yyyy"
            let dateString = dateFormatter.string(from: date)
            let lastSeenText = String(format: "%@ %@", NSLocalizedString("lastSeenOn", comment: ""),dateString)
            return lastSeenText
        }
        
    }
}

