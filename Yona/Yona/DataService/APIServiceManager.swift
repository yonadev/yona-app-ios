//
//  APIServiceManager.swift
//  Yona
//
//  Created by Ben Smith on 31/03/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

public typealias BodyDataDictionary = [String: AnyObject]

class APIServiceManager {
    static let sharedInstance = APIServiceManager()
    var newUser: Users?
    var newGoal: Goal?
    var newActivity: Activities?
    var goals:[Goal] = [] //Array returning all the goals returned by getGoals
    var activities:[Activities] = [] //array containing all the activities returned by getActivities

    var serverMessage: ServerMessage? = "Everything OK"
    var serverCode: ServerCode? = "Everything OK"

    private init() {}
    
    private func callRequestWithAPIServiceResponse(body: BodyDataDictionary?, path: String, httpMethod: String, onCompletion:APIServiceResponse){
        
        guard let yonaPassword = getYonaPassword() else {
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

    
    private func createYonaPassword() {
        let password = NSUUID().UUIDString
        
        let keychain = KeychainSwift()
        
        keychain.set(password, forKey: YonaConstants.keychain.yonaPassword)
    }
    
    private func getYonaPassword() -> String? {
        let keychain = KeychainSwift()
        
        guard let password = keychain.get(YonaConstants.keychain.yonaPassword) else { return nil }
        
        return password
    }
    
    private func setServerCodeMessage(json:BodyDataDictionary) {
        if let message = json[YonaConstants.serverResponseKeys.message] as? String,
            let code = json[YonaConstants.serverResponseKeys.code] as? String {
                self.serverMessage = message
                self.serverCode = code
        }
    }
}

//MARK: - Activities APIService
extension APIServiceManager {
    func getActivityCategories(onCompletion: APIActivitiesArrayResponse){
        let path = YonaConstants.environments.test + YonaConstants.commands.activityCategories
        callRequestWithAPIServiceResponse(nil, path: path, httpMethod: YonaConstants.httpMethods.get, onCompletion: { success, json, err in
            if let json = json {
                self.setServerCodeMessage(json)
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
                    onCompletion(false, self.serverMessage, self.serverCode, nil, err)
            }
        })
    }
    
    func getActivityCategoryWithID(activityID: String, onCompletion: APIActivityResponse){
        //if the newActivites object has been filled then we can get the link to display activity
        let path = YonaConstants.environments.test + YonaConstants.commands.activityCategories + activityID
        callRequestWithAPIServiceResponse(nil, path: path, httpMethod: YonaConstants.httpMethods.get, onCompletion: { success, json, err in
            if let json = json {
                self.setServerCodeMessage(json)
                guard success == true else {
                    onCompletion(false, self.serverMessage, self.serverCode, nil, err)
                    return
                }
                print(json)
                self.newActivity = Activities.init(activityData: json)
                onCompletion(true, self.serverMessage, self.serverCode, self.newActivity, err)
            } else {
                onCompletion(false, self.serverMessage, self.serverCode, nil, err)
            }
        })
        
    }
}

//MARK: - Goal APIService
extension APIServiceManager {
    func getUserGoals(onCompletion: APIGoalArrayResponse) {
        if let userID = KeychainManager.sharedInstance.getUserID() {
            let path = YonaConstants.environments.test + YonaConstants.commands.users + userID + "/" + YonaConstants.commands.goals
            callRequestWithAPIServiceResponse(nil, path: path, httpMethod: YonaConstants.httpMethods.get, onCompletion: { success, json, err in

                if let json = json {
                    self.setServerCodeMessage(json)
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
                    onCompletion(false, self.serverMessage, self.serverCode, nil, err)
                }
            })
        }
    }
    
    func postUserGoals(body: BodyDataDictionary, onCompletion: APIGoalResponse) {
        if let userID = KeychainManager.sharedInstance.getUserID() {
            let path = YonaConstants.environments.test + YonaConstants.commands.users + userID + "/" + YonaConstants.commands.goals
            callRequestWithAPIServiceResponse(body, path: path, httpMethod: YonaConstants.httpMethods.post, onCompletion: { success, json, err in
                if let json = json {
                    self.setServerCodeMessage(json)
                    guard success == true else {
                        onCompletion(false, self.serverMessage, self.serverCode, nil, err)
                        return
                    }
                    self.newGoal = Goal.init(goalData: json)
                    onCompletion(true, self.serverMessage, self.serverCode, self.newGoal, err)
                } else {
                    onCompletion(false, self.serverMessage, self.serverCode, nil, err)
                }
            })
        }
    }
    
    func getUsersGoalWithID(goalID: String, onCompletion: APIGoalResponse) {
        if let userID = KeychainManager.sharedInstance.getUserID() {
            let path = YonaConstants.environments.test + YonaConstants.commands.users + userID + "/" + YonaConstants.commands.goals + goalID
            callRequestWithAPIServiceResponse(nil, path: path, httpMethod: YonaConstants.httpMethods.get, onCompletion: { success, json, err in
                if let json = json {
                    self.setServerCodeMessage(json)
                    guard success == true else {
                        onCompletion(false, self.serverMessage, self.serverCode, nil, err)
                        return
                    }
                    self.newGoal = Goal.init(goalData: json)
                    onCompletion(true, self.serverMessage, self.serverCode, self.newGoal, err)
                } else {
                    onCompletion(false, self.serverMessage, self.serverCode, nil, err)
                }
            })
        }
    }
    
    func deleteUserGoal(goalID: String, onCompletion: APIResponse) {
        if let userID = KeychainManager.sharedInstance.getUserID() {
            let path = YonaConstants.environments.test + YonaConstants.commands.users + userID + "/" + YonaConstants.commands.goals + goalID
            callRequestWithAPIServiceResponse(nil, path: path, httpMethod: YonaConstants.httpMethods.delete, onCompletion: { success, json, err in
                if let json = json {
                    self.setServerCodeMessage(json)
                    guard success == true else {
                        onCompletion(false, self.serverMessage, self.serverCode)
                        return
                    }
                    onCompletion(true, self.serverMessage, self.serverCode)
                } else {
                    onCompletion(false, self.serverMessage, self.serverCode)
                }
            })
        }
    }
}

//MARK: - User APIService
extension APIServiceManager {

    func postUser(body: BodyDataDictionary, onCompletion: APIResponse) {
        //create a password for the user
        KeychainManager.sharedInstance.createYonaPassword()
        //set the path to post
        let path = YonaConstants.environments.test + YonaConstants.commands.users
        callRequestWithAPIServiceResponse(body, path: path, httpMethod: YonaConstants.httpMethods.post, onCompletion: { success, json, err in
            if let json = json {
                self.setServerCodeMessage(json)
                guard success == true else {
                    onCompletion(false, self.serverMessage, self.serverCode)
                    return
                }
                self.newUser = Users.init(userData: json)
                onCompletion(true, self.serverMessage, self.serverCode)
            } else {
                onCompletion(false, self.serverMessage, self.serverCode)
            }
        })
    }
    
    func updateUser(body: BodyDataDictionary, onCompletion: APIResponse) {
        //get the new user object
        if let newUser = newUser {
            //get the edit link
            if let getUserLink = newUser.editLink {
                ///now post updated user data
                callRequestWithAPIServiceResponse(body, path: getUserLink, httpMethod: YonaConstants.httpMethods.post, onCompletion: { success, json, err in
                    if let json = json {
                        self.setServerCodeMessage(json)
                        guard success == true else {
                            onCompletion(false, self.serverMessage, self.serverCode)
                            return
                        }
                        self.newUser = Users.init(userData: json)
                        onCompletion(true, self.serverMessage, self.serverCode)
                    } else {
                        onCompletion(false, self.serverMessage, self.serverCode)
                    }
                })
            }
        }
    }
    
    func getUser(onCompletion: APIResponse) {
        if let newUser = newUser {
            if let getUserLink = newUser.getSelfLink {
                callRequestWithAPIServiceResponse(nil, path: getUserLink, httpMethod: YonaConstants.httpMethods.post, onCompletion: { success, json, err in
                    if let json = json {
                        self.setServerCodeMessage(json)
                        guard success == true else {
                            onCompletion(false, self.serverMessage, self.serverCode)
                            return
                        }
                        self.newUser = Users.init(userData: json)
                        onCompletion(true, self.serverMessage, self.serverCode)
                    } else {
                        onCompletion(false, self.serverMessage, self.serverCode)
                    }
                })
            }

        } else { onCompletion(false, self.serverMessage, self.serverCode) }
    }
    
    func deleteUser(onCompletion: APIResponse) {
        if let newUser = newUser,
            let path = newUser.editLink {
                callRequestWithAPIServiceResponse(nil, path: path, httpMethod: YonaConstants.httpMethods.delete) { success, json, err in
                    if let json = json {
                        self.setServerCodeMessage(json)
                        guard success == true else {
                            onCompletion(false, self.serverMessage, self.serverCode)
                            return
                        }
                        KeychainManager.sharedInstance.clearKeyChain()
                        self.newUser = Users.init(userData: json)
                        onCompletion(true, self.serverMessage, self.serverCode)
                    } else {
                        onCompletion(false, self.serverMessage, self.serverCode)
                    }
                }
        } else { onCompletion(false, self.serverMessage, self.serverCode) }
        
    }
    
    func otpResendMobile(body: BodyDataDictionary?, onCompletion: APIServiceResponse) {
        if let userID = KeychainManager.sharedInstance.getUserID(),
            let otpResendMobileLink = KeychainManager.sharedInstance.getOtpResendMobileLink(){
            #if DEBUG
                print(userID)
                print(otpResendMobileLink)
            #endif
            
            callRequestWithAPIServiceResponse(body, path: otpResendMobileLink, httpMethod: YonaConstants.httpMethods.post) { success, dict, err in
                if (success){
                    onCompletion(true, dict , err)
                } else {
                    onCompletion(false, dict , err)
                }
            }
        } else { onCompletion(false, [:] , nil) }
        
    }
    

    func confirmMobileNumber(body: BodyDataDictionary?, onCompletion: APIServiceResponse) {
        if let confirmMobileLink = KeychainManager.sharedInstance.getConfirmMobileLink(){
            #if DEBUG
            print(confirmMobileLink)
            #endif

            callRequestWithAPIServiceResponse(body, path: confirmMobileLink, httpMethod: YonaConstants.httpMethods.post) { success, dict, err in
                if (success){
                    onCompletion(true, dict , err)
                } else {
                    onCompletion(false, dict , err)
                }
            }
        } else { onCompletion(false, [:] , nil) }
    
    }
}
