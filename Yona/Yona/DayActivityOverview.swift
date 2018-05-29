//
//  DayActivityOverview.swift
//  Yona
//
//  Created by Anders Liebl on 05/07/2016.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

class DayActivityOverview: NSObject {
    
    let date : Date
    var activites : [ActivitiesGoal] = []
    
    init(Date aDate: Date, theActivities: [ActivitiesGoal]) {
        date = aDate
        activites = theActivities.sorted(by: {$0.dayDetailLinks > $1.dayDetailLinks}) //sort in alphabetical order
    }
}
