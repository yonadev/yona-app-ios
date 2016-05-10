//
//  Date.swift
//  Yona
//
//  Created by Chandan on 04/05/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

extension NSDate {
    func isGreaterThanDate(dateToCompare: NSDate) -> Bool {
        var isGreater = false
        if self.compare(dateToCompare) == NSComparisonResult.OrderedDescending {
            isGreater = true
        }
        
        return isGreater
    }
    
    /**
     Round ff the time to next 15 minutes i.e if time is 10:27 it will set it as 10:30.
     
     - parameter none
     - return Rounded value of object NSDate in HH:mm format
     */
    func dateRoundedDownTo15Minute() -> NSDate {
        let referenceTime = self.timeIntervalSinceReferenceDate
        let remainingSeconds = referenceTime % 900
        var timeRound15 = referenceTime - (referenceTime % 900)
        
        if timeRound15 > 450 {
            timeRound15 = referenceTime + (900 - remainingSeconds)
        }
        
        let date = NSDate.init(timeIntervalSinceReferenceDate: timeRound15)
        return date
    }
}