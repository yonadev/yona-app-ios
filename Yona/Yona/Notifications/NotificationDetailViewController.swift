//
//  NotificationDetailViewController.swift
//  Yona
//
//  Created by Suresh Varma on 23/03/17.
//  Copyright © 2017 Yona. All rights reserved.
//

import Foundation

class NotificationDetailViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var avatarLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    var aMessage : Message!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLabels()
        self.title = NSLocalizedString("notifications.messages.title", comment: "Page title")
    }
    
    func setUpLabels() {
        nameLabel.text = NSLocalizedString("yonaAdministrator", comment: "")
        let formatter = NSDateFormatter()
        formatter.dateFormat = "HH:mm"
        let txt = formatter.stringFromDate((aMessage?.creationTime)!)
        timeLabel.text = txt
        self.title = ""
        
        if let nickname = aMessage?.nickname {
            avatarLabel.text = "\(nickname.capitalizedString.characters.first!)"
        }
        titleLabel.text = NSLocalizedString("message.type.systemMessage", comment: "")
        descriptionLabel.text = aMessage?.message
        
        
        avatarLabel.backgroundColor = UIColor.yiMango95Color()
    }
}
