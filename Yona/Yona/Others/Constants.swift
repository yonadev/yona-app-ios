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
typealias AddDeviceCode = String

struct YonaConstants {
    struct urlLinks {
        static let privacyStatementURLString = "http://www.yona.nu/app/privacy"
    }
    
    struct YonaErrorTypes {
        static let FailedToGetActivityLink = NSError.init(domain: errorDomains.internalErrorDomain.rawValue, code: responseCodes.internalErrorCode.rawValue, userInfo: [NSLocalizedDescriptionKey: serverMessages.FailedToGetActivityLink ?? "Unknown Error"])
        static let UserRequestFailed = NSError.init(domain: errorDomains.internalErrorDomain.rawValue, code: responseCodes.internalErrorCode.rawValue, userInfo: [NSLocalizedDescriptionKey: serverMessages.FailedToRetrieveGetUserDetails ?? "Unknown Error"])
        static let UserPasswordRequestFail = NSError.init(domain: errorDomains.internalErrorDomain.rawValue, code: responseCodes.internalErrorCode.rawValue, userInfo:  [NSLocalizedDescriptionKey: serverMessages.FailedToRetrievePassword ?? "Unknown Error"])
        static let GetMessagesLinkFail = NSError.init(domain: errorDomains.internalErrorDomain.rawValue, code: responseCodes.internalErrorCode.rawValue, userInfo:  [NSLocalizedDescriptionKey: serverMessages.FailedToGetGetMessagesLink ?? "Unknown Error"])
        static let GetBuddyLinkFail = NSError.init(domain: errorDomains.internalErrorDomain.rawValue, code: responseCodes.internalErrorCode.rawValue, userInfo:  [NSLocalizedDescriptionKey: serverMessages.FailedToRetrieveBuddyLink ?? "Unknown Error"])
        static let Success = NSError.init(domain: errorDomains.successDomain.rawValue, code: responseCodes.ok200.rawValue, userInfo:  [NSLocalizedDescriptionKey: serverMessages.OK ?? "Unknown Error"])
    }
    
    struct commands {
        static let users = "users/"
        static let adminRequestOverride = "admin/requestUserOverwrite/?mobileNumber=" //hard coded not in the feed
        static let userRequestOverrideCode = "?overwriteUserConfirmationCode="
        static let activityCategories = "activityCategories/"
        static let newDeviceRequests = "newDeviceRequests/"

    }

    struct keychain {
        static let yonaPassword = "kYonaPassword"
        static let PINCode = "kPINCode"
        static let userID = "userID"
        static let userSelfLink = "userSelfLink"
        static let deviceRequestLink = "deviceRequestLink"
        #if DEBUG
        static let oneTimePassword = "mobileNumberConfirmationCode"
        #endif
    }
    
    struct jsonKeys{
        static let  yonaPassword = "yonaPassword"
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
        static let  yonaUserSelfLink = "yona:user"
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
        static let  yonaResendPinResetRequest = "yona:resendPinResetConfirmationCode"
        static let  yonaPinVerify = "yona:verifyPinReset"
        static let  yonaPinClear = "yona:clearPinReset"
        static let  hrefKey = "href"

        static let  dayActivities = "dayActivities"
        static let  yonaDayActivityOverviews = "yona:dayActivityOverviews"
        static let  historyItem = "historyItem"
        static let  totalActivityDurationMinutes = "totalActivityDurationMinutes"
        static let  goalAccomplished = "goalAccomplished"
        static let  totalMinutesBeyondGoal = "totalMinutesBeyondGoal"
        static let  yonaDayDetails = "yona:dayDetails"
        static let  date = "date"
        static let  yonaGoal = "yona:goal"
        
        static let  weekActivityOverviews = "yona:weekActivityOverviews"
        static let  weekActivities = "weekActivities"
        static let  yonaWeekDetails = "yona:weekDetails"
        
    }

    struct dayOfWeek {
        static let sunday = "SUNDAY"
        static let monday = "MONDAY"
        static let tuesday = "TUESDAY"
        static let wednesday = "WEDNESDAY"
        static let thursday = "THURSDAY"
        static let friday = "FRIDAYY"
        static let saturday = "SATURDAY"
    
    }
    
