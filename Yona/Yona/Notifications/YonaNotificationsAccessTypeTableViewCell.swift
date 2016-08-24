//
//  YonaNotificationsAccessTypeTableViewCell.swift
//  Yona
//
//  Created by Anders Liebl on 20/06/2016.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation


class YonaNotificationsAccessTypeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var typeTextLable : UILabel!
    override func awakeFromNib() {
        typeTextLable.numberOfLines = 5
        typeTextLable.adjustsFontSizeToFitWidth = true
    }
}