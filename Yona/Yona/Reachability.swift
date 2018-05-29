//
//  Reachability.swift
//  DierenparkAmersfoort
//
//  Created by Angel Vasa on 05/08/16.
//  Copyright © 2016 Dierenpark Amersfoort. All rights reserved.
//

import Foundation
import SystemConfiguration

open class Reachability {
    
    class func isNetworkReachable() -> Bool {
        
//        var zeroAddress = sockaddr()
//        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
//        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        var zeroAddress = sockaddr()
        zeroAddress.sa_len = UInt8(MemoryLayout<sockaddr>.size)
        zeroAddress.sa_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {_ in
            SCNetworkReachabilityCreateWithAddress(nil, &zeroAddress)
        }) else {
            return false
        }
        
        var flags : SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        
        return (isReachable && !needsConnection)
        
    }
}
