//
//  APIServiceManager.swift
//  Yona
//
//  Created by Ben Smith on 31/03/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

class APIServiceManager {
    
    let baseURL = "http://85.222.227.142/"

    func postUser(body: [String: AnyObject], password: String, onCompletion: APIResponse) {
        let path = baseURL + "users/"
        UserManager.sharedInstance.makePostRequest(path, password: password, body: body, onCompletion: { json, err in
            if let json = json {
                //store the json in an object
                let newUser = Users.init(firstName: json["firstName"],
                    lastName: json["lastName"],
                    mobileNumber: json["mobileNumber"],
                    nickname: json["nickname"])
                onCompletion(true)
            } else {
                onCompletion(false)
            }
        })
    }
    
    func deleteUser(path: String, userID: String, password: String, onCompletion: APIResponse) {
        let path = baseURL + "users/" + userID
        UserManager.sharedInstance.makeDeleteRequest(path, password: password, userID: userID, onCompletion: { success in
            if (success){
                onCompletion(true)
            } else {
                onCompletion(false)
            }
        })
    }
    
}