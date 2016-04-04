//
//  Constants.swift
//  Yona
//
//  Created by Alessio Roberto on 04/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

struct YonaConstants {
    struct environments {
        static let test = "http://85.222.227.142/"
        static let production = ""
    }
    
    struct commands {
        static let users = "users/"
        static let mobileConfirm = "/confirmMobileNumber"
    }
    
    struct httpMethods{
        static let post = "POST"
        static let delete = "DELETE"
        static let get = "GET"
    }

    struct keychain {
        static let yonaPassword = "kYonaPassword"
    }
}