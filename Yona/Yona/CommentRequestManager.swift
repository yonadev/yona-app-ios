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
    
    func postComment(postGoalMessageLink: String){
        self.APIService.callRequestWithAPIServiceResponse(nil, path: postGoalMessageLink, httpMethod: httpMethods.post) { (success, json, error) in
            
        }
    }
}