//
//  Messaging.swift
//  Yona
//
//  Created by Ben Smith on 11/05/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

//TODO: this has not implemeneted ALL notificationstypes
// http://wiki.yona.nu/display/DEV/Me+-+Notifications
enum notificationType : String {
    case BuddyConnectRequestMessage = "BuddyConnectRequestMessage"
    case BuddyConnectResponseMessage = "BuddyConnectResponseMessage"
    case BuddyDisconnectMessage = "BuddyDisconnectMessage"
    case GoalConflictMessage = "GoalConflictMessage"
    case ActivityCommentMessage = "ActivityCommentMessage"
    case GoalChangeMessage = "GoalChangeMessage"
    case DisclosureRequestMessage = "DisclosureRequestMessage"
    case DisclosureResponseMessage = "DisclosureResponseMessage"
    case SystemMessage = "SystemMessage"
    case BuddyInfoChangeMessage = "BuddyInfoChangeMessage"
    case NoValue = "Not found"
    
}

struct Message{
    var dayDetailsLink: String?
    var weekDetailsLink: String?
    var selfLink: String?
    var editLink: String?
    var rejectLink: String?
    var acceptLink: String?
    var yonaProcessLink: String?
    var markReadLink : String?
    var activityCategoryLink : String?
    var relatedCategoryLink : String?
    //var creationTime: String?
    var nickname: String
    var message: String
    var status: buddyRequestStatus?
    var category: String!
    var messageType: notificationType
    var creationTime : NSDate
    var change : String?
    var activityTypeName : String = "noname"
    var isRead : Bool = true
    
    var violationStartTime : NSDate?
    var violationEndTime : NSDate?
    var violationLinkURL : String?

    
    //details of user who made request
    var UserRequestfirstName: String
    var UserRequestlastName: String
    var UserRequestmobileNumber: String
    var UserRequestSelfLink: String

