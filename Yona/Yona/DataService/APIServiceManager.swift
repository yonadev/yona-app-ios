//
//  APIServiceManager.swift
//  Yona
//
//  Created by Ben Smith on 31/03/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation
import SystemConfiguration

public typealias BodyDataDictionary = [String: AnyObject]

class APIServiceManager {
    static let sharedInstance = APIServiceManager()
    private var newUser: Users?
    private var newGoal: Goal?
    private var newActivity: Activities?
    private var goals:[Goal] = [] //Array returning all the goals returned by getGoals
    private var budgetGoals:[Goal] = [] //Array returning budget goals
    private var timezoneGoals:[Goal] = [] //Array returning timezone goals
    private var noGoGoals:[Goal] = [] //Array returning no go goals
    private var activities:[Activities] = [] //array containing all the activities returned by getActivities
    
    private var serverMessage: ServerMessage?
    private var serverCode: ServerCode?
    
    private init() {}
    
    private func callRequestWithAPIServiceResponse(body: BodyDataDictionary?, path: String, httpMethod: String, onCompletion:APIServiceResponse){
        
        guard let yonaPassword =  KeychainManager.sharedInstance.getYonaPassword() else {
            onCompletion(false,nil,nil)
            return
        }
        let httpHeader = ["Content-Type": "application/json", "Yona-Password": yonaPassword]
        Manager.sharedInstance.makeRequest(path, body: body, httpMethod: httpMethod, httpHeader: httpHeader, onCompletion: { success, dict, err in
            if (success){
                onCompletion(true, dict , err)
            } else {
                onCompletion(false, dict , err)
            }
        })   
    }

    func setServerCodeMessage(json:BodyDataDictionary?, code: Int) {
        //check if json is empty
        
        if case YonaConstants.responseCodes.ok200 ... YonaConstants.responseCodes.ok204 = code { // successful you get 200 to 204 back, anything else...Houston we gotta a problem
            self.serverMessage = YonaConstants.serverMessages.OK
            self.serverCode = YonaConstants.serverCodes.OK
        } else {
            if let jsonUnwrapped = json,
                let message = jsonUnwrapped[YonaConstants.serverResponseKeys.message] as? String{
                    self.serverMessage = message
                    if let serverCode = jsonUnwrapped[YonaConstants.serverResponseKeys.code] as? String{
                        self.serverCode = serverCode
                    } else {
                        self.serverCode = String(code)
                    }
                }
        }

    }
    
    func getActivitiesArray(onCompletion: APIActivitiesArrayResponse) {
        self.APIServiceCheck { (success, networkMessage, networkCode) in
            if success {
                self.getActivityCategories{ (success, serverMessage, serverCode, activities, error) in
                    onCompletion(success, serverMessage, serverCode, activities, error)
                }
            } else { //if no network
                //activities not initialised no network fail with no data
                guard self.activities.isEmpty else {
                    onCompletion(false, networkMessage, networkCode, nil, nil)
                    return
                }
                //if we already got some activities then just send back the ones we have...
                onCompletion(false, networkMessage, networkCode, self.activities, nil)
                
            }
        }
    }
    
    
    func getAllTheGoalsArray(onCompletion: APIGoalArrayResponse) {
        self.getUserGoals{ (success, serverMessage, serverCode, goals, error) in
            onCompletion(success, serverMessage, serverCode, goals, error)
        }
    }
    
    func getGoalsOfType(goalType: GoalType, onCompletion: APIGoalArrayResponse) {
        self.APIServiceCheck { (success, networkMessage, networkCode) in
            if success {
                self.getUserGoals{ (success, serverMessage, serverCode, goals, error) in
                    self.sortGoalsIntoArray(goalType, onCompletion: { (success, serverMessage, serverCode, goals, error) in
                        onCompletion(success, serverMessage, serverCode, goals, error)
                    })
                }
            } else {
                //Goals not initialised
                guard self.goals.isEmpty else {
                    onCompletion(false, networkMessage, networkCode, nil, nil)
                    return
                }
                //if we already got some goals then just send back the ones we have...
                self.sortGoalsIntoArray(goalType) { (success, message, code, goals, error) in
                    onCompletion(false, networkMessage, networkCode, goals, error)
                }
            }
        }
    }
    
