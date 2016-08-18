//
//  CommentRequestManager.swift
//  Yona
//
//  Created by Ben Smith on 03/08/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

class CommentRequestManager {
    let APIService = APIServiceManager.sharedInstance
    var comment: Comment?
    var comments: [Comment] = []
    
    var reply: Comment?
    var replies: [Comment] = []

    static let sharedInstance = CommentRequestManager()
    
    private init() {}
    
    func postComment(postGoalMessageLink: String, messageBody: BodyDataDictionary, onCompletion: APICommentResponse){
        self.APIService.callRequestWithAPIServiceResponse(messageBody, path: postGoalMessageLink, httpMethod: httpMethods.post) { (success, json, error) in
            if success {
                if let json = json {
                    self.comment = Comment.init(commentData: json)
                    onCompletion(success, self.comment, nil, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error)) //success
                } else {
                    onCompletion(success, nil, nil, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error)) //failed json response
                }
            } else {
                    onCompletion(success, nil, nil, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error))
            }
        }
    }
    
    func postReply(postReplyLink: String, messageBody: BodyDataDictionary, onCompletion: APICommentResponse){
        self.APIService.callRequestWithAPIServiceResponse(messageBody, path: postReplyLink, httpMethod: httpMethods.post) { (success, json, error) in
            if success {
                if let json = json {
                    if let embedded = json[commentKeys.embedded.rawValue],
                        let replies = embedded[commentKeys.yonaAffectedMessage.rawValue] as? NSArray{
                            self.replies = []

                            for reply in replies {
                                if let reply = reply as? BodyDataDictionary{
                                    self.reply = Comment.init(commentData: reply)
                                    self.replies.append(self.reply!)
                                }
                            }
                            onCompletion(success, self.reply, self.replies, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error)) //success
                    } else {
                        onCompletion(false, nil, self.comments, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error)) //failed to get user
                    }
                } else {
                    onCompletion(success, nil, nil, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error)) //failed json response
                }
            }
        }
    }
    
    
    func getComments(getCommentsLink: String, size: Int, page: Int, onCompletion: APICommentResponse){
        let path = getCommentsLink + "?size=" + String(size) + "&page=" + String(page)
        self.APIService.callRequestWithAPIServiceResponse(nil, path: path, httpMethod: httpMethods.get) { success, json, error in
            if let json = json {
                if let embedded = json[getMessagesKeys.embedded.rawValue],
                    let yonaComments = embedded[getMessagesKeys.yonaMessages.rawValue] as? NSArray{
                    //iterate messages
                    self.comments = []
                    for comment in yonaComments {
                        if let comment = comment as? BodyDataDictionary {
                            let comment = Comment.init(commentData: comment)
                            self.comments.append(comment)
                        }
                    }
                    onCompletion(success, nil, self.comments, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error)) //failed to get user
                } else {
                    onCompletion(false, nil, self.comments, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error)) //failed to get user
                }
            } else {
                onCompletion(success, nil, nil, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error)) //failed to get user
            }
        }
    }
    
    func deleteComment(aComment : Comment, onCompletion: APIResponse ){
        if let deleteLink = aComment.editLink {
            let body = ["properties":[:]]
            self.APIService.callRequestWithAPIServiceResponse(body, path: deleteLink, httpMethod: .delete, onCompletion: {success, json, error in
                onCompletion(success , error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error))
            })
        } else {
            onCompletion(false, YonaConstants.serverMessages.FailedToRetrieveDeleteLink, String(responseCodes.internalErrorCode))
        }
    }
}