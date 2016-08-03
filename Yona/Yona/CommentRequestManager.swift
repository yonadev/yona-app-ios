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
    
    static let sharedInstance = CommentRequestManager()
    
    private init() {}
    
    func postComment(postGoalMessageLink: String) {//, onCompletion: APIResponse){
        self.APIService.callRequestWithAPIServiceResponse(nil, path: postGoalMessageLink, httpMethod: httpMethods.post) { (success, json, error) in
            if success {
                if let json = json {
                    self.comment = Comment.init(commentData: json)
//                    onCompletion(success, serverMessage, serverCode, self.buddy, nil) //failed to get user
                } else {
//                    onCompletion(success, serverMessage, serverCode, nil, nil) //failed json response
                }
            } else {
//                onCompletion(success, serverMessage, serverCode, nil, nil)
            }
        }
    }
}