    init(messageData: BodyDataDictionary ) {
        print (messageData)
        
        message = ""
        UserRequestfirstName = ""
        UserRequestlastName = ""
        UserRequestmobileNumber = ""
        UserRequestSelfLink = ""
        nickname = ""
        messageType = .NoValue
        
        creationTime = NSDate.init()
        if let data = messageData[getMessagesKeys.messageType.rawValue] as? String{
            if let type  = notificationType(rawValue:data) {
                messageType = type
            }
        }
        if let aCreationTime = messageData[getMessagesKeys.creationTime.rawValue] as? String{
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = getMessagesKeys.dateFormat.rawValue
            if let aDate = dateFormatter.dateFromString(aCreationTime) {
                creationTime = aDate
            }
        }
        if let nickname = messageData[getMessagesKeys.nickname.rawValue] as? String{
            self.nickname = nickname
        }
        if let aChange = messageData[getMessagesKeys.change.rawValue] as? String{
            self.change = aChange
        }

        if let aBool = messageData[getMessagesKeys.isRead.rawValue] as? Bool{
            isRead = aBool
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
        
        // VILOATION
        
        
        if let violation = messageData[YonaConstants.jsonKeys.violationURL] as? String{
            violationLinkURL = violation
        }
        if let violation = messageData[YonaConstants.jsonKeys.violationStart] as? String{
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = getMessagesKeys.dateFormat.rawValue
            if let aDate = dateFormatter.dateFromString(violation) {
                violationStartTime = aDate
            }
        }
        if let violation = messageData[YonaConstants.jsonKeys.violationEnd] as? String{
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = getMessagesKeys.dateFormat.rawValue
            if let aDate = dateFormatter.dateFromString(violation) {
                violationEndTime = aDate
            }
             
        }
        
        

        
        //get the links
        if let links = messageData[getMessagesKeys.links.rawValue] as? BodyDataDictionary{
            if let linksSelf = links[getMessagesKeys.selfKey.rawValue],
                let linksSelfHref = linksSelf[getMessagesKeys.href.rawValue] as? String{
                self.selfLink = linksSelfHref
            }
            
            if let linksEdit = links[getMessagesKeys.edit.rawValue],
                let linksEditHref = linksEdit[getMessagesKeys.href.rawValue] as? String{
                self.editLink = linksEditHref
            }
            
            if let rejectLink = links[getMessagesKeys.reject.rawValue],
                let rejectLinkHref = rejectLink[getMessagesKeys.href.rawValue] as? String{
                self.rejectLink = rejectLinkHref
            }
            
            if let acceptLink = links[getMessagesKeys.accept.rawValue],
                let acceptLinkHref = acceptLink[getMessagesKeys.href.rawValue] as? String{
                self.acceptLink = acceptLinkHref
            }
            
            if let processLink = links[getMessagesKeys.process.rawValue],
                let processLinkHref = processLink[getMessagesKeys.href.rawValue] as? String{
                self.yonaProcessLink = processLinkHref
            }
            
            if let dayDetailsLink = links[YonaConstants.jsonKeys.yonaDayDetails],
                let href = dayDetailsLink[getMessagesKeys.href.rawValue] as? String{
                self.dayDetailsLink = href
            }
            
            if let dayDetailsLink = links[YonaConstants.jsonKeys.yonaDayDetailsReport],
                let href = dayDetailsLink[getMessagesKeys.href.rawValue] as? String{
                self.dayDetailsLink = href
            }
            
            
            if let weekDetailsLink = links[YonaConstants.jsonKeys.yonaWeekDetails],
                let href = weekDetailsLink[getMessagesKeys.href.rawValue] as? String{
                self.weekDetailsLink = href
            }

            if let markAsRead = links[getMessagesKeys.markRead.rawValue],
                let href = markAsRead[getMessagesKeys.href.rawValue] as? String{
                self.markReadLink = href
            }

            if let activityCategory = links[getMessagesKeys.activityCategory.rawValue],
                let href = activityCategory[getMessagesKeys.href.rawValue] as? String{
                self.activityCategoryLink = href
            }
            
            if let related = links[getMessagesKeys.relatedCategory.rawValue],
                let href = related[getMessagesKeys.href.rawValue] as? String{
                self.relatedCategoryLink = href
            }

        }
        if (relatedCategoryLink != nil) {
            self.category = ActivitiesRequestManager.sharedInstance.getActivityName(fromLink: relatedCategoryLink!)
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
    
    func messageDataDictionaryForServer() -> BodyDataDictionary {
        var body = ["firstName": "",
                    "lastName": "",
                    "mobileNumber": "",
                    "nickname": ""]
        
        body["firstName"] = UserRequestfirstName
        body["lastName"] = UserRequestlastName
        body["mobileNumber"] = UserRequestmobileNumber
        body["nickname"] = nickname
        return body
    }

    
    
    // MARK: - Icon and message methods
    
    func simpleDescription() -> String {
        switch messageType {
        case .BuddyConnectRequestMessage:
            return NSLocalizedString("message.type.friendrequest", comment: "")
        case .BuddyConnectResponseMessage:
            if status == buddyRequestStatus.ACCEPTED {
                return NSLocalizedString("message.type.friendresponse.accepted", comment: "")
            } else if status == buddyRequestStatus.REJECTED {
                return NSLocalizedString("message.type.friendresponse.rejected", comment: "")
            }
            
        case .BuddyDisconnectMessage:
            return NSLocalizedString("message.type.friendremoved", comment: "")
        case .GoalConflictMessage:
            return NSLocalizedString("message.type.nogoalert", comment: "")
        case .ActivityCommentMessage:
            return NSLocalizedString("message.type.message", comment: "")
        case .GoalChangeMessage:
            if change == "GOAL_ADDED" {
                return NSLocalizedString("message.type.goalchange.add", comment: "").stringByReplacingOccurrencesOfString("%@", withString: self.category)
            } else if change == "GOAL_DELETED" {
                return NSLocalizedString("message.type.goaldeleted", comment: "").stringByReplacingOccurrencesOfString("%@", withString: self.category)
            } else {
                return NSLocalizedString("message.type.goalchange", comment: "").stringByReplacingOccurrencesOfString("%@", withString: self.category)
            }
        case .BuddyInfoChangeMessage:
            return NSLocalizedString("message.type.buddyInfoChangeMessage", comment: "")
        case .SystemMessage:
            return NSLocalizedString("message.type.systemMessage", comment: "")
        default :
            return NSLocalizedString("Error", comment: "")
        }
        return NSLocalizedString("Error", comment: "")
    }
    
    func checkIfMessageTypeSupported() -> Bool {
        var isSupported = false
        switch messageType {
        case .BuddyConnectRequestMessage:
            isSupported = true
        case .BuddyConnectResponseMessage:
            isSupported = true
        case .BuddyDisconnectMessage:
            isSupported = true
        case .GoalConflictMessage:
            isSupported = true
        case .ActivityCommentMessage:
            isSupported = true
        case .GoalChangeMessage:
            isSupported = true
        case .BuddyInfoChangeMessage:
            isSupported = true
        case .SystemMessage:
            isSupported = true
        default :
            isSupported = false
        }
        return isSupported
    }
    
    func iconForStatus() -> UIImage {
        switch messageType {
        //TODO: these images must be set to the correct images for the state
        case .BuddyConnectRequestMessage:
            if status == buddyRequestStatus.ACCEPTED {
                return UIImage(named: "icnOk")!
            } else if status == buddyRequestStatus.REJECTED {
                return UIImage(named: "icnNo")!
            }
        case .BuddyConnectResponseMessage:
            if status == buddyRequestStatus.ACCEPTED {
                return UIImage(named: "icnOk")!
            } else if status == buddyRequestStatus.REJECTED {
                return UIImage(named: "icnNo")!
            }
        case .BuddyDisconnectMessage:
            return UIImage.init()
        case .GoalConflictMessage:
            return UIImage.init()
        case .ActivityCommentMessage:
            return UIImage.init()
        default :
            return UIImage.init()
        }
        return UIImage.init()
    }

    
}
