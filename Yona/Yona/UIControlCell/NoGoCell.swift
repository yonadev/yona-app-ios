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
    }
}