//
//  userObject.swift
//  Yona
//
//  Created by Ben Smith on 31/03/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

struct Users{
    var userID: String!
    var firstName: String
    var lastName: String
    var mobileNumber: String
    var nickname: String?
    var editLink: String?
    var confirmMobileLink: String?
    var getSelfLink: String?

    init(userData: UserData) {
        firstName = userData[YonaConstants.jsonKeys.firstNameKey] as! String
        lastName = userData[YonaConstants.jsonKeys.lastNameKeys] as! String
        mobileNumber = userData[YonaConstants.jsonKeys.mobileNumberKeys] as! String
        nickname = userData[YonaConstants.jsonKeys.nicknameKeys] as? String
        
        if let links = userData[YonaConstants.jsonKeys.linksKeys],
            let edit = links[YonaConstants.jsonKeys.editLinkKeys],
            let href = edit?[YonaConstants.jsonKeys.hrefKey],
            let selfLinks = links[YonaConstants.jsonKeys.selfLinkKeys],
            let hrefSelfLinks = selfLinks?[YonaConstants.jsonKeys.hrefSelfLinks],
            let confirmLinks = links[YonaConstants.jsonKeys.confirmMobileLinkKeys],
            let hrefConfirmLinks =  confirmLinks?[YonaConstants.jsonKeys.hrefKey],
            let editLink = href as? String {
                self.editLink = editLink
                if let lastPath = NSURL(string: editLink)?.lastPathComponent {
                    userID = lastPath
            }
            self.confirmMobileLink = hrefConfirmLinks as? String
            self.getSelfLink = hrefSelfLinks as? String
            
        }
    }
}