    func getActivityLinkForActivityName(activityName: CategoryName, onCompletion: APIActivityLinkResponse) {
        self.getActivitiesArray{ (success, message, code, activities, error) in
            if success {
                var activityCategoryLink:String?
                
                for activity in (activities! as Array) {
                    switch activity.activityCategoryName! {
                    case activityName.rawValue:  
                        activityCategoryLink = activity.selfLinks!
                    case activityName.rawValue:
                        activityCategoryLink = activity.selfLinks!
                    case activityName.rawValue:
                        activityCategoryLink = activity.selfLinks!
                    default:
                        break
                    }
                }
                onCompletion(true, activityCategoryLink, message, code)
            } else {
                onCompletion(false, nil, message, code)
            }
        }
    }
    
    func getGoalsSizeOfGoalType(goalType: GoalType, onCompletion: APIGoalSizeResponse) {
        
        switch goalType {
        case GoalType.BudgetGoalString:
            guard budgetGoals.isEmpty else {
                onCompletion(0)
                return
            }
            onCompletion(budgetGoals.count)
        case GoalType.TimeZoneGoalString:
            guard timezoneGoals.isEmpty else {
                onCompletion(0)
                return
            }
            onCompletion(timezoneGoals.count)
        case GoalType.NoGoGoalString:
            guard noGoGoals.isEmpty else {
                onCompletion(0)
                return
            }
            onCompletion(noGoGoals.count)
        }
    }
    
    private func sortGoalsIntoArray(goalType: GoalType, onCompletion: APIGoalArrayResponse){
        budgetGoals = []
        timezoneGoals = []
        noGoGoals = []
        //sort out the goals into their arrays
        for goal in goals {
            
            switch goal.goalType! {
            case GoalType.BudgetGoalString.rawValue:
                budgetGoals.append(goal)
            case GoalType.TimeZoneGoalString.rawValue:
                timezoneGoals.append(goal)
            case GoalType.NoGoGoalString.rawValue:
                noGoGoals.append(goal)
            default:
                break
            }
        }
        //which array shall we send back?
        switch goalType {
        case GoalType.BudgetGoalString:
            onCompletion(true, serverMessage, serverCode, budgetGoals, nil)
        case GoalType.TimeZoneGoalString:
            onCompletion(true, serverMessage, serverCode, timezoneGoals, nil)
        case GoalType.NoGoGoalString:
            onCompletion(true, serverMessage, serverCode, noGoGoals, nil)
        }
    }

    /**
     Check if there is an active network connection for the device
     
     - returns: Network connetion status (Bool)
     */
    func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
    func APIServiceCheck(onCompletion: APIResponse) {
        //initialise server code and messages to OK
        self.serverMessage = YonaConstants.serverMessages.OK
        self.serverCode = YonaConstants.serverCodes.OK
        //check for network connection
        guard isConnectedToNetwork() else {
            //if it fails then send messages back saying no connection
            onCompletion(false, YonaConstants.serverMessages.noConnection, YonaConstants.serverCodes.noConnection)
            return
        }
        //if not then return success
        onCompletion(true, self.serverMessage, self.serverCode)
    }
}


