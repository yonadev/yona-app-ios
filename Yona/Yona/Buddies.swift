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
    var sendingStatus: buddyRequestStatus?
    var receivingStatus: buddyRequestStatus?

    //details of user who made request
    var UserRequestfirstName: String?
    var UserRequestlastName: String?
    var UserRequestmobileNumber: String?
    var UserRequestSelfLink: String?
    
    init(buddyData: BodyDataDictionary) {

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
        }
        
        //store user who made the request
        if let embedded = buddyData[postBuddyBodyKeys.embedded.rawValue],
            let userDetails = embedded[postBuddyBodyKeys.yonaUser.rawValue] as? BodyDataDictionary{
            if let lastName = userDetails[getMessagesKeys.UserRequestlastName.rawValue] as? String {
                self.UserRequestlastName = lastName
            }
            if let firstName = userDetails[getMessagesKeys.UserRequestfirstName.rawValue] as? String {
                self.UserRequestfirstName = firstName
            }
            if let mobileNumber = userDetails[getMessagesKeys.UserRequestmobileNumber.rawValue] as? String {
                self.UserRequestmobileNumber = mobileNumber
            }
            
            if let linksRequest = userDetails[getMessagesKeys.links.rawValue] as? BodyDataDictionary,
                let linksRequestSelf = linksRequest[getMessagesKeys.selfKey.rawValue] as? BodyDataDictionary,
                let linksRequestSelfHref = linksRequestSelf[getMessagesKeys.href.rawValue] as? String {
                self.UserRequestSelfLink = linksRequestSelfHref
            }
        }
    }
}