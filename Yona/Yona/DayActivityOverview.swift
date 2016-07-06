//
//  DayActivityOverview.swift
//  Yona
//
//  Created by Anders Liebl on 05/07/2016.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation
class DayActivityOverview: NSObject {
    
    let date : NSDate
    var activites : [ActivitiesGoal] = []
    
    init(Date aDate: NSDate, theActivities: [ActivitiesGoal]) {
        date = aDate
        activites = theActivities
    }
}