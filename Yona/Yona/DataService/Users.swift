//
//  userObject.swift
//  Yona
//
//  Created by Ben Smith on 31/03/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

struct Users{
    var avatarImg: UIImage?
    var userID: String!
    var firstName: String!
    var lastName: String!
    var mobileNumber: String!
    var nickname: String!
    
    var buddies : [Buddies] = []
    var userGoals : [Goal] = []
    var devices : [Device] = []
    //links
    var editLink: String?
    var confirmMobileNumberLink: String?
    var resendConfirmationCodeMobileLink: String?
    var getSelfLink: String?
    var messagesLink: String?
    var dailyActivityReportsLink: String?
    var weeklyActivityReportsLink: String?
    var newDeviceRequestsLink: String?
    var activityCategoryLink: String?
    var requestPinResetLink: String?
    var requestPinVerifyLink: String?
    var requestPinClearLink: String?
    var resendRequestPinResetLinks: String?
    var buddiesLink: String?
    var getAllGoalsLink: String?
    var timeLineLink : String?
    var foundIncludeLink: Bool = false
    var formatetMobileNumber : String!
    var editUserAvatar: String?
    var userAvatarLink: String?
    
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
                    let hrefyonaUserSelfLink = (yonaUserSelfLink as? [String : String])?[YonaConstants.jsonKeys.hrefKey] {
                    self.getSelfLink = hrefyonaUserSelfLink
                    KeychainManager.sharedInstance.saveUserSelfLink(hrefyonaUserSelfLink)
                    foundIncludeLink = true
                }
                