//MARK: - New Device Requests APIService
extension APIServiceManager {
    func putNewDevice(mobileNumber: String, onCompletion: APIResponse) {
        APIServiceCheck { (success, message, code) in
            if success {
                let path = YonaConstants.environments.test + YonaConstants.commands.newDeviceRequests + mobileNumber
                if let password = KeychainManager.sharedInstance.getYonaPassword() {
                    let bodyNewDevice = [
                        "newDeviceRequestPassword": password
                    ]
                    self.callRequestWithAPIServiceResponse(bodyNewDevice, path: path, httpMethod: YonaConstants.httpMethods.put, onCompletion: { (success, json, error) in
                        guard success == true else {
                            onCompletion(false, self.serverMessage, self.serverCode)
                            return
                        }
                        onCompletion(true, self.serverMessage, self.serverCode)
                        
                    })
                }
            } else {
                onCompletion(false, message, code)
            }
        }
    }
}

//MARK: - Activities APIService
extension APIServiceManager {
    func getActivityCategories(onCompletion: APIActivitiesArrayResponse){
        APIServiceCheck { (success, message, code) in
            if success {
                let path = YonaConstants.environments.test + YonaConstants.commands.activityCategories
                self.callRequestWithAPIServiceResponse(nil, path: path, httpMethod: YonaConstants.httpMethods.get, onCompletion: { success, json, err in
                    if let json = json {
                        guard success == true else {
                            onCompletion(false, self.serverMessage, self.serverCode, nil, err)
                            return
                        }
                        //reset the array so start with new set of activities
                        self.activities = []
                        if let embedded = json[YonaConstants.jsonKeys.embedded],
                            let embeddedActivities = embedded[YonaConstants.jsonKeys.activityCategories] as? NSArray{
                            for activity in embeddedActivities {
                                if let activity = activity as? BodyDataDictionary {
                                    self.newActivity = Activities.init(activityData: activity)
                                    self.activities.append(self.newActivity!)
                                }
                            }
                            onCompletion(true, self.serverMessage, self.serverCode, self.activities, err)
                        }
                    } else {
                        //response from request failed
                        onCompletion(false, self.serverMessage, self.serverCode, nil, err)
                    }
                })
            } else {
                //return response from APIService Check, no network
                onCompletion(false, message, code, self.activities, nil)
            }
        }
    }
    
    func getActivityCategoryWithID(activityID: String, onCompletion: APIActivityResponse){
        APIServiceCheck { (success, message, code) in
            if success {
                //if the newActivites object has been filled then we can get the link to display activity
                let path = YonaConstants.environments.test + YonaConstants.commands.activityCategories + activityID
                self.callRequestWithAPIServiceResponse(nil, path: path, httpMethod: YonaConstants.httpMethods.get, onCompletion: { success, json, err in
                    if let json = json {
                        guard success == true else {
                            onCompletion(false, self.serverMessage, self.serverCode, nil, err)
                            return
                        }
                        print(json)
                        self.newActivity = Activities.init(activityData: json)
                        onCompletion(true, self.serverMessage, self.serverCode, self.newActivity, err)
                    } else {
                        //response from request failed
                        onCompletion(false, self.serverMessage, self.serverCode, nil, err)
                    }
                })
            } else {
                //network fail
                onCompletion(false, message, code, nil, nil)
            }
        }
    }
}

//MARK: - Goal APIService
extension APIServiceManager {
    func getUserGoals(onCompletion: APIGoalArrayResponse) {
        APIServiceCheck { (success, message, code) in
            if success {
                if let userID = KeychainManager.sharedInstance.getUserID() {
                    let path = YonaConstants.environments.test + YonaConstants.commands.users + userID + "/" + YonaConstants.commands.goals
                    self.callRequestWithAPIServiceResponse(nil, path: path, httpMethod: YonaConstants.httpMethods.get, onCompletion: { success, json, err in

                        if let json = json {
                            guard success == true else {
                                onCompletion(false, self.serverMessage, self.serverCode, nil, err)
                                return
                            }
                            self.goals = []
                            if let embedded = json[YonaConstants.jsonKeys.embedded],
                                let embeddedGoals = embedded[YonaConstants.jsonKeys.yonaGoals] as? NSArray{
                                for goal in embeddedGoals {
                                    if let goal = goal as? BodyDataDictionary {
                                        self.newGoal = Goal.init(goalData: goal)
                                        self.goals.append(self.newGoal!)
                                    }
                                }
                                onCompletion(true, self.serverMessage, self.serverCode, self.goals, err)
                            }
                        } else {
                            //response from request failed
                            onCompletion(false, self.serverMessage, self.serverCode, nil, err)
                        }
                    })
                }
            } else {
                onCompletion(false, message, code, self.goals, nil)
            }
        }
    }
    
