//
//  Enums.swift
//  Yona
//
//  Created by Ben Smith on 20/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

enum DayOfWeek : Int {
    case sunday = 1
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
}

enum loadType {
    case prev
    case own
    case next
}

enum ViewControllerTypeString: String {
    case walkThrough = "WalkThrough"
    case welcome = "Welcome"
    case confirmMobileNumberValidation = "confirmPinValidationViewController"
    case pinResetValidation = "pinResetValidationController"
    case adminOverrideValidation = "adminOverrideValidationViewController"
    case passcode = "Passcode"
    case login = "Login"
    case dashboard = "Dashboard"
    case userProfile = "ProfileStoryboard"
    case signUp = "SignUpSecondStepViewController"
}

enum GoalType: String {
    case BudgetGoalString = "BudgetGoal"
    case TimeZoneGoalString = "TimeZoneGoal"
    case NoGoGoalString = "NoGoGoal"
}

enum serverLanguages: String {
    case dutch = "nl-NL"
    case english = "en-EN"
}

enum iosLanguages: String {
    case dutch = "nl"
    case english = "en"
}

enum CategoryName: String {
    case newsString = "News"
    case socialString = "Social"
    case gamblingString = "Gambling"
}

enum Segues: String {
    case BudgetChallengeSegue = "BudgetChallengeSegue"
    case TimeZoneChallengeSegue = "TimezoneChallengeSegue"
    case NoGoChallengeSegue = "NoGoChallengeSegue"
}

enum httpMethods: String{
    case post = "POST"
    case delete = "DELETE"
    case get = "GET"
    case put = "PUT"
}

enum alertButtonType{
    case ok
    case cancel
}

enum pinRequestTypes{
    case resetRequest
    case resendResetRequest
    case verifyRequest
    case clearRequest
}

enum goalRequestTypes{
    case updateGoal
    case deleteGoal
    case getAllGoals
    case postGoal
}

enum userRequestTypes{
    case postUser
    case deleteUser
    case getUser
    case updateUser
    case confirmMobile
    case resendMobileConfirmCode
    case getConfigFile
}

enum GetUserRequest{
    case allowed
    case notAllowed //if you set this one then the get User API will not be called, but the USER object will be returned (saves API get user calls)
}

enum responseCodes: Int{
    case ok200 = 200
    case ok399 = 399
    case connectionFail400 = 400
    case connectionFail499 = 499
    case serverProblem500 = 500
    case serverProblem599 = 599
    case yonaErrorCode = 600
    case internalErrorCode = 700
}

enum errorDomains : String {
    case yonaErrorDomain = "YONA.Domain"
    case networkErrorDomain = "Network.Domain"
    case successDomain = "Success"
    case internalErrorDomain = "App error"
}

enum responseMessages: String{
    case networkConnectionProblem = "Network connection problem"
    case serverProblem = "Server problem"
    case YonaError = "You are not Alone! Something went wrong!"
    case internalErrorMessage = "App error"
    case success = "Success"
}

enum timeBucketTabNames: String{
    case budget = "Budget"
    case timeZone = "TimeZone"
    case noGo = "NoGo"
}

enum buddyRequestStatus : String {
    case REQUESTED = "REQUESTED"
    case NOT_REQUESTED = "NOT_REQUESTED"
    case ACCEPTED = "ACCEPTED"
    case REJECTED = "REJECTED"
}


enum postBuddyBodyKeys : String {
    case embedded = "_embedded"
    case sendingStatus = "sendingStatus"
    case receivingStatus = "receivingStatus"
    case message = "message"
    case yonaUser = "yona:user"
    case yonaBuddies = "yona:buddies"
    case yonaDailyActivityReports = "yona:dailyActivityReports"
    case yonaWeeklyActivityReports = "yona:weeklyActivityReports"
    case links = "_links"
    case selfKey = "self"
    case editKey = "edit"
    case href = "href"

}

