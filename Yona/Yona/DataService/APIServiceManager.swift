//
//  APIServiceManager.swift
//  Yona
//
//  Created by Ben Smith on 31/03/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

struct Environments {
    static let test = "http://85.222.227.142/"
    static let production = ""
}

public typealias UserData = [String: AnyObject]

class APIServiceManager {
    static let sharedInstance = APIServiceManager()
    
    private init() {}
    
    var newUser: Users?
    
    func postUser(body: [String: AnyObject], password: String, onCompletion: APIResponse) {
        let path = Environments.test + "users/"
        UserManager.sharedInstance.makePostRequest(path, password: password, body: body, onCompletion: { json, err in
            if let json = json {
                //store the json in an object
                self.newUser = Users.init(userData: json)
                onCompletion(true)
            } else {
                onCompletion(false)
            }
        })
    }
    
    func deleteUser(password: String, onCompletion: APIResponse) {
        if let newUser = newUser,
            let editLink = newUser.editLink,
            let userID = newUser.userID {
            UserManager.sharedInstance.makeDeleteRequest(editLink, password: password, userID: userID, onCompletion: { success in
                if (success){
                    onCompletion(true)
                } else {
                    onCompletion(false)
                }
            })
        }
    }
    
}