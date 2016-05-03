//
//  NewDeviceRequestManager.swift
//  Yona
//
//  Created by Ben Smith on 28/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

//MARK: - New Device Requests APIService
extension APIServiceManager {
    
    /**
     Add a new device to the users account
     
     - parameter mobileNumber: String, mobile number required to identify the account that the user wants to add a device to
     - parameter onCompletion: APIResponse, returns success or fail of the method and server messages
     */
    func putNewDevice(mobileNumber: String, onCompletion: APIResponse) {
        APIServiceCheck { (success, message, code) in
            if success {
                self.getUser{ (success, message, code, user) in
                    if let path = user?.newDeviceRequestsLink,
                        let password = KeychainManager.sharedInstance.getYonaPassword() {
                        let bodyNewDevice = [
                            "newDeviceRequestPassword": password
                        ]
                        self.callRequestWithAPIServiceResponse(bodyNewDevice, path: path, httpMethod: httpMethods.put, onCompletion: { (success, json, error) in
                            guard success == true else {
                                onCompletion(false, self.serverMessage, self.serverCode)
                                return
                            }
                            onCompletion(true, self.serverMessage, self.serverCode)
                            
                        })
                    }
                }
            } else {
                onCompletion(false, message, code)
            }
        }
    }
}