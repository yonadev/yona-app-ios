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
            let arrT = (arr as! String).dashRemoval()
            finalZoneArray.append(ToFromDate(fromDate: dateFormatter.dateFromString(arrT[0]), toDate: dateFormatter.dateFromString(arrT[1])))
        }
        
        
        
        return finalZoneArray
    }
    
    func convertToString() -> [String] {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        var finalZoneArray = [String]()
        for arr in self {
            let arrT = (arr as! ToFromDate)
            finalZoneArray.append("\(dateFormatter.stringFromDate(arrT.fromDate!))-\(dateFormatter.stringFromDate(arrT.toDate!))")
        }
        
        
        return finalZoneArray
    }
}
