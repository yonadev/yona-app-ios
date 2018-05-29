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
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        var finalZoneArray = [ToFromDate]()
        for arr in self {
            let bifurcateArray = String(describing: arr).dashRemoval()
            finalZoneArray.append(ToFromDate(fromDate: dateFormatter.date(from: bifurcateArray[0])!, toDate: dateFormatter.date(from: bifurcateArray[1])!))
        }
        return finalZoneArray
    }
    
    func convertToString() -> [String] {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        var finalZoneArray = [String]()
        for arr in self {
            let bifurcateArray = (arr as! ToFromDate)
            finalZoneArray.append("\(dateFormatter.string(from: bifurcateArray.fromDate as Date))-\(dateFormatter.string(from: bifurcateArray.toDate as Date))")
        }
        
        
        return finalZoneArray
    }
}
