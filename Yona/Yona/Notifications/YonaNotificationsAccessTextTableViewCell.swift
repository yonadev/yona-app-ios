//
//  YonaNotificationsAccessTextTableViewCell.swift
//  Yona
//
//  Created by Anders Liebl on 20/06/2016.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation


class YonaNotificationsAccessTextTableViewCell: UITableViewCell {
    @IBOutlet weak var aTextLabel : UILabel!
 
    
    func setPhoneNumber(aMessage : Message) {
        let num = aMessage.UserRequestmobileNumber
        let text = String(format:  NSLocalizedString("notifications.accept.number", comment: ""), num)

        aTextLabel.text = text
    }

    func setMessageFromPoster(aMessage : Message) {
            aTextLabel.text = aMessage.message
        
    }

}