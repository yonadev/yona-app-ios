//
//  userObject.swift
//  Yona
//
//  Created by Ben Smith on 31/03/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

struct Users{
    var userID: String?
    var firstName: String
    var lastName: String
    var mobileNumber: String
    var nickname: String?
    var editLink: String?
    
    init(userData: UserData) {
        firstName = userData["firstName"] as! String
        lastName = userData["lastName"] as! String
        mobileNumber = userData["mobileNumber"] as! String
        nickname = userData["nickname"] as? String
       
        if let links = userData["_links"],
            let edit = links["edit"],
            let href = edit?["href"],
            let editLink = href as? String {
            self.editLink = editLink
            
            if let lastPath = NSURL(string: editLink)?.lastPathComponent {
                userID = lastPath
            }
        }
    }
}