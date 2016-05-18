//
//  Messaging.swift
//  Yona
//
//  Created by Ben Smith on 11/05/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation
struct Message{
    var selfLink: String?
    var rejectLink: String?
    var acceptLink: String?
    var creationTime: String?
    var nickname: String?
    var message: String?
    var status: buddyRequestStatus?
    var messageType: String?

    //details of user who made request
    var UserRequestfirstName: String?
    var UserRequestlastName: String?
    var UserRequestmobileNumber: String?
    var UserRequestSelfLink: String?
    
    init(messageData: BodyDataDictionary) {
        if let messageType = messageData[getMessagesKeys.messageType.rawValue] as? String{
            self.messageType = messageType
        }
        if let creationTime = messageData[getMessagesKeys.creationTime.rawValue] as? String{
            self.creationTime = creationTime
        }
        if let nickname = messageData[getMessagesKeys.nickname.rawValue] as? String{
            self.nickname = nickname
        }
        if let message = messageData[getMessagesKeys.message.rawValue] as? String{
            self.message = message
        }
        if let status = messageData[getMessagesKeys.status.rawValue] as? String{
            switch status {
            case buddyRequestStatus.ACCEPTED.rawValue:
                self.status = buddyRequestStatus.ACCEPTED
            case buddyRequestStatus.NOT_REQUESTED.rawValue:
                self.status = buddyRequestStatus.NOT_REQUESTED
            case buddyRequestStatus.REJECTED.rawValue:
                self.status = buddyRequestStatus.REJECTED
            case buddyRequestStatus.REQUESTED.rawValue:
                self.status = buddyRequestStatus.REQUESTED
            default: //won't reach this unless they change the name of the statuses
                self.status = buddyRequestStatus.REQUESTED
            }
        }
        
        //get the links
        if let links = messageData[getMessagesKeys.links.rawValue] as? BodyDataDictionary{
            if let linksSelf = links[getMessagesKeys.selfKey.rawValue],
                let linksSelfHref = linksSelf[getMessagesKeys.href.rawValue] as? String{
                self.selfLink = linksSelfHref
            }
            
            if let rejectLink = links[getMessagesKeys.reject.rawValue],
                let rejectLinkHref = rejectLink[getMessagesKeys.href.rawValue] as? String{
                self.rejectLink = rejectLinkHref
            }
            
            if let acceptLink = links[getMessagesKeys.accept.rawValue],
                let acceptLinkHref = acceptLink[getMessagesKeys.href.rawValue] as? String{
                self.acceptLink = acceptLinkHref
            }
        }
        
        //store user who made the request
        if let embedded = messageData[getMessagesKeys.embedded.rawValue],
            let userDetails = embedded[getMessagesKeys.yonaUser.rawValue] as? BodyDataDictionary{
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