//
//  Array.swift
//  Yona
//
//  Created by Chandan on 04/05/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

extension Array {
    func converToDate() -> [ToFromDate]{
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        var finalZoneArray = [ToFromDate]()
        for arr in self {
            let bifurcateArray = String(arr).dashRemoval()
            finalZoneArray.append(ToFromDate(fromDate: dateFormatter.dateFromString(bifurcateArray[0])!, toDate: dateFormatter.dateFromString(bifurcateArray[1])!))
        }
        return finalZoneArray
    }
    
    func convertToString() -> [String] {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        var finalZoneArray = [String]()
        for arr in self {
            let bifurcateArray = (arr as! ToFromDate)
            finalZoneArray.append("\(dateFormatter.stringFromDate(bifurcateArray.fromDate))-\(dateFormatter.stringFromDate(bifurcateArray.toDate))")
        }
        
        
        return finalZoneArray
    }
}
