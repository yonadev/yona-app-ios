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
    
    fileprivate init() {}
    
    func postComment(_ postGoalMessageLink: String, messageBody: BodyDataDictionary, onCompletion: @escaping APICommentResponse){
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
    
    func postReply(_ postReplyLink: String, messageBody: BodyDataDictionary, onCompletion: @escaping APICommentResponse){
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
    
    
    func getComments(_ getCommentsLink: String, size: Int, page: Int, onCompletion: @escaping APICommentResponse){
        let path = getCommentsLink + "?size=" + String(size) + "&page=" + String(page-1)
        self.APIService.callRequestWithAPIServiceResponse(nil, path: path, httpMethod: httpMethods.get) { success, json, error in
            if let json = json {
                if let embedded = json[getMessagesKeys.embedded.rawValue],
                    let yonaComments = embedded[getMessagesKeys.yonaMessages.rawValue] as? NSArray{
                    //iterate messages
                    self.comments = []
                    for comment in yonaComments {
                        if let comment = comment as? BodyDataDictionary {
                            var comment = Comment.init(commentData: comment)
                            if let data = json[commentKeys.page.rawValue] {
                                if let size = data[commentKeys.size.rawValue] as? Int{
                                    comment.currentSize = size
                                }
                                if let totalSize = data[commentKeys.totalElements.rawValue] as? Int{
                                    comment.totalSize = totalSize
                                }
                                if let totalPages = data[commentKeys.totalPages.rawValue] as? Int{
                                    comment.totalPages = totalPages
                                }
                                if let currentPage = data[commentKeys.number.rawValue] as? Int{
                                    comment.currentPage = currentPage
                                }
                            }
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
    
    func deleteComment(_ aComment : Comment, onCompletion: @escaping APIResponse ){
        if let deleteLink = aComment.editLink {
            let body = ["properties":[:]]
            self.APIService.callRequestWithAPIServiceResponse(body as BodyDataDictionary, path: deleteLink, httpMethod: .delete, onCompletion: {success, json, error in
                onCompletion(success , error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error))
            })
        } else {
            onCompletion(false, NSLocalizedString("failed-to-retrieve-delete-link", comment: ""), String(describing: responseCodes.internalErrorCode))
        }
    }
    
    // MARK: - get replies data and filter
    func getRepliesToThreadID(_ commentLink: String?, threadID: String?, size: Int, page: Int, onCompletion: @escaping APICommentResponse) {
        CommentRequestManager.sharedInstance.getComments(commentLink!, size: size, page: page) { (success, comment, comments, serverMessage, serverCode) in
            if success {
                if let comments = comments {
                    self.comments = comments.filter() { $0.threadHeadMessageID == threadID }
                }
                onCompletion(success, nil, self.comments, serverMessage, serverCode) //failed to get user
            } else {
                onCompletion(false, nil, nil, serverMessage, serverCode) //failed to get user
            }
        }
    }
}
