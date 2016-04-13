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
    var newActivities: Activities?

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
}

//MARK: - Activities APIService
extension APIServiceManager {
    func getActivityCategories(onCompletion: APIResponse){
        let path = YonaConstants.environments.test + YonaConstants.commands.activityCategories
        callRequestWithAPIServiceResponse(nil, path: path, httpMethod: YonaConstants.httpMethods.get, onCompletion: { success, json, err in
            guard success == true else { onCompletion(false); return}
            if let json = json {
                self.newActivities = Activities.init(activityData: json)
                onCompletion(true)
            } else {
                onCompletion(false)
            }
        })
    }
    
    func getActivityCategoryWithID(activityID: String, onCompletion: APIServiceResponse){
        //if the newActivites object has been filled then we can get the link to display activity
        let path = YonaConstants.environments.test + YonaConstants.commands.activityCategories + activityID
        callRequestWithAPIServiceResponse(nil, path: path, httpMethod: YonaConstants.httpMethods.get, onCompletion: { success, json, err in
            guard success == true else { onCompletion(false, json, err); return}
            if let json = json {
                print(json)
                onCompletion(true, json, err)
            } else {
                onCompletion(false, json, err)
            }
        })
        
    }
}

//MARK: - Goal APIService
extension APIServiceManager {
    func getUserGoals(onCompletion: APIResponse) {
        if let userID = NSUserDefaults.standardUserDefaults().objectForKey(YonaConstants.nsUserDefaultsKeys.userID) as? String {
            let path = YonaConstants.environments.test + YonaConstants.commands.users + userID + "/" + YonaConstants.commands.goals
            callRequestWithAPIServiceResponse(nil, path: path, httpMethod: YonaConstants.httpMethods.get, onCompletion: { success, json, err in
                guard success == true else { onCompletion(false); return}
                if let json = json {
                    self.newGoal = Goal.init(goalData: json)
                    onCompletion(true)
                } else {
                    onCompletion(false)
                }
            })
        }
        onCompletion(false)
    }
    
    func postUserGoals(body: BodyDataDictionary, onCompletion: APIResponse) {
        if let userID = NSUserDefaults.standardUserDefaults().objectForKey(YonaConstants.nsUserDefaultsKeys.userID) as? String {
            let path = YonaConstants.environments.test + YonaConstants.commands.users + userID + "/" + YonaConstants.commands.goals
            callRequestWithAPIServiceResponse(body, path: path, httpMethod: YonaConstants.httpMethods.post, onCompletion: { success, json, err in
                guard success == true else { onCompletion(false); return}
                if let json = json {
                    self.newGoal = Goal.init(goalData: json)
                    onCompletion(true)
                } else {
                    onCompletion(false)
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
            guard success == true else { onCompletion(false); return }
            if let json = json {
                self.newUser = Users.init(userData: json)
                onCompletion(true)
            } else {
                onCompletion(false)
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
                    guard success == true else { onCompletion(false); return }
                    if let json = json {
                        self.newUser = Users.init(userData: json)
                        onCompletion(true)
                    } else {
                        onCompletion(false)
                    }
                })
            }
        }
    }
    
    func getUser(onCompletion: APIResponse) {
        if let newUser = newUser {
            if let getUserLink = newUser.getSelfLink {
                callRequestWithAPIServiceResponse(nil, path: getUserLink, httpMethod: YonaConstants.httpMethods.post, onCompletion: { success, dict, err in
                    if success {
                        onCompletion(true)
                    } else {
                        onCompletion(false)
                    }
                })
            }

        } else { onCompletion(false) }
    }
    
    func deleteUser(onCompletion: APIResponse) {
        if let newUser = newUser,
            let path = newUser.editLink {
                callRequestWithAPIServiceResponse(nil, path: path, httpMethod: YonaConstants.httpMethods.delete) { success, dict, err in
                    if (success){
                        onCompletion(true)
                    } else {
                        onCompletion(false)
                    }
                }
        } else { onCompletion(false) }
        
    }
    
    func otpResendMobile(body: BodyDataDictionary?, onCompletion: APIServiceResponse) {
        if let userID = NSUserDefaults.standardUserDefaults().objectForKey(YonaConstants.nsUserDefaultsKeys.userID) as? String,
            let otpResendMobileLink = NSUserDefaults.standardUserDefaults().objectForKey(YonaConstants.nsUserDefaultsKeys.otpResendMobileKeyURL) as? String{
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
        if let confirmMobileLink = NSUserDefaults.standardUserDefaults().objectForKey(YonaConstants.nsUserDefaultsKeys.confirmMobileKeyURL) as? String{
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
