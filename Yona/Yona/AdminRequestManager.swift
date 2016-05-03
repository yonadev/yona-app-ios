//
//  AdminRequestManager.swift
//  Yona
//
//  Created by Ben Smith on 03/05/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

class AdminRequestManager {

    /**
     Holds a reference to our shared instance of APIServiceManager
     */
    let APIService = APIServiceManager.sharedInstance
    
    static let sharedInstance = AdminRequestManager()
    
    private init() {}
    
    /**
     Resends the One Time Password (OTP) code that is sent to the user when they are required to confirm their account
     
     - parameter onCompletion: APIResponse, returns success or fail of the method and server messages
     */
    func adminRequestOverride(userBody: BodyDataDictionary, onCompletion: APIResponse) {
         APIService.APIServiceCheck { (success, message, code) in
            if success {
                
                if let mobileNumber = userBody["mobileNumber"] as? String {
                        let path = YonaConstants.environments.testUrl + YonaConstants.commands.adminRequestOverride + mobileNumber 
                        //not in user body need to hardcode
                        self.APIService.callRequestWithAPIServiceResponse(nil, path: path, httpMethod: httpMethods.post) { (success, json, error) in
                            
                        }
                        
                    }
                }
        }
    }
}

