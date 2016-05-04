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
    
    //links
    var editLink: String?
    var confirmMobileLink: String?
    var otpResendMobileLink: String?
    var getSelfLink: String?
    var messagesLink: String?
    var dailyActivityReportsLink: String?
    var weeklyActivityReportsLink: String?
    var newDeviceRequestsLink: String?
    var appActivityLink: String?
    var activityCategoryLink: String?
    var requestPinResetLink: String?
    var requestPinVerifyLink: String?
    var requestPinClearLink: String?
    var buddiesLink: String?
    var getAllGoalsLink: String?

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
        

        //get the links
        if let links = userData[YonaConstants.jsonKeys.linksKeys] {
            
            if let editLink = links[YonaConstants.jsonKeys.editLinkKeys],
                let hrefEditLink = editLink?[YonaConstants.jsonKeys.hrefKey] as? String{
                self.editLink = hrefEditLink
                
                if let lastPath = NSURL(string: self.editLink!)!.lastPathComponent {
                    self.userID = lastPath
                    KeychainManager.sharedInstance.saveUserID(self.userID!)
                }
            }
            
            if let selfLinks = links[YonaConstants.jsonKeys.selfLinkKeys],
                let hrefSelfLinks = selfLinks?[YonaConstants.jsonKeys.hrefKey] as? String {
                self.getSelfLink = hrefSelfLinks
                KeychainManager.sharedInstance.saveUserSelfLink(hrefSelfLinks) //save this so we can always get the user
            }
            
            // this is for when parsing user body returned from add device, to get the self link to the user
            if let yonaUserSelfLink = links[YonaConstants.jsonKeys.yonaUserSelfLink],
                let hrefyonaUserSelfLink = yonaUserSelfLink?[YonaConstants.jsonKeys.hrefKey] as? String {
                self.getSelfLink = hrefyonaUserSelfLink
                KeychainManager.sharedInstance.saveUserSelfLink(hrefyonaUserSelfLink) //save this so we can always get the user
            }
            
            if let confirmLinks = links[YonaConstants.jsonKeys.yonaConfirmMobileLinkKeys],
                let confirmLinksHref = confirmLinks?[YonaConstants.jsonKeys.hrefKey] as? String{
                self.confirmMobileLink = confirmLinksHref
            }
            if let otpResendMobileLink = links[YonaConstants.jsonKeys.yonaOtpResendMobileLinkKey],
                let hrefOTPesendMobileLink = otpResendMobileLink?[YonaConstants.jsonKeys.hrefKey] as? String {
                self.otpResendMobileLink = hrefOTPesendMobileLink
            }
            
            if let messageLinks = links[YonaConstants.jsonKeys.yonaMessages],
                let hrefMessageLinks = messageLinks?[YonaConstants.jsonKeys.hrefKey] as? String {
                self.messagesLink = hrefMessageLinks
            }
            
            if let dailyActivityReportsLinks = links[YonaConstants.jsonKeys.yonaDailyActivityReports],
                let hrefdailyActivityReportsLinks = dailyActivityReportsLinks?[YonaConstants.jsonKeys.hrefKey] as? String {
                self.dailyActivityReportsLink = hrefdailyActivityReportsLinks
            }
            
            if let weeklyActivityReportsLinks = links[YonaConstants.jsonKeys.yonaWeeklyActivityReports],
                let hrefWeeklyActivityReportsLinks = weeklyActivityReportsLinks?[YonaConstants.jsonKeys.hrefKey] as? String {
                self.weeklyActivityReportsLink = hrefWeeklyActivityReportsLinks
            }
            
            if let newDeviceRequestsLinks = links[YonaConstants.jsonKeys.yonaNewDeviceRequest],
                let hrefnewDeviceRequestsLink = newDeviceRequestsLinks?[YonaConstants.jsonKeys.hrefKey] as? String {
                self.newDeviceRequestsLink = hrefnewDeviceRequestsLink
            }// this is for when parsing user body returned from add device
            else if let newDeviceRequestsLinks = userData[YonaConstants.jsonKeys.linksKeys],
                let newDeviceRequestsLinksSelf = newDeviceRequestsLinks[YonaConstants.jsonKeys.selfLinkKeys],
                let newDeviceRequestsLinksSelfHref = newDeviceRequestsLinksSelf?[YonaConstants.jsonKeys.hrefKey] as? String{
                self.newDeviceRequestsLink = newDeviceRequestsLinksSelfHref
            }
            
            if let appActivityLinks = links[YonaConstants.jsonKeys.yonaAppActivity],
                let hrefappActivityLinks = appActivityLinks?[YonaConstants.jsonKeys.hrefKey] as? String {
                self.appActivityLink = hrefappActivityLinks
            }
            
            if let requestPinResetLinks = links[YonaConstants.jsonKeys.yonaPinRequest],
                let hrefrequestPinResetLinks = requestPinResetLinks?[YonaConstants.jsonKeys.hrefKey] as? String {
                self.requestPinResetLink = hrefrequestPinResetLinks
            }
            
            if let requestPinVerifyLinks = links[YonaConstants.jsonKeys.yonaPinVerify],
                let hrefrequestPinVerifyLinks = requestPinVerifyLinks?[YonaConstants.jsonKeys.hrefKey] as? String {
                self.requestPinVerifyLink = hrefrequestPinVerifyLinks
            }
            
            if let requestPinClearLinks = links[YonaConstants.jsonKeys.yonaPinClear],
                let hrefrequestPinClearLinks = requestPinClearLinks?[YonaConstants.jsonKeys.hrefKey] as? String {
                self.requestPinClearLink = hrefrequestPinClearLinks
            }
        }
        
        if let embedded = userData[YonaConstants.jsonKeys.embedded],
            let yonaGoals = embedded[YonaConstants.jsonKeys.yonaGoals],
            let goalsLink = yonaGoals?[YonaConstants.jsonKeys.linksKeys],
            let selfGoalsLink = goalsLink?[YonaConstants.jsonKeys.selfLinkKeys],
            let hrefSelfGoalsLink = selfGoalsLink?[YonaConstants.jsonKeys.hrefKey] as? String{
                self.getAllGoalsLink = hrefSelfGoalsLink
        }
        
        //for now this is the only way to get the activity category link
        self.activityCategoryLink = YonaConstants.environments.testUrl + YonaConstants.commands.activityCategories
        
        if let embedded = userData[YonaConstants.jsonKeys.embedded],
            let yonaBuddies = embedded[YonaConstants.jsonKeys.yonaBuddies]{
            //at some point Bert will probably add Buddies so we need to parse them here too!
            
            //get buddies links
            if let buddiesLinks = yonaBuddies?[YonaConstants.jsonKeys.linksKeys],
                buddiesLinksHref = buddiesLinks?[YonaConstants.jsonKeys.hrefKey] as? String{
                    self.buddiesLink = buddiesLinksHref
            }
        }
        
        
    }
}