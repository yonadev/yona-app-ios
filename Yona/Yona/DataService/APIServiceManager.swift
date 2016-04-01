//
//  APIServiceManager.swift
//  Yona
//
//  Created by Ben Smith on 31/03/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

struct YonaPath {
    struct environments {
        static let test = "http://85.222.227.142/"
        static let production = ""
    }
    
    struct commands {
        static let users = "users/"
    }
}

public typealias UserData = [String: AnyObject]

class APIServiceManager {
    static let sharedInstance = APIServiceManager()
    
    private init() {}
    
    var newUser: Users?
    lazy var yonaPassword: String = {
        return NSUUID().UUIDString
    }()
    
    func postUser(body: UserData, onCompletion: APIResponse) {
        let path = YonaPath.environments.test + YonaPath.commands.users
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
            UserManager.sharedInstance.makeDeleteRequest(editLink, password: yonaPassword, userID: userID, onCompletion: { success in
                if (success){
                    onCompletion(true)
                } else {
                    onCompletion(false)
                }
            })
        }
    }
    
}