enum getMessagesKeys : String {
    case embedded = "_embedded"
    case yonaMessages = "yona:messages"
    case creationTime = "creationTime"
    case nickname = "nickname"
    case message = "message"
    case status = "status"
    case reject =  "yona:reject"
    case accept =  "yona:accept"
    case process =  "yona:process"
    case markRead = "yona:markRead"
    case activityCategory = "yona:activityCategory"
    case relatedCategory = "related"
    case selfKey = "self"
    case links = "_links"
    case edit = "edit"
    case userPhoto = "yona:userPhoto"
    case yonaUser = "yona:user"
    case href = "href"
    case UserRequestfirstName = "firstName"
    case UserRequestlastName = "lastName"
    case UserRequestmobileNumber = "mobileNumber"
    case messageType = "@type"
    //paging
    case page = "page"
    case size = "size"
    case totalElements = "totalElements"
    case totalPages = "totalPages"
    case number = "number"
    case change = "change"
    case dateFormat = "YYYY-MM-dd'T'HH:mm:ss.SSZZZ"
    case dateFormatSimple = "YYYY-MM-dd"
    case dateFormatWeek = "yyyy'-W'w"
    case isRead = "isRead"
    case lastMonitoredActivityDate = "lastMonitoredActivityDate"
}

enum addUserKeys : String {
    case firstNameKey = "firstName"
    case lastNameKeys = "lastName"
    case mobileNumberKeys = "mobileNumber"
    case nicknameKeys = "nickname"
    case emailAddress = "emailAddress"
}

// Used in Profile 
enum ProfileCategoryHeader : Int {
    case firstName = 0
    case lastName
    case nickName
    case cellNumber
    
    
    func headerText() -> String{
        switch self {
        case ProfileCategoryHeader.firstName:
            return  NSLocalizedString("profile.user.data.firstname", comment: "ProfileCell FirstName header")
        case ProfileCategoryHeader.lastName:
            return  NSLocalizedString("profile.user.data.lastname", comment: "ProfileCell LastName header")
        case ProfileCategoryHeader.nickName:
            return  NSLocalizedString("profile.user.data.nickname", comment: "ProfileCell NickName header")
        case ProfileCategoryHeader.cellNumber:
            return  NSLocalizedString("profile.user.data.mobilenumber", comment: "ProfileCell Mobile Phone header")
        }
    }

    func imageType() -> UIImage {
        
        switch self {
        case ProfileCategoryHeader.firstName:
            return  UIImage(named: "icnName")!
        case ProfileCategoryHeader.lastName:
            return  UIImage(named: "icnName")!
        case ProfileCategoryHeader.nickName:
            return  UIImage(named: "icnNickname")!
        case ProfileCategoryHeader.cellNumber:
            return  UIImage(named: "icnMobile")!
        }
    }

}

// Used in Profile
enum FriendsProfileCategoryHeader : Int {
    case name = 0
    case lastName
    case nickName
    case cellNumber
    
    
    func headerText() -> String{
        switch self {
        case FriendsProfileCategoryHeader.name:
            return  NSLocalizedString("profile.user.data.firstname", comment: "ProfileCell FirstName header")
        case FriendsProfileCategoryHeader.lastName:
            return  NSLocalizedString("profile.user.data.lastname", comment: "ProfileCell FirstName header")
        case FriendsProfileCategoryHeader.nickName:
            return  NSLocalizedString("profile.user.data.nickname", comment: "ProfileCell NickName header")
        case FriendsProfileCategoryHeader.cellNumber:
            return  NSLocalizedString("profile.user.data.mobilenumber", comment: "ProfileCell Mobile Phone header")
        }
    }
    
    func imageType() -> UIImage {
        
        switch self {
        case FriendsProfileCategoryHeader.name:
            return  UIImage(named: "icnName")!
        case FriendsProfileCategoryHeader.lastName:
            return  UIImage(named: "icnName")!
        case FriendsProfileCategoryHeader.nickName:
            return  UIImage(named: "icnNickname")!
        case FriendsProfileCategoryHeader.cellNumber:
            return  UIImage(named: "icnMobile")!
        }
    }
    
}

