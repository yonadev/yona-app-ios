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
    var firstName: String?
    var lastName: String?
    var mobileNumber: String?
    var nickname: String?
    var editLink: String?
    var confirmMobileLink: String?
    var otpResendMobileLink: String?
    var getSelfLink: String?

    init(userData: BodyDataDictionary) {
        if let firstName = userData[YonaConstants.jsonKeys.firstNameKey] as? String {
            self.firstName = firstName
        }
        if let lastName = userData[YonaConstants.jsonKeys.lastNameKeys] as? String {
            self.lastName = lastName
        }
        if let mobileNumber = userData[YonaConstants.jsonKeys.mobileNumberKeys] as? String {
            self.mobileNumber = mobileNumber
        }
        if let nickname = userData[YonaConstants.jsonKeys.nicknameKeys] as? String {
            self.nickname = nickname
        }
        
        if let links = userData[YonaConstants.jsonKeys.linksKeys],
            let edit = links[YonaConstants.jsonKeys.editLinkKeys],
            let href = edit?[YonaConstants.jsonKeys.hrefKey],
            let selfLinks = links[YonaConstants.jsonKeys.selfLinkKeys],
            let hrefSelfLinks = selfLinks?[YonaConstants.jsonKeys.hrefKey],
            let confirmLinks = links[YonaConstants.jsonKeys.confirmMobileLinkKeys],
            let hrefConfirmLinks =  confirmLinks?[YonaConstants.jsonKeys.hrefKey],
            let otpResendMobileLink = links[YonaConstants.jsonKeys.otpResendMobileLinkKey],
            let editLink = href as? String {
                    self.editLink = editLink
                    if let lastPath = NSURL(string: editLink)?.lastPathComponent {
                        self.userID = lastPath
                        KeychainManager.sharedInstance.saveUserID(self.userID!)
                    }
                if let confirmMobileLink = hrefConfirmLinks as? String{
                    self.confirmMobileLink = confirmMobileLink
                    KeychainManager.sharedInstance.saveConfirmMobileLink(confirmMobileLink)

                }
            if let otpResendMobileLink = otpResendMobileLink as? String {
                self.otpResendMobileLink = otpResendMobileLink
                KeychainManager.sharedInstance.saveOtpResendMobileLink(otpResendMobileLink)

            }
            self.getSelfLink = hrefSelfLinks as? String
                
        }
    }
}