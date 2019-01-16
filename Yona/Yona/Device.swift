//
//  Device.swift
//  Yona
//
//  Created by Vishal Revdiwala on 11/01/19.
//  Copyright © 2019 Yona. All rights reserved.
//

import Foundation

struct Device {
    
    var isRequestingDevice: Bool?
    var appActivityLink: String?
    var openAppEventLink: String?
    var mobileConfigLink: String?
    
    init(deviceData: BodyDataDictionary) {
        self.isRequestingDevice = deviceData[YonaConstants.jsonKeys.requestingDevice] as? Bool
        
        if let links = deviceData[YonaConstants.jsonKeys.linksKeys] {
            if let appActivityLinks = links[YonaConstants.jsonKeys.yonaAppActivity],
                let hrefAppActivityLinks = (appActivityLinks as? [String : String])?[YonaConstants.jsonKeys.hrefKey] {
                self.appActivityLink = hrefAppActivityLinks
            }
            
            if let yonaOpenAppEventLink = links[YonaConstants.jsonKeys.yonaOpenAppEventLink],
                let hrefYonaOpenAppEventLink = (yonaOpenAppEventLink as? [String : String])?[YonaConstants.jsonKeys.hrefKey] {
                self.openAppEventLink = hrefYonaOpenAppEventLink
            }
            
            if let yonaAppleMobileConfigLink = links[YonaConstants.jsonKeys.yonaAppleMobileConfig],
                let mobileConfig  = (yonaAppleMobileConfigLink as? [String : String])?[YonaConstants.jsonKeys.hrefKey] {
                self.mobileConfigLink = mobileConfig
            }
        }
    }
}