                if let editLink = links[YonaConstants.jsonKeys.editLinkKeys],
                    let hrefEditLink = (editLink as? [String : String])?[YonaConstants.jsonKeys.hrefKey] {
                    self.newDeviceRequestsLink = hrefEditLink
                }
            }
            
            if let firstName = userData[addUserKeys.firstNameKey.rawValue] as? String {// firstName
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
                    let hrefEditLink = (editLink as? [String : String])?[YonaConstants.jsonKeys.hrefKey]{
                    self.editLink = hrefEditLink
                    
                    if let lastPath = URL(string: self.editLink!)?.lastPathComponent {
                        self.userID = lastPath
                        KeychainManager.sharedInstance.saveUserID(self.userID)
                    }
                }
                
                
                if !foundIncludeLink {
                    if let selfLinks = links[YonaConstants.jsonKeys.selfLinkKeys],
                        let hrefSelfLinks = (selfLinks as? [String : String])?[YonaConstants.jsonKeys.hrefKey] {
                        self.getSelfLink = hrefSelfLinks
                        print(self.getSelfLink!)
                        KeychainManager.sharedInstance.saveUserSelfLink(hrefSelfLinks)
                    }
                }
                
                if let confirmLinks = links[YonaConstants.jsonKeys.yonaConfirmMobileLinkKeys],
                    let confirmLinksHref = (confirmLinks as? [String : String])?[YonaConstants.jsonKeys.hrefKey] {
                    self.confirmMobileNumberLink = confirmLinksHref
                }
                if let resendMobileNumberConfirmationCodeLink = links[YonaConstants.jsonKeys.yonaResendMobileNumberConfirmationCodeLinkKey],
                    let hrefResendMobileNumberConfirmationCodeLink = (resendMobileNumberConfirmationCodeLink as? [String : String])?[YonaConstants.jsonKeys.hrefKey] {
                    self.resendConfirmationCodeMobileLink = hrefResendMobileNumberConfirmationCodeLink
                }
                
                if let messageLinks = links[YonaConstants.jsonKeys.yonaMessages],
                    let hrefMessageLinks = (messageLinks as? [String : String])?[YonaConstants.jsonKeys.hrefKey] {
                    self.messagesLink = hrefMessageLinks
                }
                
                if let dailyActivityReportsLinks = links[YonaConstants.jsonKeys.yonaDailyActivityReports],
                    let hrefdailyActivityReportsLinks = (dailyActivityReportsLinks as? [String : String])?[YonaConstants.jsonKeys.hrefKey] {
                    self.dailyActivityReportsLink = hrefdailyActivityReportsLinks
                }
                
                if let weeklyActivityReportsLinks = links[YonaConstants.jsonKeys.yonaWeeklyActivityReports],
                    let hrefWeeklyActivityReportsLinks = (weeklyActivityReportsLinks as? [String : String])?[YonaConstants.jsonKeys.hrefKey] {
                    self.weeklyActivityReportsLink = hrefWeeklyActivityReportsLinks
                }
                
                if let newDeviceRequestsLinks = links[YonaConstants.jsonKeys.yonaNewDeviceRequest],
                    let hrefnewDeviceRequestsLink = (newDeviceRequestsLinks as? [String : String])?[YonaConstants.jsonKeys.hrefKey] {
                    self.newDeviceRequestsLink = hrefnewDeviceRequestsLink
                }// this is for when parsing user body returned from add device
                else if let newDeviceRequestsLinks = userData[YonaConstants.jsonKeys.linksKeys],
                    let newDeviceRequestsLinksSelf = newDeviceRequestsLinks[YonaConstants.jsonKeys.selfLinkKeys],
                    let newDeviceRequestsLinksSelfHref = (newDeviceRequestsLinksSelf as? [String : String])?[YonaConstants.jsonKeys.hrefKey] {
                    self.newDeviceRequestsLink = newDeviceRequestsLinksSelfHref
                }
                
                if let requestPinResetLinks = links[YonaConstants.jsonKeys.yonaPinRequest],
                    let hrefrequestPinResetLinks = (requestPinResetLinks as? [String : String])?[YonaConstants.jsonKeys.hrefKey] {
                    self.requestPinResetLink = hrefrequestPinResetLinks
                }
                
                if let resendRequestPinResetLinks = links[YonaConstants.jsonKeys.yonaResendPinResetRequest],
                    let hrefresendRequestPinResetLinks = (resendRequestPinResetLinks as? [String : String])?[YonaConstants.jsonKeys.hrefKey] {
                    self.resendRequestPinResetLinks = hrefresendRequestPinResetLinks
                }
                
                if let requestPinVerifyLinks = links[YonaConstants.jsonKeys.yonaPinVerify],
                    let hrefrequestPinVerifyLinks = (requestPinVerifyLinks as? [String : String])?[YonaConstants.jsonKeys.hrefKey]  {
                    self.requestPinVerifyLink = hrefrequestPinVerifyLinks
                }
                
                if let requestPinClearLinks = links[YonaConstants.jsonKeys.yonaPinClear],
                    let hrefrequestPinClearLinks = (requestPinClearLinks as? [String : String])?[YonaConstants.jsonKeys.hrefKey] {
                    self.requestPinClearLink = hrefrequestPinClearLinks
                }
                if let requestPinClearLinks = links[YonaConstants.jsonKeys.yonaDailyActivityReportsWithBuddies],
                    let timeline  = (requestPinClearLinks as? [String : String])?[YonaConstants.jsonKeys.hrefKey] {
                    timeLineLink = timeline
                }

                if let yonaEditPhotoLink = links[YonaConstants.jsonKeys.yonaEditUserPhoto],
                    let href  = (yonaEditPhotoLink as? [String : String])?[YonaConstants.jsonKeys.hrefKey] {
                    editUserAvatar = href
                }
                if let yonaPhotoLink = links[YonaConstants.jsonKeys.yonaUserPhoto],
                    let href = (yonaPhotoLink as? [String : String])?[YonaConstants.jsonKeys.hrefKey] {
                    userAvatarLink = href
                }

            }
            
            if let embedded = userData[YonaConstants.jsonKeys.embedded],
                let yonaGoals = embedded[YonaConstants.jsonKeys.yonaGoals],
                let goalsLink = (yonaGoals as? [String : Any])?[YonaConstants.jsonKeys.linksKeys],
                let selfGoalsLink = (goalsLink as? [String : Any])?[YonaConstants.jsonKeys.selfLinkKeys],
                let hrefSelfGoalsLink = (selfGoalsLink as? [String : Any])?[YonaConstants.jsonKeys.hrefKey]{
                self.getAllGoalsLink = hrefSelfGoalsLink as? String
            }
            
            if let embedded = userData[YonaConstants.jsonKeys.embedded],
                let yonaDevice = embedded[YonaConstants.jsonKeys.yonaDevice],
                let embeddedNext = (yonaDevice as? [String : Any])?[YonaConstants.jsonKeys.embedded] {
                if let DevicesJSON  = (embeddedNext as? [String : Any])?[YonaConstants.jsonKeys.yonaDevice] as? [BodyDataDictionary] {
                    for each in DevicesJSON {
                        let aDevice = Device(deviceData: each)
                        devices.append(aDevice)
                    }
                }
            }
            
            //for now this is the only way to get the activity category link
            self.activityCategoryLink = YonaConstants.commands.activityCategories
            
            if let embedded = userData[YonaConstants.jsonKeys.embedded],
                let yonaBuddies = embedded[YonaConstants.jsonKeys.yonaBuddies]{
                //at some point Bert will probably add Buddies so we need to parse them here too!
                
                //get buddies links
                if let buddiesLinks = (yonaBuddies as? [String : Any])?[YonaConstants.jsonKeys.linksKeys],
                    let buddiesLinksSelf = (buddiesLinks as? [String : Any])?[YonaConstants.jsonKeys.selfLinkKeys],
                    let buddiesLinksSelfHref = (buddiesLinksSelf as? [String : Any])?[YonaConstants.jsonKeys.hrefKey]{
                    self.buddiesLink = buddiesLinksSelfHref as? String
                }
            }
            
            
            if let embedded = userData[YonaConstants.jsonKeys.embedded],
                let yonabuddies = embedded[YonaConstants.jsonKeys.yonaGoals],
                let embeddedNext = (yonabuddies as? [String : Any])?[YonaConstants.jsonKeys.embedded] {
                if let goalJSON  = (embeddedNext as? [String : Any])?[YonaConstants.jsonKeys.yonaGoals] as? [BodyDataDictionary] {
                    for each in goalJSON {
                        let aGoal = Goal(goalData : each, activities: [])
                        userGoals.append(aGoal)
                    }
                }
            }
            // UGLY HACK TO FIX   APPDEV-852
            // Code should be changed to NOT use the NSUserDefaults for this...
            //
            UserDefaults.standard.set(userGoals.count > 0, forKey: YonaConstants.nsUserDefaultsKeys.isGoalsAdded)
            
            
            if let embedded = userData[YonaConstants.jsonKeys.embedded],
                let yonabuddies = embedded[YonaConstants.jsonKeys.yonaBuddies],
                let embeddedNext = (yonabuddies as? [String : Any])?[YonaConstants.jsonKeys.embedded] {
                if let buddiesJSON  = (embeddedNext as? [String : Any])?[YonaConstants.jsonKeys.yonaBuddies] as? [BodyDataDictionary] {
                            for each in buddiesJSON {
                                let aBuddie = Buddies(buddyData: each, allActivity: [])
                                buddies.append(aBuddie)
                            }
                        }
            }
        }
        
    }
    
    fileprivate func formatMobileNumber() -> String {
        let num = mobileNumber.replacingOccurrences(of: "+31", with: "+310")
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
        return body as BodyDataDictionary
    }
}
