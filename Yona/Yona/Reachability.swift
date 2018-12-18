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
        var zeroAddress = sockaddr()
        zeroAddress.sa_len = UInt8(MemoryLayout<sockaddr>.size)
        zeroAddress.sa_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }) else {
            return false
        }
        
        var flags = SCNetworkReachabilityFlags()
        guard SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) else {
            return false
        }
        
        return flags.contains(.reachable) && !flags.contains(.connectionRequired)
    }
}
