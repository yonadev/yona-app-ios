//
//  Enums.swift
//  Yona
//
//  Created by Ben Smith on 20/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

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

enum AllowedGetUserRequest{
    case deleteDeviceRequest
    case pinReset
    case other
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

enum errorDomains: String {
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
