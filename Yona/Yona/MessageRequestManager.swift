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
                    self.messages.removeAll()
                    if let getMessagesLink = user?.messagesLink {
                        let path = getMessagesLink + "?size=" + String(size) + "&page=" + String(page)
                        self.APIService.callRequestWithAPIServiceResponse(body, path: path, httpMethod: httpMethod) { success, json, error in
                            if let json = json {
                                if let embedded = json[getMessagesKeys.embedded.rawValue],
                                let yonaMessages = embedded[getMessagesKeys.yonaMessages.rawValue] as? NSArray{
                                    //iterate messages
                                    for message in yonaMessages {
                                        if let message = message as? BodyDataDictionary {
                                            let aMessage = Message.init(messageData: message)
                                            if aMessage.UserRequestmobileNumber.characters.count > 0 {
                                                self.messages.append(aMessage)
                                            }
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

    
    func postAcceptMessage(aMesage : Message, onCompletion: APIResponse ){
        if let acceptLink = aMesage.acceptLink {        
            let body = ["properties":[:]]
            self.APIService.callRequestWithAPIServiceResponse(body, path: acceptLink, httpMethod: .post, onCompletion: {success, json, error in
                print("how did we do \(success)")
                onCompletion(success , "", "")
            })
        }
    }

}