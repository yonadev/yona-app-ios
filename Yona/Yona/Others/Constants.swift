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
typealias PinCode = String

struct YonaConstants {
    
    struct YonaErrorTypes {
        static let SerialiseRequestBodyFail = NSError(domain: "Serializing the body for a request failed", code: 1, userInfo: nil)
        static let NSURLRequestSetupFail = NSError(domain: "NSURL Request failed to setup", code: 2, userInfo: nil)
        static let NetworkFail = NSError.init(domain: "Network Fail", code: 3, userInfo: nil)
        static let UserRequestFailed = NSError.init(domain: "Failed to get user", code: 4, userInfo: nil)
        static let UserPasswordRequestFail = NSError.init(domain: "Failed to get user password", code: 5, userInfo: nil)
        static let JsonObjectSerialisationFail = NSError.init(domain: "JSON Object serialisation failed", code: 6, userInfo: nil)
        static let APILinkRetrievalFail = NSError.init(domain: "Getting link for API failed", code: 7, userInfo: nil)
    }
    
    struct environments {
        static let testPostUserLink = "http://85.222.227.142/users/" // only link we need to hard code!
        static let testUrl = "http://85.222.227.142/" //test server
        static let production = ""
    }
    
    struct commands {
        static let users = "users/"
        static let goals = "goals/"
        static let mobileConfirm = "/confirmMobileNumber"
        static let activityCategories = "activityCategories/"
        static let newDeviceRequests = "newDeviceRequests/"
        static let pinRequest = "/pinResetRequest/request"
        static let pinVerify = "/pinResetRequest/verify"
        static let pinClear = "/pinResetRequest/clear"

    }

    struct keychain {
        static let yonaPassword = "kYonaPassword"
        static let PINCode = "kPINCode"
        static let userID = "userID"
        static let userSelfLink = "userSelfLink"
        #if DEBUG
        static let oneTimePassword = "mobileNumberConfirmationCode"
        #endif
    }
    
    struct jsonKeys{
        static let  firstNameKey = "firstName"
        static let  lastNameKeys = "lastName"
        static let  mobileNumberKeys = "mobileNumber"
        static let  nicknameKeys = "nickname"
        static let  goalType = "@type"
        static let  maxDuration = "maxDurationMinutes"
        static let  activityCategoryName = "activityCategoryName"
        static let  embedded = "_embedded"
        static let  yonaGoals = "yona:goals"
        static let  yonaBuddies = "yona:buddies"
        static let  name = "name"
        static let  applications = "applications"
        static let  zones = "zones"
        static let  pinResetDelay = "delay"
        static let  bodyCode = "code"
        static let  yonaActivityCategories = "yona:activityCategories"
        //links
        static let  linksKeys = "_links"
        static let  selfLinkKeys = "self"
        static let  editLinkKeys = "edit"
        static let  yonaConfirmMobileLinkKeys = "yona:confirmMobileNumber"
        static let  yonaOtpResendMobileLinkKey = "yona:resendMobileNumberConfirmationCode"
        static let  yonaMessages = "yona:messages"
        static let  yonaDailyActivityReports = "yona:dailyActivityReports"
        static let  yonaWeeklyActivityReports = "yona:weeklyActivityReports"
        static let  yonaActivityCategory = "yona:activityCategory"
        static let  yonaNewDeviceRequest = "yona:newDeviceRequest"
        static let  yonaAppActivity = "yona:appActivity"
        static let  yonaPinRequest = "yona:requestPinReset"
        static let  yonaPinVerify = "yona:verifyPinReset"
        static let  yonaPinClear = "yona:clearPinReset"
        static let  hrefKey = "href"
    }

    struct serverCodes{
        static let tooManyOTPAttemps = "error.too.many.wrong.attempts"
        static let tooManyResendOTPAttemps = "error.mobile.number.confirmation.code.too.many.failed.attempts"
        static let tooManyPinResetAttemps = "error.pin.reset.request.confirmation.code.too.many.failed.attempts"
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
        static let CannotRemoveMandatoryGoal = "Cannot remove a mandatory goal"
        static let NoEditLinkCannotRemoveMandatoryGoal = "No Edit Link, because this is a mandatory goal and you cannot remove it!"

    }
    
    struct serverResponseKeys{
        static let message = "message"
        static let code = "code"
    }
    
    struct mobilePhoneLength{
        static let netherlands = 11
    }
    
    struct mobilePhoneSpace{
        static let mobileFirstSpace = 4
        static let mobileMiddleSpace = 9
        static let mobileLastSpace = 13
    }
    
    struct testKeys{
        static let otpTestCode = "1234"
    }

    struct nsUserDefaultsKeys{
        static let isBlocked = "isBlocked"
        static let screenToDisplay = "screenToDisplay"
        static let timeBucketTabToDisplay = "timeBucketTabToDisplay"
    }

    struct screenNames{
        static let walkThrough = "WalkThrough"
        static let welcome = "Welcome"
        static let smsValidation = "SMSValidation"
        static let passcode = "Passcode"
        static let login = "Login"
    }    
}