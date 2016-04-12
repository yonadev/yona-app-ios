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
        static let goals = "goals/"
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
        static let  otpResendMobileLinkKey = "yona:resendMobileNumberConfirmationCode"
        static let  hrefKey = "href"
    }
    struct mobilePhoneLength{
        static let netherlands = 11
    }
    
    struct testKeys{
        static let code = "1234"
    }

    struct nsUserDefaultsKeys{
        static let userID = "userID"
        static let confirmMobileKeyURL = "confirmMobileLink"
        static let otpResendMobileKeyURL = "otpResendMobileLink"

        #if DEBUG
        static let pincode = "mobileNumberConfirmationCode"
        #endif
        static let isBlocked = "isBlocked"
        static let screenToDisplay = "screenToDisplay"
        
    }

}