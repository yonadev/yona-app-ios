//
//  NoGoView.swift
//  Yona
//
//  Created by Ben Smith on 12/07/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

class NoGoCell : UITableViewCell {
    
    @IBOutlet weak var nogoImage: UIImageView!
    @IBOutlet weak var nogoType: UILabel!
    @IBOutlet weak var nogoMessage: UILabel!
    
    override func awakeFromNib() {
    }
    
    func setUpView(activityGoal : ActivitiesGoal) {
        nogoType.text = activityGoal.goalName
        if activityGoal.maxDurationMinutes > 0 {
            self.nogoImage.image = R.image.adultSad
            let zone = activityGoal.zones[0]
            self.nogoMessage.text = "Zones \(String(zone)) - \(String(activityGoal.maxDurationMinutes))"
        } else {
            self.nogoMessage.text = "geen hits, hou vol"
//            let zone = activityGoal.zones[0]
//            self.nogoMessage.text = "Zones \(String(zone)) - \(String(activityGoal.maxDurationMinutes))"
            self.nogoImage.image = R.image.adultHappy
        }
    }
}