    struct serverCodes{
        static let userOverWriteConfirmCodeMismatch = "error.user.overwrite.confirmation.code.mismatch"
        static let mobileConfirmMismatch = "error.mobile.number.confirmation.code.mismatch"
        static let pinResetMismatch = "error.pin.reset.request.confirmation.code.mismatch"
        static let errorUserExists = "error.user.exists"
        static let errorAddBuddyUserExists = "error.user.exists.created.on.buddy.request"
        static let errorUserNotFound = "error.user.not.found.id"
        static let tooManyOTPAttemps = "error.too.many.wrong.attempts"
        static let tooManyFailedConfirmOTPAttemps = "error.mobile.number.confirmation.code.too.many.failed.attempts"
        static let tooManyPinResetAttemps = "error.pin.reset.request.confirmation.code.too.many.failed.attempts"
        static let cannotAddSecondGoalOnSameCategory = "error.goal.cannot.add.second.on.activity.category"
        static let cannotRemoveMandatoryGoal = "error.goal.cannot.remove.mandatory"
        static let OK = "OK"
        static let networkConnectionProblem = "NetworkConnectionProblem"
        static let noJsonReturned = "JsonNil"
        static let FailedToRetrieveOTP = "RetrievingOTPFail"
        static let FailedToRetrieveConfirmMobile = "RetrievingConfirmMobileFail"
        static let FailedToRetrieveGetUserDetails = "getUserFail"
        static let FailedToRetrieveUpdateUserDetails = "updateUserFail"
        static let FailedToRetrieveUserDetailsForDeleteUser = "deleteUserFail"
        static let FailedToRetrieveGetUserGoals = "getUserGoalsFail"
    }
    
    struct serverMessages{
        static let timeoutRequest = "The request timed out, server problem"
        static let OK = "Everything is OK"
        static let networkConnectionProblem = "Network connection problem"
        static let serverProblem = "Server problem"

        static let needToGetSomeActivities = "Call get activities to populate array"
        static let noJsonReturned = "No JSON returned from request"
        static let FailedToRetrievePassword = "Failed to get user password"
        static let FailedToRetrieveBuddyLink = "Failed to retrieve buddy link"
        static let FailedToRetrieveOTP = "Failed to retrieve details for OTP"
        static let FailedToRetrieveProcessLink = "Failed to retrieve process link for friend request"
        static let FailedToRetrieveAcceptLink = "Failed to retrieve accept link for friend request"
        static let FailedToRetrieveRejectLink = "Failed to retrieve accept link for friend request"
        static let FailedToRetrieveDeleteLink = "Failed to retrieve delete link for friend request"
        static let FailedToRetrieveGetUserDetails = "Failed to retrieve details for user"
        static let FailedToRetrieveUpdateUserDetails = "Failed to get the details to update the user"
        static let FailedToRetrieveUserDetailsForDeleteUser = "Failed to retrieve the details to delete the user"
        static let FailedToRetrieveConfirmMobile = "Failed to retrieve details for confirm mobile"
        static let FailedToRetrieveGetUserGoals = "Failed to get the users goals"
        static let FailedToGetActivityLink = "Failed to get activity Link"
        static let FailedToGetResetPinLink = "Failed to get reset pin link"
        static let FailedToGetResetPinVerifyLink = "Failed to get pin verify link"
        static let FailedToGetResendResetRequestLink = "Failed to get Resend pin verify link"
        static let FailedToGetResetPinClearLink = "Failed to get pin clear link"
        static let FailedToGetDeviceRequestLink = "Failed to get device request  link"
        static let FailedToGetGetMessagesLink = "Failed to get Get Messages link from user body"
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
        static let timeToPinReset = "timeToPinReset"
        static let isBlocked = "isBlocked"
        static let isFromSettings = "isFromSettings"
        static let isLoggedIn = "isLoggedIn"
        static let screenToDisplay = "screenToDisplay"
        static let timeBucketTabToDisplay = "timeBucketTabToDisplay"
        static let adminOverride = "adminOverride"
        static let userToOverride = "userToOverride"
        static let isGoalsAdded = "isGoalsAdded"
    }   
}