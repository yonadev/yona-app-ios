//
//  Buddy.swift
//  Yona
//
//  Created by Ben Smith on 11/05/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation
struct Buddies{
    var selfLink: String?
    var editLink: String?
    var dailyActivityReports : String?
    var weeklyActivityReports : String?
    var sendingStatus: buddyRequestStatus?
    var receivingStatus: buddyRequestStatus?
    var lastMonitoredActivityDate: String?
    var buddyGoalSelfLink: String?

    //details of user who made request
    var UserRequestfirstName: String
    var UserRequestlastName: String
    var UserRequestmobileNumber: String
    var UserRequestSelfLink: String
    var formattetMobileNumber : String
    var buddyNickName : String
    var buddyAvatarURL: String?
    
    var buddyGoals : [Goal] = []
    init(buddyData: BodyDataDictionary, allActivity: [Activities]) {
        UserRequestfirstName = ""
        UserRequestlastName = ""
        UserRequestmobileNumber = ""
        UserRequestSelfLink = ""
        buddyNickName = ""
        formattetMobileNumber = UserRequestmobileNumber
        lastMonitoredActivityDate = ""
        if let sendingStatusFeed = buddyData[postBuddyBodyKeys.sendingStatus.rawValue] as? String{
            switch sendingStatusFeed {
            case buddyRequestStatus.ACCEPTED.rawValue:
                self.sendingStatus = buddyRequestStatus.ACCEPTED
            case buddyRequestStatus.NOT_REQUESTED.rawValue:
                self.sendingStatus = buddyRequestStatus.NOT_REQUESTED
            case buddyRequestStatus.REJECTED.rawValue:
                self.sendingStatus = buddyRequestStatus.REJECTED
            case buddyRequestStatus.REQUESTED.rawValue:
                self.sendingStatus = buddyRequestStatus.REQUESTED
            default: //won't reach this unless they change the name of the statuses
                self.sendingStatus = buddyRequestStatus.REQUESTED
            }
        }
        
        if let receivingStatusFeed = buddyData[postBuddyBodyKeys.receivingStatus.rawValue] as? String{
            switch receivingStatusFeed {
            case buddyRequestStatus.ACCEPTED.rawValue:
                self.receivingStatus = buddyRequestStatus.ACCEPTED
            case buddyRequestStatus.NOT_REQUESTED.rawValue:
                self.receivingStatus = buddyRequestStatus.NOT_REQUESTED
            case buddyRequestStatus.REJECTED.rawValue:
                self.receivingStatus = buddyRequestStatus.REJECTED
            case buddyRequestStatus.REQUESTED.rawValue:
                self.receivingStatus = buddyRequestStatus.REQUESTED
            default: //won't reach this unless they change the name of the statuses
                self.receivingStatus = buddyRequestStatus.REQUESTED
            }
        }
        
        //get the links
        if let links = buddyData[postBuddyBodyKeys.links.rawValue] as? BodyDataDictionary{
            if let linksSelf = links[postBuddyBodyKeys.selfKey.rawValue],
                let linksSelfHref = linksSelf[postBuddyBodyKeys.href.rawValue] as? String{
                self.selfLink = linksSelfHref
            }
            if let editLink = links[postBuddyBodyKeys.editKey.rawValue],
                let editLinkHref = editLink[postBuddyBodyKeys.href.rawValue] as? String{
                self.editLink = editLinkHref
            }
            if let dayly = links[postBuddyBodyKeys.yonaDailyActivityReports.rawValue],
                let editLinkHref = dayly[postBuddyBodyKeys.href.rawValue] as? String{
                self.dailyActivityReports = editLinkHref
            }
            if let weekly = links[postBuddyBodyKeys.yonaWeeklyActivityReports.rawValue],
                let editLinkHref = weekly[postBuddyBodyKeys.href.rawValue] as? String{
                self.weeklyActivityReports = editLinkHref
            }
        }
        
        if let activityDate = buddyData[getMessagesKeys.lastMonitoredActivityDate.rawValue] as? String {
            lastMonitoredActivityDate = activityDate
        }
        
        //store user who made the request
        if let embedded = buddyData[postBuddyBodyKeys.embedded.rawValue],
            let userDetails = embedded[postBuddyBodyKeys.yonaUser.rawValue] as? BodyDataDictionary{
            if let nickName = userDetails[getMessagesKeys.nickname.rawValue] as? String {
                self.buddyNickName = nickName
            }
            if let lastName = userDetails[getMessagesKeys.UserRequestlastName.rawValue] as? String {
                self.UserRequestlastName = lastName
            }
            if let firstName = userDetails[getMessagesKeys.UserRequestfirstName.rawValue] as? String {
                self.UserRequestfirstName = firstName
            }
            if let mobileNumber = userDetails[getMessagesKeys.UserRequestmobileNumber.rawValue] as? String {
                self.UserRequestmobileNumber = mobileNumber
                formattetMobileNumber = formatMobileNumber()
            }
            if let linksRequest = userDetails[getMessagesKeys.links.rawValue] as? BodyDataDictionary,
                let linksRequestSelf = linksRequest[getMessagesKeys.selfKey.rawValue] as? BodyDataDictionary,
                let linksRequestSelfHref = linksRequestSelf[getMessagesKeys.href.rawValue] as? String {
                self.UserRequestSelfLink = linksRequestSelfHref
            }
            
            if let embeddedMore = userDetails[YonaConstants.jsonKeys.embedded]  as? BodyDataDictionary, let embededGoals = embeddedMore[YonaConstants.jsonKeys.yonaGoals] as? BodyDataDictionary, let embeddedNext = embededGoals[YonaConstants.jsonKeys.embedded]  as? BodyDataDictionary, let buddyGoals = embeddedNext[YonaConstants.jsonKeys.yonaGoals]  as? [BodyDataDictionary] {
                for goal in buddyGoals {
                    let newGoal = Goal.init(goalData: goal, activities: allActivity)
                    if !newGoal.isHistoryItem {
                        self.buddyGoals.append(newGoal)
                    }
                }
            }
            
            if let embeddedNext = userDetails[YonaConstants.jsonKeys.embedded], let yonaGoal = (embeddedNext as? [String : Any])?[YonaConstants.jsonKeys.yonaGoals], let goalLink = (yonaGoal as? [String : Any])?[YonaConstants.jsonKeys.linksKeys], let goalSelfLink = (goalLink as? [String : Any])?[YonaConstants.jsonKeys.selfLinkKeys], let goalSelfLinkHref = (goalSelfLink as? [String : String])?[YonaConstants.jsonKeys.hrefKey] {
                self.buddyGoalSelfLink = goalSelfLinkHref
            }
            
            if let links = userDetails[getMessagesKeys.links.rawValue] as? BodyDataDictionary, let buddyPhotoURL = links[getMessagesKeys.userPhoto.rawValue] as? BodyDataDictionary, let buddyPhotoURLHref = buddyPhotoURL[getMessagesKeys.href.rawValue] as? String {
                self.buddyAvatarURL = buddyPhotoURLHref
            }
        }
    }
    
    fileprivate func formatMobileNumber() -> String {
        let num = UserRequestmobileNumber.replacingOccurrences(of: "+31", with: "+310")
        return num
    }
}