    func postUserGoals(body: BodyDataDictionary, onCompletion: APIGoalResponse) {
        APIServiceCheck { (success, message, code) in
            if success {
                if let userID = KeychainManager.sharedInstance.getUserID() {
                    let path = YonaConstants.environments.test + YonaConstants.commands.users + userID + "/" + YonaConstants.commands.goals
                    self.callRequestWithAPIServiceResponse(body, path: path, httpMethod: YonaConstants.httpMethods.post, onCompletion: { success, json, err in
                        if let json = json {
                            guard success == true else {
                                onCompletion(false, self.serverMessage, self.serverCode, nil, err)
                                return
                            }
                            self.newGoal = Goal.init(goalData: json)
                            onCompletion(true, self.serverMessage, self.serverCode, self.newGoal, err)
                        } else {
                            //response from request failed, json is nil
                            onCompletion(false, self.serverMessage, self.serverCode, nil, err)
                        }
                    })
                } else {
                //response from request failed, json is nil
                    //Failed to retrive details for GET user details request
                    self.setServerCodeMessage([YonaConstants.serverResponseKeys.message: YonaConstants.serverCodes.FailedToRetrieveGetUserGoals,
                        YonaConstants.serverResponseKeys.code: YonaConstants.serverCodes.FailedToRetrieveGetUserGoals], code: 1)
                    onCompletion(false, self.serverMessage, self.serverCode, nil, nil)
                }
            } else {
                onCompletion(false, message, code, nil, nil)
            }
        }
    }
    
    func getUsersGoalWithID(goalID: String, onCompletion: APIGoalResponse) {
        APIServiceCheck { (success, message, code) in
            if success {
                if let userID = KeychainManager.sharedInstance.getUserID() {
                    let path = YonaConstants.environments.test + YonaConstants.commands.users + userID + "/" + YonaConstants.commands.goals + goalID
                    self.callRequestWithAPIServiceResponse(nil, path: path, httpMethod: YonaConstants.httpMethods.get, onCompletion: { success, json, err in
                        if let json = json {
                            guard success == true else {
                                onCompletion(false, self.serverMessage, self.serverCode, nil, err)
                                return
                            }
                            self.newGoal = Goal.init(goalData: json)
                            onCompletion(true, self.serverMessage, self.serverCode, self.newGoal, err)
                        } else {
                            //response from request failed, json is nil
                            onCompletion(false, self.serverMessage, self.serverCode, nil, err)
                        }
                    })
                }
            } else {
                //passes back network failed messages
                onCompletion(false, message, code, nil, nil)
            }
        }
    }
    
    func deleteUserGoal(goalID: String, onCompletion: APIResponse) {
        APIServiceCheck { (success, message, code) in
            if success {
                if let userID = KeychainManager.sharedInstance.getUserID() {
                    let path = YonaConstants.environments.test + YonaConstants.commands.users + userID + "/" + YonaConstants.commands.goals + goalID
                    self.callRequestWithAPIServiceResponse(nil, path: path, httpMethod: YonaConstants.httpMethods.delete, onCompletion: { success, json, err in
                        guard success == true else {
                            onCompletion(false, self.serverMessage, self.serverCode)
                            return
                        }
                        onCompletion(true, self.serverMessage, self.serverCode)

                    })
                }
            } else {
                onCompletion(false, message, code)
            }
        }
    }
}

//MARK: - User APIService
extension APIServiceManager {

