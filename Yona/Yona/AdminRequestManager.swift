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
    
    fileprivate init() {}
    
    /**
     Creates an admin request, if the user tries to create an account with same mobile number because they have lost their phone but what to retrieve the account
     
     - parameter userBody: BodyDataDictionary Dictionary of user details for the admin request, we need the mobile from here
     - parameter onCompletion: APIResponse, returns success or fail of the method and server messages
     */
    func adminRequestOverride(_ mobileNumber: String?, onCompletion: @escaping APIResponse) {
        UserRequestManager.sharedInstance.getUser(GetUserRequest.allowed) { (success, message, code, user) in
            if let mobileNumber = user?.mobileNumber {
                let path = YonaConstants.commands.adminRequestOverride + mobileNumber.replacePlusSign()
                //not in user body need to hardcode
                self.APIService.callRequestWithAPIServiceResponse(nil, path: path, httpMethod: httpMethods.post) { (success, json, error) in
                    onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error))
                }
            } else if let mobileNumber = mobileNumber {
                let path = YonaConstants.commands.adminRequestOverride + mobileNumber.replacePlusSign()
                //not in user body need to hardcode
                self.APIService.callRequestWithAPIServiceResponse(nil, path: path, httpMethod: httpMethods.post) { (success, json, error) in
                    onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error))
                }
            }
        
        }

    }
}

