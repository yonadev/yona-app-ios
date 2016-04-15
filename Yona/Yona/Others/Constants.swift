//
//  Constants.swift
//  Yona
//
//  Created by Alessio Roberto on 04/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

typealias ServerMessage = String
typealias ServerCode = String

struct YonaConstants {
    struct environments {
        static let test = "http://85.222.227.142/"
        static let production = ""
    }
    
    struct commands {
        static let users = "users/"
        static let goals = "goals/"
        static let mobileConfirm = "/confirmMobileNumber"
        static let activityCategories = "activityCategories/"
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
        static let userID = "userID"
        static let confirmMobileKeyURL = "confirmMobileLink"
        static let otpResendMobileKeyURL = "otpResendMobileLink"
        #if DEBUG
        static let oneTimePassword = "mobileNumberConfirmationCode"
        #endif
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
        static let  goalType = "@type"
        static let  maxDuration = "maxDurationMinutes"
        static let  activityCategoryName = "activityCategoryName"
        static let  embedded = "_embedded"
        static let  yonaGoals = "yona:goals"
        static let  activityCategories = "yona:activityCategories"
        static let  name = "name"
        static let  applications = "applications"
        static let  mandatoryNoGo = "mandatoryNoGo"
        static let  zones = "zones"
    }

    struct serverCodes{
        static let tooManyOTPAttemps = "error.too.many.wrong.attempts"
        static let cannotAddSecondGoalOnSameCategory = "error.goal.cannot.add.second.on.activity.category"
        static let cannotRemoveMandatoryGoal = "error.goal.cannot.remove.mandatory"
        static let OK = "OK"
        static let noConnection = "NoConnection"
        static let noJsonReturned = "JsonNil"
        static let FailedToRetrieveOTP = "RetrievingOTPFail"
        static let FailedToRetrieveConfirmMobile = "RetrievingConfirmMobileFail"
        static let FailedToRetrieveGetUserDetails = "getUserFail"
        static let FailedToRetrieveUpdateUserDetails = "updateUserFail"
        static let FailedToRetrieveUserDetailsForDeleteUser = "deleteUserFail"
        static let FailedToRetrieveGetUserGoals = "getUserGoalsFail"

    }
    
    struct serverMessages{
        static let needToGetSomeActivities = "Call get activities to populate array"
        static let OK = "Everything is OK"
        static let noConnection = "No network connection"
        static let noJsonReturned = "No JSON returned from request"
        static let FailedToRetrieveOTP = "Failed to retrieve details for OTP"
        static let FailedToRetrieveGetUserDetails = "Failed to retrieve details for user"
        static let FailedToRetrieveUpdateUserDetails = "Failed to get the details to update the user"
        static let FailedToRetrieveUserDetailsForDeleteUser = "Failed to retrieve the details to delete the user"
        static let FailedToRetrieveConfirmMobile = "Failed to retrieve details for confirm mobile"
        static let FailedToRetrieveGetUserGoals = "Failed to get the users goals"
    }
    
    struct serverResponseKeys{
        static let message = "message"
        static let code = "code"
    }
    
    struct mobilePhoneLength{
        static let netherlands = 11
    }
    
    struct testKeys{
        static let otpTestCode = "1234"
    }

    struct responseCodes{
        static let ok200 = 200
        static let ok204 = 204
    }

    struct nsUserDefaultsKeys{
        static let isBlocked = "isBlocked"
        static let screenToDisplay = "screenToDisplay"
        
    }

}