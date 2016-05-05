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

enum userRequestTypes{
    case postUser
    case deleteUser
    case getUser
    case putUser
    case confirmMobile
    case resendMobileConfirmCode
}

enum responseCodes: Int{
    case ok200 = 200
    case ok204 = 204
    case timeoutRequest = 408
    case timeoutRequest2 = -1001
    case networkFail = 3
}

enum timeBucketTabNames: String{
    case budget = "Budget"
    case timeZone = "TimeZone"
    case noGo = "NoGo"
}

