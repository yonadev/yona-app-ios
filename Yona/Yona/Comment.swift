//
//  Comments.swift
//  Yona
//
//  Created by Ben Smith on 03/08/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

enum commentKeys : String {
    case creationTime = "creationTime"
    case message = "message"
    case threadHeadMessageID = "threadHeadMessageID"
    case nickname = "nickname"
    case links = "_links"
    case _self = "self"
    case href = "href"
    case yona_markRead = "yona:markRead"
    case edit = "edit"
    case yona_user = "yona:user"
    case yona_dayDetails = "yona:dayDetails"
    case yona_threadHead = "yona:threadHead"
    case commentType = "@type"
    case isRead = "isRead"
}

struct Comment{
    var creationTime: NSDate?
    var message: String?
    var threadHeadMessageID: String?
    var nickname: String?
    var commentType: notificationType?
    var isRead: Bool?
    
    //links
    var selfLink: String?
    var markReadLink: String?
    var editLink: String?
    var dayDetailsLink: String?
    var threadHeadLink: String?
    var yonaUser : String?
    
    init(commentData: BodyDataDictionary) {
        
        creationTime = NSDate.init()
        if let data = commentData[commentKeys.commentType.rawValue] as? String{
            if let type  = notificationType(rawValue:data) {
                commentType = type
            }
        }
        if let aCreationTime = commentData[commentKeys.creationTime.rawValue] as? String{
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = getMessagesKeys.dateFormat.rawValue
            if let aDate = dateFormatter.dateFromString(aCreationTime) {
                creationTime = aDate
            }
        }
        if let nickname = commentData[commentKeys.nickname.rawValue] as? String{
            self.nickname = nickname
        }
        if let message = commentData[commentKeys.message.rawValue] as? String{
            self.message = message
        }
        if let isRead = commentData[commentKeys.isRead.rawValue] as? Bool{
            self.isRead = isRead
        }
        if let threadHeadMessageID = commentData[commentKeys.threadHeadMessageID.rawValue] as? String{
            self.threadHeadMessageID = threadHeadMessageID
        }
        
        //get the links
        if let links = commentData[commentKeys.links.rawValue] as? BodyDataDictionary{
            if let linksSelf = links[commentKeys._self.rawValue],
                let linksSelfHref = linksSelf[commentKeys.href.rawValue] as? String{
                self.selfLink = linksSelfHref
            }
            
            if let linksEdit = links[commentKeys.edit.rawValue],
                let linksEditHref = linksEdit[commentKeys.href.rawValue] as? String{
                self.editLink = linksEditHref
            }
            
            if let threadHeadLink = links[commentKeys.yona_threadHead.rawValue],
                let threadHeadLinkHref = threadHeadLink[commentKeys.href.rawValue] as? String{
                self.threadHeadLink = threadHeadLinkHref
            }
            
            if let dayDetailsLink = links[commentKeys.yona_dayDetails.rawValue],
                let dayDetailsLinkHref = dayDetailsLink[commentKeys.href.rawValue] as? String{
                self.dayDetailsLink = dayDetailsLinkHref
            }
            
            if let markReadLink = links[commentKeys.yona_markRead.rawValue],
                let markReadLinkHref = markReadLink[commentKeys.href.rawValue] as? String{
                self.markReadLink = markReadLinkHref
            }
            
            if let yonaUser = links[commentKeys.yona_user.rawValue],
                let yonaUserHref = yonaUser[commentKeys.href.rawValue] as? String{
                self.yonaUser = yonaUserHref
            }
        }
        
    }
}