//
//  userObject.swift
//  Yona
//
//  Created by Ben Smith on 31/03/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

struct Users{
    var firstName: String
    var lastName: String
    var mobileNumber: Int
    var nickname: String
    
    init(Dictionary: json) {
        self.firstName = firstName
        self.lastName = lastName
        self.mobileNumber = mobileNumber
        self.nickname = nickname
    }
}