    func postUser(body: BodyDataDictionary, onCompletion: APIUserResponse) {
        APIServiceCheck { (success, message, code) in
            if success {
                //create a password for the user
                KeychainManager.sharedInstance.createYonaPassword()
                //set the path to post
                let path = YonaConstants.environments.test + YonaConstants.commands.users
                self.callRequestWithAPIServiceResponse(body, path: path, httpMethod: YonaConstants.httpMethods.post, onCompletion: { success, json, err in
                    if let json = json {
                        guard success == true else {
                            onCompletion(false, self.serverMessage, self.serverCode,nil)
                            return
                        }
                        self.newUser = Users.init(userData: json)
                        //intialise the goals and the activities
                        self.getActivitiesArray({ (success, message, code, activities, error) in
                            if success {
                                self.getAllTheGoalsArray({ (success, message, code, goals, error) in
                                    if success {
                                        onCompletion(true, self.serverMessage, self.serverCode,self.newUser)
                                    } else {
                                        onCompletion(false, self.serverMessage, self.serverCode, self.newUser)
                                    }
                                })
                            } else {
                                onCompletion(false, self.serverMessage, self.serverCode, self.newUser)
                            }
                        })
                    } else {
                        //response from request failed
                        onCompletion(false, self.serverMessage, self.serverCode,nil)
                    }
                })
            } else {
                //network fail
                onCompletion(false, message, code, nil)
            }
        }
    }
    
    func updateUser(body: BodyDataDictionary, onCompletion: APIResponse) {
        APIServiceCheck { (success, message, code) in
            if success {
                //get the new user object
                if let newUser = self.newUser,
                    let getUserLink = newUser.editLink {
                        ///now post updated user data
                        self.callRequestWithAPIServiceResponse(body, path: getUserLink, httpMethod: YonaConstants.httpMethods.post, onCompletion: { success, json, err in
                            if let json = json {
                                guard success == true else {
                                    onCompletion(false, self.serverMessage, self.serverCode)
                                    return
                                }
                                self.newUser = Users.init(userData: json)
                                onCompletion(true, self.serverMessage, self.serverCode)
                            } else {
                                //response from request failed
                                onCompletion(false, self.serverMessage, self.serverCode)
                            }
                        })
                } else {
                    //Failed to retrive details for POST user details request
                    self.setServerCodeMessage([YonaConstants.serverResponseKeys.message: YonaConstants.serverCodes.FailedToRetrieveUpdateUserDetails,
                        YonaConstants.serverResponseKeys.code: YonaConstants.serverCodes.FailedToRetrieveUpdateUserDetails], code: 1)
                    onCompletion(false, self.serverMessage, self.serverCode)
                }
            } else {
                onCompletion(false, message, code)
            }
        }
    }
    
    func getUser(onCompletion: APIUserResponse) {
        APIServiceCheck { (success, message, code) in
            if success {
                if let newUser = self.newUser {
                    if let getUserLink = newUser.getSelfLink {
                        self.callRequestWithAPIServiceResponse(nil, path: getUserLink, httpMethod: YonaConstants.httpMethods.post, onCompletion: { success, json, err in
                            if let json = json {
                                guard success == true else {
                                    onCompletion(false, self.serverMessage, self.serverCode,nil)
                                    return
                                }
                                self.newUser = Users.init(userData: json)
                                onCompletion(true, self.serverMessage, self.serverCode,self.newUser)
                            } else {
                                //response from request failed
                                onCompletion(false, self.serverMessage, self.serverCode,nil)
                            }
                        })
                    }

                } else {
                    //Failed to retrive details for GET user details request
                    self.setServerCodeMessage([YonaConstants.serverResponseKeys.message: YonaConstants.serverCodes.FailedToRetrieveGetUserDetails,
                        YonaConstants.serverResponseKeys.code: YonaConstants.serverCodes.FailedToRetrieveGetUserDetails], code: 1)
                    onCompletion(false, self.serverMessage, self.serverCode,nil)
                }
            } else {
                onCompletion(false, message, code,nil)
            }
        }
    }
    
