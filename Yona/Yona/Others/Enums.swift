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