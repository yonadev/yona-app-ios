//
//  Enums.swift
//  Yona
//
//  Created by Ben Smith on 20/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

enum ViewControllerTypeString: String {
    case walkThrough = "WalkThrough"
    case welcome = "Welcome"
    case confirmMobileValidation = "confirmPinValidationViewController"
    case pinResetValidation = "pinResetValidationController"
    case adminOverrideValidation = "adminOverrideValidationViewController"
    case passcode = "Passcode"
    case login = "Login"
    case dashboard = "Dashboard"
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
    case OK
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
    case selfKey = "self"
    case links = "_links"
    case edit = "edit"
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

    case dateFormat = "YYYY-MM-dd'T'HH:mm:ss.SSZZZ"
    case dateFormatSimple = "YYYY-MM-dd"
    case dateFormatWeek = "yyyy'-W'w"
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
    case FirstName = 0
    case LastName
    case NickName
    case CellNumber
    
    
    func headerText() -> String{
        switch self {
        case ProfileCategoryHeader.FirstName:
            return  NSLocalizedString("profile.user.data.firstname", comment: "ProfileCell FirstName header")
        case ProfileCategoryHeader.LastName:
            return  NSLocalizedString("profile.user.data.lastname", comment: "ProfileCell LastName header")
        case ProfileCategoryHeader.NickName:
            return  NSLocalizedString("profile.user.data.nickname", comment: "ProfileCell NickName header")
        case ProfileCategoryHeader.CellNumber:
            return  NSLocalizedString("profile.user.data.mobilenumber", comment: "ProfileCell Mobile Phone header")
        }
    }

    func imageType() -> UIImage {
        
        switch self {
        case ProfileCategoryHeader.FirstName:
            return  UIImage(named: "icnName")!
        case ProfileCategoryHeader.LastName:
            return  UIImage(named: "icnName")!
        case ProfileCategoryHeader.NickName:
            return  UIImage(named: "icnNickname")!
        case ProfileCategoryHeader.CellNumber:
            return  UIImage(named: "icnMobile")!
        }
    }

}