    func deleteUser(onCompletion: APIResponse) {
        APIServiceCheck { (success, message, code) in
            if success{
                if let newUser = self.newUser,
                    let path = newUser.editLink {
                        self.callRequestWithAPIServiceResponse(nil, path: path, httpMethod: YonaConstants.httpMethods.delete) { success, json, err in
                            if let json = json {
                                guard success == true else {
                                    onCompletion(false, self.serverMessage, self.serverCode)
                                    return
                                }
                                KeychainManager.sharedInstance.clearKeyChain()
                                self.newUser = Users.init(userData: json)
                                onCompletion(true, self.serverMessage, self.serverCode)
                            } else {
                                //response from request failed
                                onCompletion(false, self.serverMessage, self.serverCode)
                            }
                        }
                    } else {
                        //Failed to retrive details for delete user request
                        self.setServerCodeMessage([YonaConstants.serverResponseKeys.message: YonaConstants.serverCodes.FailedToRetrieveUserDetailsForDeleteUser,
                            YonaConstants.serverResponseKeys.code: YonaConstants.serverCodes.FailedToRetrieveUserDetailsForDeleteUser], code: 1)
                        onCompletion(false, self.serverMessage, self.serverCode)
                    }
                } else {
                onCompletion(false, message, code)
            }
        }
    }
    
    func otpResendMobile(body: BodyDataDictionary?, onCompletion: APIResponse) {
        APIServiceCheck { (success, message, code) in
            if success {
                if let userID = KeychainManager.sharedInstance.getUserID(),
                    let otpResendMobileLink = KeychainManager.sharedInstance.getOtpResendMobileLink(){
                    #if DEBUG
                        print(userID)
                        print(otpResendMobileLink)
                    #endif
                    
                    self.callRequestWithAPIServiceResponse(body, path: otpResendMobileLink, httpMethod: YonaConstants.httpMethods.post) { success, json, err in
                        guard success == true else {
                            onCompletion(false, self.serverMessage, self.serverCode)
                            return
                        }
                        onCompletion(true, self.serverMessage, self.serverCode)
                    }
                } else {
                    //Failed to retrive details for otp resend request
                    self.setServerCodeMessage([YonaConstants.serverResponseKeys.message: YonaConstants.serverCodes.FailedToRetrieveOTP,
                        YonaConstants.serverResponseKeys.code: YonaConstants.serverCodes.FailedToRetrieveOTP], code: 1)
                    onCompletion(false, self.serverMessage, self.serverCode)
                }
            } else {
                //no network connection
                onCompletion(false, self.serverMessage, self.serverCode)
            }
        }
    }
    
    func confirmMobileNumber(body: BodyDataDictionary?, onCompletion: APIResponse) {
        APIServiceCheck { (success, message, code) in
            if success {
                if let confirmMobileLink = KeychainManager.sharedInstance.getConfirmMobileLink(){
                    #if DEBUG
                        print(confirmMobileLink)
                    #endif
                    
                    self.callRequestWithAPIServiceResponse(body, path: confirmMobileLink, httpMethod: YonaConstants.httpMethods.post) { success, json, err in
                        guard success == true else {
                            print(err)
                            onCompletion(false, self.serverMessage, self.serverCode)
                            return
                        }
                        onCompletion(true, self.serverMessage, self.serverCode)
                    }
                } else {
                    //Failed to retrive details for confirm mobile request
                    self.setServerCodeMessage([YonaConstants.serverResponseKeys.message: YonaConstants.serverCodes.FailedToRetrieveConfirmMobile,
                        YonaConstants.serverResponseKeys.code: YonaConstants.serverCodes.FailedToRetrieveConfirmMobile], code: 1)
                    onCompletion(false, self.serverMessage, self.serverCode)
                }
            } else {
                //network fail
                onCompletion(false, self.serverMessage, self.serverCode)
            }
        }
    }
}