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
    var firstName: String!
    var lastName: String!
    var mobileNumber: String!
    var nickname: String!
    
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
    var resendRequestPinResetLinks: String?
    var buddiesLink: String?
    var getAllGoalsLink: String?

    var formatetMobileNumber : String!
    init(userData: BodyDataDictionary) {
        
        userID = "NOID"
        firstName = ""
        lastName = ""
        mobileNumber = ""
        nickname = ""
        formatetMobileNumber = mobileNumber
        //used to set password on add new device, yonapassword indicates get new device request response
        if let yonapassword = userData[YonaConstants.jsonKeys.yonaPassword] as? String {
            KeychainManager.sharedInstance.setPassword(yonapassword)
            //get the links
            if let links = userData[YonaConstants.jsonKeys.linksKeys] {
                
                // this is for when parsing user body returned from add device, to get the self link to the user
                if let yonaUserSelfLink = links[YonaConstants.jsonKeys.yonaUserSelfLink],
                    let hrefyonaUserSelfLink = yonaUserSelfLink?[YonaConstants.jsonKeys.hrefKey] as? String {
                    self.getSelfLink = hrefyonaUserSelfLink
                    KeychainManager.sharedInstance.saveUserSelfLink(hrefyonaUserSelfLink)
                }
                
                if let editLink = links[YonaConstants.jsonKeys.editLinkKeys],
                    let hrefEditLink = editLink?[YonaConstants.jsonKeys.hrefKey] as? String{
                    self.newDeviceRequestsLink = hrefEditLink
                }
            }
        } else {
            
            if let firstName = userData[addUserKeys.firstNameKey.rawValue] as? String {
                self.firstName = firstName
            }
            if let lastName = userData[addUserKeys.lastNameKeys.rawValue] as? String {
                self.lastName = lastName
            }
            if let mobileNumber = userData[addUserKeys.mobileNumberKeys.rawValue] as? String {
                self.mobileNumber = mobileNumber
                self.formatetMobileNumber = formatMobileNumber()
            }
            if let nickname = userData[addUserKeys.nicknameKeys.rawValue] as? String {
                self.nickname = nickname
            }
            

            //get the links
            if let links = userData[YonaConstants.jsonKeys.linksKeys] {
                
                if let editLink = links[YonaConstants.jsonKeys.editLinkKeys],
                    let hrefEditLink = editLink?[YonaConstants.jsonKeys.hrefKey] as? String{
                    self.editLink = hrefEditLink
                    
                    if let lastPath = NSURL(string: self.editLink!)!.lastPathComponent {
                        self.userID = lastPath
                        KeychainManager.sharedInstance.saveUserID(self.userID)
                    }
                }
                
                if let selfLinks = links[YonaConstants.jsonKeys.selfLinkKeys],
                    let hrefSelfLinks = selfLinks?[YonaConstants.jsonKeys.hrefKey] as? String {
                    self.getSelfLink = hrefSelfLinks
                    KeychainManager.sharedInstance.saveUserSelfLink(hrefSelfLinks)
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
                
                if let resendRequestPinResetLinks = links[YonaConstants.jsonKeys.yonaResendPinResetRequest],
                    let hrefresendRequestPinResetLinks = resendRequestPinResetLinks?[YonaConstants.jsonKeys.hrefKey] as? String {
                    self.resendRequestPinResetLinks = hrefresendRequestPinResetLinks
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
            self.activityCategoryLink = YonaConstants.commands.activityCategories
            
            if let embedded = userData[YonaConstants.jsonKeys.embedded],
                let yonaBuddies = embedded[YonaConstants.jsonKeys.yonaBuddies]{
                //at some point Bert will probably add Buddies so we need to parse them here too!
                
                //get buddies links
                if let buddiesLinks = yonaBuddies?[YonaConstants.jsonKeys.linksKeys],
                    let buddiesLinksSelf = buddiesLinks?[YonaConstants.jsonKeys.selfLinkKeys],
                    let buddiesLinksSelfHref = buddiesLinksSelf?[YonaConstants.jsonKeys.hrefKey] as? String{
                        self.buddiesLink = buddiesLinksSelfHref
                }
            }
        }
        /*
        - parameter body: BodyDataDictionary, pass in the body as below on how you want to update the user
        {
            "firstName": "Richard",
            "lastName": "Quin",
            "mobileNumber": "+31612345678",
            "nickname": "RQ"
        }
        */
        
    }
    
    private func formatMobileNumber() -> String {
        
//        let number1 = mobileNumber[mobileNumber.startIndex...mobileNumber.startIndex.advancedBy(2)]
//        let number2 = mobileNumber[mobileNumber.startIndex.advancedBy(3)..<mobileNumber.startIndex.advancedBy(6)]
//        let number3 = mobileNumber[mobileNumber.startIndex.advancedBy(6)..<mobileNumber.startIndex.advancedBy(9)]
//        let number4 = mobileNumber[mobileNumber.startIndex.advancedBy(9)..<mobileNumber.endIndex]
//        
//        let formatNum = number1+" "+number2+" "+number3+" "+number4
//        let num = formatNum.stringByReplacingOccurrencesOfString("+31", withString: "+310")
        let num = mobileNumber.stringByReplacingOccurrencesOfString("+31", withString: "+310")
        return num
    }
    
    func userDataDictionaryForServer() -> BodyDataDictionary {
        var body = ["firstName": "",
                    "lastName": "",
                    "mobileNumber": "",
                    "nickname": ""]
        
            body["firstName"] = firstName
            body["lastName"] = lastName
            body["mobileNumber"] = mobileNumber
            body["nickname"] = nickname
        return body
    }

}