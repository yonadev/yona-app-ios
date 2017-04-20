//
//  Reachability.swift
//  DierenparkAmersfoort
//
//  Created by Angel Vasa on 05/08/16.
//  Copyright © 2016 Dierenpark Amersfoort. All rights reserved.
//

import Foundation
import SystemConfiguration

public class Reachability {
    
    class func isNetworkReachable() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(&zeroAddress, {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }) else {
            return false
        }
        
        var flags : SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.Reachable)
        let needsConnection = flags.contains(.ConnectionRequired)
        
        
        return (isReachable && !needsConnection)
        
    }
}