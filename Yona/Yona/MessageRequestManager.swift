//
//  messageRequestManager.swift
//  Yona
//
//  Created by Ben Smith on 16/05/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation
class MessageRequestManager {
    let APIService = APIServiceManager.sharedInstance
    let APIUserRequestManager = UserRequestManager.sharedInstance
    var message: Message?
    var messages: [Message] = []

    //paging
    var currentSize: Int?
    var currentPage : Int?
    var totalSize: Int? = 0
    var totalPages : Int? = 0
    
    static let sharedInstance = MessageRequestManager()
    
    fileprivate init() {}
    
    fileprivate func genericMessageRequest(_ httpMethod: httpMethods, body: BodyDataDictionary?, messageAction: String?, messageID: String?, size: Int, page: Int, onlyUnRead : Bool = false, onCompletion: @escaping APIMessageResponse) {
        switch httpMethod {
        case .get:
            UserRequestManager.sharedInstance.getUser(GetUserRequest.notAllowed){ (success, serverMessage, serverCode, user) in
                if success {
                    ActivitiesRequestManager.sharedInstance.getActivityCategories {
                        bool, serverMessage, serverCode, activities, error in
                        self.messages.removeAll()
                        if let getMessagesLink = user?.messagesLink {
                            let path = getMessagesLink + "?size=" + String(size) + "&page=" + String(page) + "&onlyUnreadMessages="+"\(onlyUnRead)"
                            self.APIService.callRequestWithAPIServiceResponse(body, path: path, httpMethod: httpMethod) { success, json, error in
                                if let json = json {
                                    if let data = json[commentKeys.page.rawValue] {
                                        if let size = data[commentKeys.size.rawValue] as? Int{
                                            self.currentSize = size
                                        }
                                        if let totalSize = data[commentKeys.totalElements.rawValue] as? Int{
                                            self.totalSize = totalSize
                                        }
                                        if let totalPages = data[commentKeys.totalPages.rawValue] as? Int{
                                            self.totalPages = totalPages
                                        }
                                        if let currentPage = data[commentKeys.number.rawValue] as? Int{
                                            self.currentPage = currentPage
                                        }
                                    }
                                    if let embedded = json[getMessagesKeys.embedded.rawValue],
                                        let yonaMessages = embedded[getMessagesKeys.yonaMessages.rawValue] as? NSArray {
                                        
                                        
                                        //iterate messages
                                        var totalUnread = 0
                                        for message in yonaMessages {
                                            if let message = message as? BodyDataDictionary {
                                                var aMessage = Message.init(messageData: message)
                                                if  let aActivities = activities {
                                                    for aActivity in aActivities  {
                                                        if aActivity.selfLinks == aMessage.activityCategoryLink {
                                                            aMessage.activityTypeName = aActivity.activityCategoryName!
                                                        }
                                                    }
                                                }
                                                self.messages.append(aMessage)
                                                //}
                                            }
                                        }
                                        onCompletion(success, serverMessage, serverCode, nil, self.messages) //failed to get user
                                    } else {
                                        self.message = Message.init(messageData: json)
                                        onCompletion(success, serverMessage, serverCode, self.message, nil) //failed to get user
                                    }
                                } else {
                                    onCompletion(success, serverMessage, serverCode, nil, nil) //failed to get user
                                }
                 
                        }
                    } else {
                        onCompletion(false, YonaConstants.YonaErrorTypes.GetMessagesLinkFail.localizedDescription, self.APIService.determineErrorCode(YonaConstants.YonaErrorTypes.GetMessagesLinkFail), nil, nil)
                    }
                    }
                } else {
                    onCompletion(success, serverMessage, serverCode, nil, nil) //failed to get user
                }
            }
            break
        case .post:
            break
        case .put:
            break
        case .delete:
            break
        }
    }
    
    func getMessages(_ size: Int, page: Int, onCompletion: @escaping APIMessageResponse){
        self.genericMessageRequest(httpMethods.get, body: nil, messageAction: nil, messageID: nil, size: size, page: page, onCompletion: onCompletion)
    }

    func getUnReadMessages(_ onCompletion: @escaping APIMessageResponse){
        self.genericMessageRequest(httpMethods.get, body: nil, messageAction: nil, messageID: nil, size: 3  , page: 0,onlyUnRead: true, onCompletion: onCompletion)
    }

    func deleteMessage(_ aMessage : Message, onCompletion: @escaping APIResponse ){
        if let deleteLink = aMessage.editLink {
            let body = ["properties":[:]]
            self.APIService.callRequestWithAPIServiceResponse(body as BodyDataDictionary, path: deleteLink, httpMethod: .delete, onCompletion: {success, json, error in
                print("how did we do \(success)")
                onCompletion(success , "", "")
            })
        } else {
            onCompletion(false, NSLocalizedString("failed-to-retrieve-delete-link", comment: ""), String(describing: responseCodes.internalErrorCode))
        }
    }

    func postRejectMessage(_ aMesage : Message, onCompletion: @escaping APIResponse ){
        if let rejectLink = aMesage.rejectLink {
            let body = ["properties":[:]]
            self.APIService.callRequestWithAPIServiceResponse(body as BodyDataDictionary, path: rejectLink, httpMethod: .post, onCompletion: {success, json, error in
                print("how did we do \(success)")
                onCompletion(success , "", "")
            })
        } else {
            onCompletion(false, YonaConstants.serverMessages.FailedToRetrieveRejectLink, String(describing: responseCodes.internalErrorCode))
        }
    }
    
    func postAcceptMessage(_ aMesage : Message, onCompletion: @escaping APIResponse ){
        if let acceptLink = aMesage.acceptLink {        
            let body = ["properties":[:]]
            self.APIService.callRequestWithAPIServiceResponse(body as BodyDataDictionary, path: acceptLink, httpMethod: .post, onCompletion: {success, json, error in
                print("how did we do \(success)")
                UserRequestManager.sharedInstance.getUser(GetUserRequest.allowed, onCompletion:{(success, servermessage, servercode, users) in
                    print("user updated")
                })
                onCompletion(success , "", "")
            })
        } else {
            onCompletion(false, YonaConstants.serverMessages.FailedToRetrieveAcceptLink, String(describing: responseCodes.internalErrorCode))
        }
    }
    
    func postProcessLink(_ aMesage : Message, onCompletion: @escaping APIResponse ){
        if let processLink = aMesage.yonaProcessLink {
            let body = ["properties":[:]]
            self.APIService.callRequestWithAPIServiceResponse(body as BodyDataDictionary, path: processLink, httpMethod: .post, onCompletion: {success, json, error in
                print("how did we do \(success)")
                onCompletion(success , "", "")
            })
        } else {
            onCompletion(false, YonaConstants.serverMessages.FailedToRetrieveProcessLink, String(describing: responseCodes.internalErrorCode))
        }
    }

    
    func postReadMessage(_ aMesage : Message, onCompletion: @escaping APIResponse ){
        if let markAsRead = aMesage.markReadLink {
            let body = ["properties":[:]]
            self.APIService.callRequestWithAPIServiceResponse(body as BodyDataDictionary, path: markAsRead, httpMethod: .post, onCompletion: {success, json, error in
                print("how did we do \(success)")
                UserRequestManager.sharedInstance.getUser(GetUserRequest.allowed, onCompletion:{(success, servermessage, servercode, users) in
                    print("user updated")
                })
                onCompletion(success , "", "")
            })
        } else {
            onCompletion(false, YonaConstants.serverMessages.FailedToRetrieveAcceptLink, String(describing: responseCodes.internalErrorCode))
        }
    }

}
