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

    static let sharedInstance = MessageRequestManager()
    
    private init() {}
    
    private func genericMessageRequest(httpMethod: httpMethods, body: BodyDataDictionary?, messageAction: String?, messageID: String?, size: Int, page: Int, onCompletion: APIMessageResponse) {
        switch httpMethod {
        case .get:
            UserRequestManager.sharedInstance.getUser(GetUserRequest.notAllowed){ (success, serverMessage, serverCode, user) in
                if success {
                    if let getMessagesLink = user?.messagesLink {
                        let path = getMessagesLink + "?size=" + String(size) + "&page=" + String(page)
                        self.APIService.callRequestWithAPIServiceResponse(body, path: path, httpMethod: httpMethod) { success, json, error in
                            if let json = json {
                                if let embedded = json[getMessagesKeys.embedded.rawValue],
                                    let yonaMessages = embedded[getMessagesKeys.yonaMessages.rawValue] as? NSArray{
                                    //iterate messages
                                    for message in yonaMessages {
                                        if let message = message as? BodyDataDictionary {
                                            self.message = Message.init(messageData: message)
                                            if let message = self.message {
                                                self.messages.append(message)
                                            }
                                        }
                                    }
                                }
                                onCompletion(success, serverMessage, serverCode, nil, nil) //failed to get user
                            }
                        }
                    } else {
                        onCompletion(false, YonaConstants.YonaErrorTypes.GetMessagesLinkFail.localizedDescription, self.APIService.determineErrorCode(YonaConstants.YonaErrorTypes.GetMessagesLinkFail), nil, nil)
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
    
    func getMessages(size: Int, page: Int, onCompletion: APIMessageResponse){
        self.genericMessageRequest(httpMethods.get, body: nil, messageAction: nil, messageID: nil, size: size, page: page, onCompletion: onCompletion)
    }
}