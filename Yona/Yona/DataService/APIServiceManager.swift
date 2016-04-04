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
        let path = YonaConstants.environments.test + YonaConstants.commands.users
        
        guard let yonaPassword = KeychainManager.sharedInstance.getYonaPassword() else {
            onCompletion(false)
            return
        }
        
        UserManager.sharedInstance.makePostRequest(path, password: yonaPassword, body: body, onCompletion: { json, err in
            if let json = json {
                //store the json in an object
                self.newUser = Users.init(userData: json)
                onCompletion(true)
            } else {
                onCompletion(false)
            }
        })
    }
    
    func deleteUser(onCompletion: APIResponse) {
        if let newUser = newUser,
            let editLink = newUser.editLink,
            let userID = newUser.userID {
            guard let yonaPassword = KeychainManager.sharedInstance.getYonaPassword() else {
                onCompletion(false)
                return
            }
            
            UserManager.sharedInstance.makeRequest(editLink, password: yonaPassword, userID: userID, body: [:], httpMethod: YonaConstants.httpMethods.delete, onCompletion: { success in
                if (success){
                    onCompletion(true)
                } else {
                    onCompletion(false)
                }
            })
        } else { onCompletion(false) }
    }
    
    func confirmMobileNumber(body: UserData, onCompletion: APIResponse) {
        if let newUser = newUser,
            let userID = newUser.userID {
            guard let yonaPassword = KeychainManager.sharedInstance.getYonaPassword() else {
                onCompletion(false)
                return
            }
            
            let path = YonaConstants.environments.test + YonaConstants.commands.users + userID + YonaConstants.commands.mobileConfirm //POST /users/{id}/confirmMobileNumber
            UserManager.sharedInstance.makeRequest(path, password: yonaPassword, userID: userID, body: body, httpMethod: YonaConstants.httpMethods.post, onCompletion: { success in
                if (success){
                    onCompletion(true)
                } else {
                    onCompletion(false)
                }
            })
        } else { onCompletion(false) }
    }
}