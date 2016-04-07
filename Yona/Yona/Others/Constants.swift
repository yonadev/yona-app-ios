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
        static let put = "PUT"
    }

    struct keychain {
        static let yonaPassword = "kYonaPassword"
        static let PINCode = "kPINCode"
    }
    
    struct jsonKeys{
        static let  firstNameKey = "firstName"
        static let  lastNameKeys = "lastName"
        static let  mobileNumberKeys = "mobileNumber"
        static let  nicknameKeys = "nickname"
        static let  linksKeys = "_links"
        static let  selfLinkKeys = "self"
        static let  editLinkKeys = "edit"
        static let  confirmMobileLinkKeys = "yona:confirmMobileNumber"
        static let  hrefKey = "href"
    }
    
    struct nsUserDefaultsKeys{
        static let userID = "userID"
        static let confirmMobileKeyURL = "confirmMobileLink"
        #if DEBUG
        static let pincode = "mobileNumberConfirmationCode"
        #endif
    }

}