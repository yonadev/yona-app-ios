//
//  RequestResult.swift
//  YONA
//
//  Created by Ben Smith on 10/05/16.
//  Copyright © 2016 Ben Smith. All rights reserved.
//

import Foundation

/**
 The purpose of this class is to store the result of the request, maybe it has a system error message because of network fail or OMDB returns their own error, well we store it all here and the code so the UI can determin what messages to present to the user
 */
struct requestResult {
    var success: Bool
    var errorMessage: String?
    var errorCode: Int
    var domain: String
    
    init(success: Bool, errorMessage: String?, errorCode: Int, domain: String)
    {
        self.success = success
        self.errorMessage = errorMessage
        self.errorCode = errorCode
        self.domain = domain
    }
}