//
//  APIServiceManager.swift
//  Yona
//
//  Created by Ben Smith on 31/03/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

public typealias UserData = [String: AnyObject]

class APIServiceManager {
    static let sharedInstance = APIServiceManager()
    
    private init() {}
    
    var newUser: Users?

    func postUser(body: UserData, onCompletion: APIResponse) {
        KeychainManager.sharedInstance.createYonaPassword()
        let path = YonaConstants.environments.test + YonaConstants.commands.users
        callUserRequest(path, body: body, httpMethod: YonaConstants.httpMethods.post, onCompletion: { (success) in
            if success {
                onCompletion(true)
            } else {
                onCompletion(false)
            }
        })
    }
    
    func updateUser(body: UserData, onCompletion: APIResponse) {
        if let newUser = newUser {
            if let getUserLink = newUser.editLink {
                callUserRequest(getUserLink, body: body, httpMethod: YonaConstants.httpMethods.post, onCompletion: { (success) in
                    if success {
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
                callUserRequest(getUserLink, body: nil, httpMethod: YonaConstants.httpMethods.get, onCompletion: { (success) in
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
            let userID = newUser.userID,
            let path = newUser.editLink {
                callRequest(nil, userID: userID, path: path, httpMethod: YonaConstants.httpMethods.delete) { success, dict, err in
                    if (success){
                        onCompletion(true)
                    } else {
                        onCompletion(false)
                    }
                }
        } else { onCompletion(false) }
        
    }
    
    func confirmMobileNumber(body: UserData?, onCompletion: APIServiceResponse) {
        if let userID = NSUserDefaults.standardUserDefaults().objectForKey(YonaConstants.nsUserDefaultsKeys.userID) as? String,
            let confirmMobileLink = NSUserDefaults.standardUserDefaults().objectForKey(YonaConstants.nsUserDefaultsKeys.confirmMobileKeyURL) as? String{
            #if DEBUG
            print(userID)
            print(confirmMobileLink)
            #endif

            callRequest(body,userID: userID, path: confirmMobileLink, httpMethod: YonaConstants.httpMethods.post) { success, dict, err in
                if (success){
                    onCompletion(true, dict , err)
                } else {
                    onCompletion(false, dict , err)
                }
            }
        } else { onCompletion(false, nil , nil) }
    
    }
    
    private func callRequest(body: UserData?, userID: String, path: String, httpMethod: String, onCompletion:APIServiceResponse){
        
        guard let yonaPassword = getYonaPassword() else {
            onCompletion(false,nil,nil)
            return
        }
        let httpHeader = ["Content-Type": "application/json", "Yona-Password": yonaPassword, "id":userID]

        //POST /users/{id}/confirmMobileNumber
        UserManager.sharedInstance.makeRequest(path, body: body, httpMethod: httpMethod, httpHeader: httpHeader, onCompletion: { success, dict, err in
            if (success){
                onCompletion(true, dict , err)
            } else {
                onCompletion(false, dict , err)
            }
        })
            
        
    }
    
    private func callUserRequest(path: String, body: UserData?, httpMethod: String, onCompletion: APIResponse) {
        guard let yonaPassword = getYonaPassword() else {
            onCompletion(false)
            return
        }
        
        let httpHeader = ["Content-Type": "application/json", "Yona-Password": yonaPassword]
        UserManager.sharedInstance.makeUserRequest(path, body: body, httpMethod: httpMethod, httpHeader: httpHeader, onCompletion: { success, json, err in
            if let json = json {
                self.newUser = Users.init(userData: json)
                onCompletion(true)
            } else {
                onCompletion(false)
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