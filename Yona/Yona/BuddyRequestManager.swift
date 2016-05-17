//
//  BuddyRequestManager.swift
//  Yona
//
//  Created by Ben Smith on 11/05/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

class BuddyRequestManager {
    let APIService = APIServiceManager.sharedInstance
    let APIUserRequestManager = UserRequestManager.sharedInstance
    static let sharedInstance = BuddyRequestManager()
    
    private init() {}

    func requestNewbuddy(buddyBody: BodyDataDictionary, onCompletion: APIResponse) {
        UserRequestManager.sharedInstance.getUser(.allowed) { (success, message, code, user) in
            if success {
                if let buddieLink = user?.buddiesLink {
                    self.APIService.callRequestWithAPIServiceResponse(buddyBody, path: buddieLink, httpMethod: httpMethods.post) { (success, json, error) in
                        onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error))
                    }
                }
            }
        }
    }
}